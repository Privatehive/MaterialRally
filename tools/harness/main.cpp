// RallyHarness - drives a QML scene offscreen with synthetic touch input, for testing.
//
// Runs on the "offscreen" QPA platform (no display server needed), injects touch through
// QWindowSystemInterface (the same path a real touch driver takes, so DragHandler & co. see a
// genuine TouchScreen device), and executes a line-based script. Moves are paced in real time
// because Rally's VelocityTracker samples Date.now().
//
// Usage: RallyHarness [-c CMD]... [SCRIPT | -]...
//
// Commands (one per line, '#' starts a comment, coordinates are logical scene pixels):
//   load FILE                   load a QML file (root may be a Window or an Item)
//   size W H                    resize the window
//   wait MS                     keep the event loop running for MS milliseconds
//   down X Y [ID]               touch press
//   move X Y [ID]               touch move
//   up [X Y] [ID]               touch release (at the last position if X Y omitted)
//   drag X1 Y1 X2 Y2 MS [HZ]    press, then move linearly over MS at HZ (default 120); no release
//   swipe X1 Y1 X2 Y2 MS [HZ]   drag + release at the end point
//   click X Y                   mouse click (left button)
//   wheel X Y DY [DX]           mouse wheel, in angle-delta units (120 = one notch)
//   shot FILE                   save a screenshot (PNG, path relative to the working directory)
//   eval EXPR                   evaluate JS with the root object as scope and print the result
//   expect EXPR                 like eval, but fail (exit code 1) if the result is falsy
//   at X Y                      print the item stack under a point
//   tree [DEPTH]                print the visible item tree with ids and scene geometry
//
// In every command except eval/expect, `{EXPR}` is replaced by the value of the JS expression, so
// a gesture can target an item wherever it currently is: `down 200 {H.rect(list).y + 50}`.
//
// Qt Quick merges touch moves that arrive between two frames, as it does on a device. Put a short
// `wait` after a `move` whose exact position must be seen on its own (e.g. the one that crosses a
// drag threshold).
//
// Relative paths in `load` resolve against the script's directory (the working directory for -c).
//
// In eval/expect, the root object is the scope, plus a helper object `H`:
//   H.find(name [, within])   nearest (breadth-first) object whose QML id or objectName matches,
//                             searching the whole scene or only below `within` (ids are not unique
//                             across components, e.g. every Rally.ScrollView has an internal
//                             #flickable)
//   H.ancestor(item, name)    nearest ancestor of `item` whose id or objectName matches
//   H.rect(item)              the item's scene rectangle
//   H.set(key, value)         remember a value for a later command (e.g. a position to compare)
//   H.get(key)                read it back

#include <QCommandLineParser>
#include <QDir>
#include <QElapsedTimer>
#include <QEventLoop>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QIcon>
#include <QJSValue>
#include <QJsonDocument>
#include <QPointingDevice>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlExpression>
#include <QQuickItem>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QTextStream>
#include <QTimer>
#include <QWheelEvent>
#include <private/qhighdpiscaling_p.h>
#include <qpa/qwindowsysteminterface.h>

static QTextStream out(stdout);
static QTextStream err(stderr);

static QString describe(QObject *obj) {
	if (!obj) return QStringLiteral("null");
	QString s = QString::fromLatin1(obj->metaObject()->className());
	if (auto *ctx = qmlContext(obj)) {
		const QString id = ctx->nameForObject(obj);
		if (!id.isEmpty()) s += QStringLiteral(" #") + id;
	}
	if (!obj->objectName().isEmpty()) s += QStringLiteral(" '%1'").arg(obj->objectName());
	return s;
}

class Helper : public QObject {
	Q_OBJECT
public:
	QQuickItem *root = nullptr;

	Q_INVOKABLE QObject *find(const QString &name, QObject *within = nullptr) const {
		return find(within ? within : root, name);
	}

