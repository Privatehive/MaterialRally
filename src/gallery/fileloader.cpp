#include "fileloader.h"
#include <QFile>


FileLoader::FileLoader(QObject *pParent /*= nullptr*/) : QObject(pParent) {}

QString FileLoader::loadFileContent(const QString & filePath) {

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    return QString::fromUtf8(file.readAll());
}
