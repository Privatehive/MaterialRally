#include "AdvancedQmlApplicationEngine.h"
#include "QtApplicationBase.h"
#include "info.h"
#include "fileloader.h"
#include <QGuiApplication>
#include <QIcon>


int main(int argc, char** argv) {

  qmlRegisterSingletonType<FileLoader>("Qt.file", 1, 0, "FileLoader", [](QQmlEngine *e, QJSEngine *) -> QObject * {
        auto loader = new FileLoader(e);
        e->setObjectOwnership(loader, QQmlEngine::CppOwnership);
        return loader;
    });

  QtApplicationBase<QGuiApplication> app(argc, argv);
  AdvancedQmlApplicationEngine qmlEngine;
  QIcon::setThemeName("material");

#ifdef QT_DEBUG
  auto qmlMainFile = QString("src/gallery/main.qml");
  if(!QFile::exists(qmlMainFile)) {
    qInfo() << "QML hot reloading enabled";
    qmlEngine.setHotReload(true);
    qmlEngine.loadRootItem(qmlMainFile, false);
  } else {
    qmlEngine.addImportPath(QML_IMPORT_PATH);
    qmlEngine.setHotReload(false);
    qmlEngine.loadRootItem("qrc:/qt/qml/Application/main.qml", false);
  }
#else
  qmlEngine.setHotReload(false);
	qmlEngine.loadRootItem("qrc:/Application/res/gui/main.qml");
#endif

  return app.start();
}