	Q_INVOKABLE QObject *ancestor(QQuickItem *item, const QString &name) const {
		for (auto *p = item ? item->parentItem() : nullptr; p; p = p->parentItem())
			if (matches(p, name)) return p;
		return nullptr;
	}

	Q_INVOKABLE void set(const QString &key, const QVariant &value) { store.insert(key, value); }
	Q_INVOKABLE QVariant get(const QString &key) const { return store.value(key); }

	Q_INVOKABLE QRectF rect(QQuickItem *item) const {
		return item ? item->mapRectToScene(QRectF(0, 0, item->width(), item->height())) : QRectF();
	}

private:
	QVariantMap store;

	static bool matches(QObject *obj, const QString &name) {
		if (obj->objectName() == name) return true;
		auto *ctx = qmlContext(obj);
		return ctx && ctx->nameForObject(obj) == name;
	}

	static QObject *find(QObject *start, const QString &name) {
		QList<QObject *> queue{start};
		QSet<QObject *> seen;
		while (!queue.isEmpty()) {
			QObject *obj = queue.takeFirst();
			if (!obj || seen.contains(obj)) continue;
			seen.insert(obj);
			if (matches(obj, name)) return obj;
			// Visual children are not necessarily QObject children, so walk both.
			if (auto *item = qobject_cast<QQuickItem *>(obj)) {
				for (auto *child : item->childItems()) queue.append(child);
			}
			queue.append(obj->children());
		}
		return nullptr;
	}
};

class Harness {
public:
	QQmlApplicationEngine engine;
	QQuickWindow *window = nullptr;
	QObject *rootObject = nullptr;
	Helper helper;
	QPointingDevice *touch = nullptr;
	QElapsedTimer clock;
	QHash<int, QPointF> activePoints;
	bool failed = false;
	QDir baseDir;

	Harness() {
		touch = new QPointingDevice(QStringLiteral("RallyHarness touchscreen"), 1000,
		                            QInputDevice::DeviceType::TouchScreen, QPointingDevice::PointerType::Finger,
		                            QInputDevice::Capability::Position | QInputDevice::Capability::Area |
		                                QInputDevice::Capability::NormalizedPosition,
		                            10, 0);
		QWindowSystemInterface::registerInputDevice(touch);
		engine.addImportPath(QStringLiteral(RALLY_QML_IMPORT_DIR));
		engine.rootContext()->setContextProperty(QStringLiteral("H"), &helper);
		clock.start();
	}

	static void wait(int ms) {
		QEventLoop loop;
		QTimer::singleShot(qMax(0, ms), &loop, &QEventLoop::quit);
		loop.exec();
	}

	bool requireWindow() {
		if (window) return true;
		err << "error: no scene loaded (use 'load FILE' first)\n";
		return false;
	}

	bool load(const QString &file) {
		const QUrl url = QUrl::fromLocalFile(baseDir.absoluteFilePath(file));
		engine.load(url);
		if (engine.rootObjects().isEmpty()) {
			err << "error: failed to load " << file << "\n";
			return false;
		}
		rootObject = engine.rootObjects().constLast();
		window = qobject_cast<QQuickWindow *>(rootObject);
		if (!window) {
			// A bare Item root: host it in a window of its own size.
			auto *item = qobject_cast<QQuickItem *>(rootObject);
			if (!item) {
				err << "error: root object is neither a Window nor an Item\n";
				return false;
			}
			window = new QQuickWindow;
			item->setParentItem(window->contentItem());
			window->resize(qMax(1, int(item->width())), qMax(1, int(item->height())));
		}
		helper.root = window->contentItem();
		window->show();
		wait(200);
		return true;
	}

