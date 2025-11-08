#include "AdvancedQmlApplicationEngine.h"
#include "QtApplicationBase.h"
#include <QFile>
#include <QGuiApplication>
#include <QIcon>
#include <QStyleHints>

/*!
    \title Material Rally Gallery
    \subtitle An example app showing all available Material Rally styled controls
*/
int main(int argc, char **argv) {

	QtApplicationBase<QGuiApplication> app(argc, argv);
	AdvancedQmlApplicationEngine qmlEngine;
	QIcon::setThemeName("material");

#ifdef QT_DEBUG
	auto qmlMainFile = QString("Gallery/Gallery/main.qml");
	if(QFile::exists(qmlMainFile)) {
		qInfo() << "QML hot reloading enabled";
		qmlEngine.setHotReload(true);
		qmlEngine.loadRootItem(qmlMainFile, true);
	} else {
		qmlEngine.setHotReload(false);
		qmlEngine.loadRootItem("qrc:/qt/qml/Gallery/Gallery/main.qml", false);
	}
#else
	qmlEngine.setHotReload(false);
	qmlEngine.loadRootItem("qrc:/qt/qml/Gallery/Gallery/main.qml", false);
#endif

	return app.start();
}
