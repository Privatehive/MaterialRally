#include <QDir>
#include <QFontDatabase>
#include <QtQml/qqmlextensionplugin.h>

extern void qml_register_types_MaterialRally();
Q_GHS_KEEP_REFERENCE(qml_register_types_MaterialRally)

class MaterialRallyPlugin : public QQmlEngineExtensionPlugin {

  Q_OBJECT
  Q_PLUGIN_METADATA(IID QQmlEngineExtensionInterface_iid)

public:
  void initializeEngine(QQmlEngine *engine, const char *uri) override {

    Q_UNUSED(engine);
    Q_UNUSED(uri);
    QDir fontsDir(QLatin1String(":/qt/qml/MaterialRally/fonts"));
    for (const auto &entry : fontsDir.entryList(
             {QLatin1String("*.ttf"), QLatin1String("*.otf")}, QDir::Files)) {
      auto fontId =
          QFontDatabase::addApplicationFont(fontsDir.absoluteFilePath(entry));
      if (fontId >= 0) {
        qInfo() << "Font registered:"
                << QFontDatabase::applicationFontFamilies(fontId);
      } else {
        qWarning() << "Couldn't install font.";
      }
    }
  }
};

#include "materialrallyplugin.moc"