	void sendTouch(int id, QEventPoint::State state, QPointF scenePos) {
		QWindowSystemInterface::TouchPoint tp;
		tp.id = id;
		tp.state = state;
		tp.pressure = state == QEventPoint::State::Released ? 0 : 1;
		const QPointF nativeGlobal = QHighDpi::toNativeGlobalPosition(window->mapToGlobal(scenePos), window);
		tp.area = QRectF(nativeGlobal - QPointF(2, 2), QSizeF(4, 4));
		const QRectF screenGeo = QHighDpi::toNativePixels(window->screen()->geometry(), window->screen());
		tp.normalPosition = QPointF((nativeGlobal.x() - screenGeo.x()) / screenGeo.width(),
		                            (nativeGlobal.y() - screenGeo.y()) / screenGeo.height());

		QList<QWindowSystemInterface::TouchPoint> points{tp};
		// Other fingers that are still down must be reported as stationary.
		for (auto it = activePoints.cbegin(); it != activePoints.cend(); ++it) {
			if (it.key() == id) continue;
			QWindowSystemInterface::TouchPoint other;
			other.id = it.key();
			other.state = QEventPoint::State::Stationary;
			other.pressure = 1;
			const QPointF g = QHighDpi::toNativeGlobalPosition(window->mapToGlobal(it.value()), window);
			other.area = QRectF(g - QPointF(2, 2), QSizeF(4, 4));
			points.append(other);
		}
		QWindowSystemInterface::handleTouchEvent<QWindowSystemInterface::SynchronousDelivery>(
		    window, ulong(clock.elapsed()), touch, points);

		if (state == QEventPoint::State::Released)
			activePoints.remove(id);
		else
			activePoints.insert(id, scenePos);
	}

	void drag(QPointF from, QPointF to, int ms, int hz, bool release) {
		sendTouch(0, QEventPoint::State::Pressed, from);
		const int steps = qMax(1, ms * hz / 1000);
		QElapsedTimer t;
		t.start();
		for (int i = 1; i <= steps; ++i) {
			// Pace against the absolute schedule so event-loop jitter does not accumulate.
			wait(int(qint64(ms) * i / steps - t.elapsed()));
			sendTouch(0, QEventPoint::State::Updated, from + (to - from) * (qreal(i) / steps));
		}
		if (release) sendTouch(0, QEventPoint::State::Released, to);
	}

	void mouseClick(QPointF pos) {
		const QPointF global = window->mapToGlobal(pos);
		QWindowSystemInterface::handleMouseEvent<QWindowSystemInterface::SynchronousDelivery>(
		    window, ulong(clock.elapsed()), pos, global, Qt::LeftButton, Qt::LeftButton, QEvent::MouseButtonPress);
		wait(30);
		QWindowSystemInterface::handleMouseEvent<QWindowSystemInterface::SynchronousDelivery>(
		    window, ulong(clock.elapsed()), pos, global, Qt::NoButton, Qt::LeftButton, QEvent::MouseButtonRelease);
	}

	QVariant evaluate(const QString &expr, bool *ok) {
		QQmlContext *ctx = qmlContext(rootObject);
		QQmlExpression e(ctx ? ctx : engine.rootContext(), rootObject, expr);
		QVariant v = e.evaluate();
		*ok = !e.hasError();
		if (!*ok) err << "error: " << e.error().toString() << "\n";
		if (v.canConvert<QJSValue>()) v = v.value<QJSValue>().toVariant();
		return v;
	}

	static QString format(const QVariant &v) {
		if (auto *obj = v.value<QObject *>()) return describe(obj);
		if (v.metaType().id() == QMetaType::QRectF) {
			const QRectF r = v.toRectF();
			return QStringLiteral("rect(%1, %2, %3x%4)").arg(r.x()).arg(r.y()).arg(r.width()).arg(r.height());
		}
		if (v.metaType().id() == QMetaType::QPointF) {
			const QPointF p = v.toPointF();
			return QStringLiteral("point(%1, %2)").arg(p.x()).arg(p.y());
		}
		if (v.metaType().id() == QMetaType::QVariantList) {
			QStringList parts;
			for (const QVariant &e : v.toList()) parts << format(e);
			return QLatin1Char('[') + parts.join(QStringLiteral(", ")) + QLatin1Char(']');
		}
		if (v.metaType().id() == QMetaType::QVariantMap)
			return QString::fromUtf8(QJsonDocument::fromVariant(v).toJson(QJsonDocument::Compact));
		return v.isValid() ? v.toString() : QStringLiteral("undefined");
	}

