#pragma once
#include <QObject>

class FileLoader : public QObject{

    Q_OBJECT

public:
    FileLoader(QObject *pParent = nullptr);
    Q_INVOKABLE QString loadFileContent(const QString & filePath);
};

