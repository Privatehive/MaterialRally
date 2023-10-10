#include <QDir>
#include <QFontDatabase>
#include <QQmlApplicationEngine>

/*
void MaterialRallyPlugin::init() {

  qputenv("QT_QUICK_CONTROLS_CONF", ":/qt/qml/MaterialRally/qtquickcontrols2.conf");
  QDir fontsDir(QLatin1String(":/qt/qml/MaterialRally/fonts"));
  for(const auto &entry : fontsDir.entryList({QLatin1String("*.ttf"), QLatin1String("*.otf")}, QDir::Files)) {
    auto fontId = QFontDatabase::addApplicationFont(fontsDir.absoluteFilePath(entry));
    if(fontId >= 0) {
      qInfo() << "Font registered:" << QFontDatabase::applicationFontFamilies(fontId);
    } else {
      qWarning() << "Couldn't install font.";
    }
  }
}*/

#include <QtQml/qqmlextensionplugin.h>

extern void qml_register_types_MaterialRally();
Q_GHS_KEEP_REFERENCE(qml_register_types_MaterialRally)

class MaterialRallyPlugin : public QQmlEngineExtensionPlugin
{
Q_OBJECT
  Q_PLUGIN_METADATA(IID QQmlEngineExtensionInterface_iid)

public:
  explicit MaterialRallyPlugin(QObject *parent = nullptr) : QQmlEngineExtensionPlugin(parent) {
    volatile auto registration = &qml_register_types_MaterialRally;
    Q_UNUSED(registration)
  }

  void initializeEngine(QQmlEngine *engine, const char *uri) override {

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
};

#include "materialrallyplugin.moc"