	void printAt(QPointF pos) {
		QList<QQuickItem *> stack;
		collectAt(window->contentItem(), pos, stack);
		for (int i = stack.size() - 1; i >= 0; --i) {
			const QRectF r = helper.rect(stack[i]);
			out << "  " << describe(stack[i]) << "  [" << r.x() << "," << r.y() << " " << r.width() << "x"
			    << r.height() << "]\n";
		}
	}

	static void collectAt(QQuickItem *item, QPointF scenePos, QList<QQuickItem *> &stack) {
		if (!item->isVisible()) return;
		const QPointF local = item->mapFromScene(scenePos);
		if (item->contains(local)) stack.append(item);
		for (auto *child : item->childItems()) collectAt(child, scenePos, stack);
	}

	void printTree(QQuickItem *item, int depth, int maxDepth) {
		if (!item->isVisible() || depth > maxDepth) return;
		const QRectF r = helper.rect(item);
		out << QString(depth * 2, QLatin1Char(' ')) << describe(item) << "  [" << r.x() << "," << r.y() << " "
		    << r.width() << "x" << r.height() << "]\n";
		for (auto *child : item->childItems()) printTree(child, depth + 1, maxDepth);
	}

	// Replaces each {EXPR} in `line` with its evaluated value.
	bool expand(QString &line) {
		static const QRegularExpression braces(QStringLiteral("\\{([^{}]*)\\}"));
		for (auto m = braces.match(line); m.hasMatch(); m = braces.match(line)) {
			bool ok = false;
			const QVariant v = rootObject ? evaluate(m.captured(1), &ok) : QVariant();
			if (!ok) {
				err << "error: cannot expand " << m.captured(0) << "\n";
				return false;
			}
			line.replace(m.capturedStart(), m.capturedLength(), format(v));
		}
		return true;
	}

