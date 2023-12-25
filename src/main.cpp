#include "AdvancedQmlApplicationEngine.h"
#include "QtApplicationBase.h"
#include <QFile>
#include <QGuiApplication>
#include <QIcon>

int main(int argc, char **argv) {

  QtApplicationBase<QGuiApplication> app(argc, argv);
  AdvancedQmlApplicationEngine qmlEngine;
  QIcon::setThemeName("material");

#ifdef QT_DEBUG
  auto qmlMainFile = QString("Gallery/Gallery/main.qml");
  if (QFile::exists(qmlMainFile)) {
    qInfo() << "QML hot reloading enabled";
    qmlEngine.setHotReload(true);
    qmlEngine.loadRootItem(qmlMainFile, false);
  } else {
    qmlEngine.setHotReload(false);
    qmlEngine.loadRootItem("qrc:/qt/qml/Gallery/Gallery/main.qml", false);
  }
#else
  qmlEngine.setHotReload(false);
  qmlEngine.loadRootItem("qrc:/qt/qml/Gallery/Gallery/main.qml");
#endif

  return app.start();
}
