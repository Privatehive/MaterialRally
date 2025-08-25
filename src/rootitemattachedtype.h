#include "MaterialRallyExport.h"
#include <QObject>
#include <QQuickItem>


class InputEventFilter : public QObject {

	Q_OBJECT

 public:
	explicit InputEventFilter(QObject *parent = nullptr) : QObject(parent) {}

 signals:
	void touchInputChanged(bool isTouch);

 protected:
	bool eventFilter(QObject *obj, QEvent *event) override;
};

class MATERIALRALLY_EXPORT RootItemAttachedType : public QObject {

	Q_OBJECT
	Q_PROPERTY(QQuickItem *contentItem READ getContentItem WRITE setContentItem NOTIFY contentItemChanged)
	Q_PROPERTY(QQuickItem *header READ getHeader WRITE setHeader NOTIFY headerChanged)
	Q_PROPERTY(QQuickItem *footer READ getFooter WRITE setFooter NOTIFY footerChanged)
	Q_PROPERTY(bool isTouchInput READ isTouchInput NOTIFY inputChanged)
	Q_PROPERTY(bool isMouseInput READ isMouseInput NOTIFY inputChanged)
	QML_ANONYMOUS

 public:
	explicit RootItemAttachedType(QObject *parent = nullptr);
	QQuickItem *getContentItem();
	void setContentItem(QQuickItem *root);
	QQuickItem *getHeader();
	void setHeader(QQuickItem *root);
	QQuickItem *getFooter();
	void setFooter(QQuickItem *root);
	bool isTouchInput() const;
	bool isMouseInput() const;

 signals:
	void contentItemChanged(QQuickItem *root);
	void headerChanged(QQuickItem *root);
	void footerChanged(QQuickItem *root);
	void inputChanged();

 private:
	static QQuickItem *mpContentItem;
	static QQuickItem *mpHeader;
	static QQuickItem *mpFooter;
	static InputEventFilter *mpInputDetector;
	static bool mTouchInput;
};

class RootItem : public QObject {
	Q_OBJECT
	QML_ATTACHED(RootItemAttachedType)
	QML_ELEMENT

 public:
	static RootItemAttachedType *qmlAttachedProperties(QObject *object) { return new RootItemAttachedType(object); }
};