	// Returns false only on a malformed command; assertion failures set `failed` instead.
	bool run(const QString &line) {
		QString trimmed = line.section(QLatin1Char('#'), 0, 0).trimmed();
		if (trimmed.isEmpty()) return true;
		const QString cmd = trimmed.section(QLatin1Char(' '), 0, 0);
		if (cmd != QLatin1String("eval") && cmd != QLatin1String("expect") && !expand(trimmed)) return false;
		const QString rest = trimmed.section(QLatin1Char(' '), 1).trimmed();
		const QStringList a = rest.split(QLatin1Char(' '), Qt::SkipEmptyParts);
		auto num = [&](int i, qreal def = 0) { return i < a.size() ? a[i].toDouble() : def; };
		auto pt = [&](int i) { return QPointF(num(i), num(i + 1)); };

		out << "> " << trimmed << "\n";
		out.flush();

		if (cmd == QLatin1String("load")) return load(rest);
		if (cmd == QLatin1String("wait")) {
			wait(int(num(0)));
			return true;
		}
		if (!requireWindow()) return false;

		if (cmd == QLatin1String("size")) {
			window->resize(int(num(0)), int(num(1)));
			wait(100);
		} else if (cmd == QLatin1String("down")) {
			sendTouch(int(num(2)), QEventPoint::State::Pressed, pt(0));
		} else if (cmd == QLatin1String("move")) {
			sendTouch(int(num(2)), QEventPoint::State::Updated, pt(0));
		} else if (cmd == QLatin1String("up")) {
			const int id = a.size() == 1 ? int(num(0)) : int(num(2));
			const QPointF pos = a.size() >= 2 ? pt(0) : activePoints.value(id);
			sendTouch(id, QEventPoint::State::Released, pos);
		} else if (cmd == QLatin1String("drag") || cmd == QLatin1String("swipe")) {
			if (a.size() < 5) return false;
			drag(pt(0), pt(2), int(num(4)), int(num(5, 120)), cmd == QLatin1String("swipe"));
		} else if (cmd == QLatin1String("click")) {
			mouseClick(pt(0));
		} else if (cmd == QLatin1String("wheel")) {
			const QPointF pos = pt(0);
			QWindowSystemInterface::handleWheelEvent(window, ulong(clock.elapsed()), pos, window->mapToGlobal(pos),
			                                         QPoint(), QPoint(int(num(3)), int(num(2))));
			QWindowSystemInterface::flushWindowSystemEvents();
		} else if (cmd == QLatin1String("shot")) {
			const QImage img = window->grabWindow();
			if (img.isNull() || !img.save(rest)) {
				err << "error: could not save screenshot to " << rest << "\n";
				failed = true;
			} else {
				out << "  saved " << QFileInfo(rest).absoluteFilePath() << " (" << img.width() << "x" << img.height()
				    << ")\n";
			}
		} else if (cmd == QLatin1String("eval") || cmd == QLatin1String("expect")) {
			bool ok = false;
			const QVariant v = evaluate(rest, &ok);
			if (!ok) {
				failed = true;
			} else if (cmd == QLatin1String("expect") && !v.toBool()) {
				out << "  FAIL\n";
				failed = true;
			} else {
				out << "  " << (cmd == QLatin1String("expect") ? QStringLiteral("ok") : format(v)) << "\n";
			}
		} else if (cmd == QLatin1String("at")) {
			printAt(pt(0));
		} else if (cmd == QLatin1String("tree")) {
			printTree(window->contentItem(), 0, a.isEmpty() ? 1000 : int(num(0)));
		} else {
			err << "error: unknown command '" << cmd << "'\n";
			return false;
		}
		out.flush();
		return true;
	}
};

int main(int argc, char **argv) {
	if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM")) qputenv("QT_QPA_PLATFORM", "offscreen");

	QGuiApplication app(argc, argv);
	QIcon::setThemeName(QStringLiteral("material"));

	QCommandLineParser parser;
	parser.setApplicationDescription(QStringLiteral("Drives a QML scene offscreen with synthetic touch input."));
	parser.addHelpOption();
	QCommandLineOption cmdOption(QStringLiteral("c"), QStringLiteral("Run a single command."), QStringLiteral("cmd"));
	parser.addOption(cmdOption);
	parser.addPositionalArgument(QStringLiteral("script"), QStringLiteral("Script file(s); '-' reads stdin."));
	parser.process(app);

	// Each script runs with its own directory as the base for relative paths.
	QList<QPair<QDir, QStringList>> scripts;
	for (const QString &file : parser.positionalArguments()) {
		QFile f;
		if (file == QLatin1String("-")) {
			if (!f.open(stdin, QIODevice::ReadOnly)) {
				err << "error: cannot read stdin\n";
				return 2;
			}
		} else {
			f.setFileName(file);
			if (!f.open(QIODevice::ReadOnly)) {
				err << "error: cannot open " << file << "\n";
				return 2;
			}
		}
		const QDir dir = file == QLatin1String("-") ? QDir::current() : QFileInfo(file).absoluteDir();
		scripts.append({dir, QString::fromUtf8(f.readAll()).split(QLatin1Char('\n'))});
	}
	scripts.append({QDir::current(), parser.values(cmdOption)});

	Harness harness;
	for (const auto &[dir, lines] : std::as_const(scripts)) {
		harness.baseDir = dir;
		for (const QString &line : lines) {
			if (!harness.run(line)) {
				err.flush();
				return 2;
			}
		}
	}
	out << (harness.failed ? "FAILED\n" : "PASSED\n");
	out.flush();
	return harness.failed ? 1 : 0;
}

#include "main.moc"
