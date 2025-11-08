#include "materialrallyplugin.h"
#include <QDir>
#include <QFontDatabase>
#include <QQmlApplicationEngine>
#include <qqmlcontext.h>

void materialrallyplugin_initializeEngine(QQmlEngine *engine, const char *uri) {

	// Workaround: instanceOf does not work after qmlengine 'clearComponentCache' is called, which is used for hot reloading.
	auto instanceOfFunc = engine->evaluate(
	 "(function(one, two) { if(one && two) { return ''.concat('' + one).startsWith('' + two + '_'); } else { return false; } })",
	 "MaterialRallyHotReloadingWorkaround.js", 1);

	Q_ASSERT(instanceOfFunc.isCallable());

	engine->globalObject().setProperty("rallyInstanceOf", instanceOfFunc);

#ifdef QT_DEBUG
	engine->globalObject().setProperty("rallyIsDebug", QJSValue(true));
#else
	engine->globalObject().setProperty("rallyIsDebug", QJSValue(false));
#endif

	QDir fontsDir(QLatin1String(":/qt/qml/MaterialRally/fonts"));
	for(const auto &entry : fontsDir.entryList({QLatin1String("*.ttf"), QLatin1String("*.otf")}, QDir::Files)) {
		auto fontId = QFontDatabase::addApplicationFont(fontsDir.absoluteFilePath(entry));
		if(fontId >= 0) {
			qInfo() << "Font registered:" << QFontDatabase::applicationFontFamilies(fontId);
		} else {
			qWarning() << "Couldn't install font.";
		}
	}
}
