#include <QObject>
#include <QQuickItem>


class RootItemAttachedType : public QObject {

  Q_OBJECT
  Q_PROPERTY(QQuickItem* contentItem READ getContentItem WRITE setContentItem NOTIFY contentItemChanged)
  Q_PROPERTY(QQuickItem* header READ getHeader WRITE setHeader NOTIFY headerChanged)
  Q_PROPERTY(QQuickItem* footer READ getFooter WRITE setFooter NOTIFY footerChanged)
  QML_ANONYMOUS

public:
  explicit RootItemAttachedType(QObject *parent = nullptr);
  QQuickItem* getContentItem();
  void setContentItem(QQuickItem* root);
  QQuickItem* getHeader();
  void setHeader(QQuickItem* root);
  QQuickItem* getFooter();
  void setFooter(QQuickItem* root);

signals:
  void contentItemChanged(QQuickItem* root);
  void headerChanged(QQuickItem* root);
  void footerChanged(QQuickItem* root);

private:
  static QQuickItem* mpContentItem;
  static QQuickItem* mpHeader;
  static QQuickItem* mpFooter;
};

class RootItem : public QObject {

  Q_OBJECT
  QML_ATTACHED(RootItemAttachedType)
  QML_ELEMENT

public:
  static RootItemAttachedType *qmlAttachedProperties(QObject *object)
  {
    return new RootItemAttachedType(object);
  }
};
