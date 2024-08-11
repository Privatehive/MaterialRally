#include "materialrallyplugin.h"
#include <QDir>
#include <QFontDatabase>

void materialrallyplugin_initializeEngine(QQmlEngine *engine, const char *uri) {
    QDir fontsDir(QLatin1String(":/qt/qml/MaterialRally/fonts"));
    for (const auto &entry: fontsDir.entryList(
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
