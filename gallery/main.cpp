#include "fileloader.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QDir>
#include <QtPlugin>

#ifndef QML_IMPORT_PATH
#define QML_IMPORT_PATH ""
#endif
#ifndef QML_PLUGIN_PATHS
#define QML_PLUGIN_PATHS ""
#endif

Q_IMPORT_PLUGIN(MaterialRallyPlugin);

int main(int argc, char** argv) {
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.setImportPathList({QLatin1String("qrc:/"), QLatin1String("qrc:/qt-project.org/imports")}/*QStringList(QLatin1String("qrc:/"))+engine.importPathList()+QString::fromLocal8Bit(QML_IMPORT_PATHS).split(QLatin1String(","))*/);
    engine.setPluginPathList({QLatin1String("qrc:/"), QLatin1String("qrc:/qt-project.org/imports")}/*QStringList(QLatin1String("qrc:/"))+engine.pluginPathList()+QString::fromLocal8Bit(QML_PLUGIN_PATHS).split(QLatin1String(","))*/);
    qInfo() << "qml import paths:" << engine.importPathList();
    qInfo() << "qml plugin paths:" << engine.importPathList();
    // Install fonts
    QFontDatabase fontDb;
    QDir fontsDir(QLatin1String(":/fonts"));
    for(const auto &entry : fontsDir.entryList({QLatin1String("*.ttf"), QLatin1String("*.otf")}, QDir::Files)) {
        auto fontId = QFontDatabase::addApplicationFont(fontsDir.absoluteFilePath(entry));
        if(fontId >= 0) {
            auto fontFamily = QFontDatabase::applicationFontFamilies(fontId);
            qInfo() << "Font registered:" << QFontDatabase::applicationFontFamilies(fontId);
        } else {
            qWarning() << "Couldn't install font.";
        }
    }

    qmlRegisterSingletonType<FileLoader>("Qt.file", 1, 0, "FileLoader", [](QQmlEngine *e, QJSEngine *) -> QObject * {
        auto loader = new FileLoader(e);
        e->setObjectOwnership(loader, QQmlEngine::CppOwnership);
        return loader;
    });

    Q_INIT_RESOURCE(MaterialRallyPlugin);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    return app.exec();
}
