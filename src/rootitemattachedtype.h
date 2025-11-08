#pragma once
#include "MaterialRallyExport.h"
#include <QAtomicInteger>
#include <QMutex>
#include <QQuickItem>


class InputEventFilter : public QObject {

	Q_OBJECT

 public:
	explicit InputEventFilter(bool initialValue, QObject *parent = nullptr) : QObject(parent), mIsTouch(initialValue) {}

	bool isTouch() const { return mIsTouch; }

 signals:
	void touchInputChanged(bool isTouch);

 protected:
	bool eventFilter(QObject *obj, QEvent *event) override;

 private:
	bool mIsTouch;
};

class MATERIALRALLY_EXPORT RootItemAttachedType : public QObject {

	Q_OBJECT
	Q_PROPERTY(QQuickItem *contentItem READ getContentItem WRITE setContentItem NOTIFY contentItemChanged)
	Q_PROPERTY(QObject *root READ getRoot WRITE setRoot NOTIFY rootChanged)
	Q_PROPERTY(bool isTouchInput READ isTouchInput NOTIFY inputChanged)
	Q_PROPERTY(bool isMouseInput READ isMouseInput NOTIFY inputChanged)
	QML_ANONYMOUS

 public:
	explicit RootItemAttachedType(QObject *parent = nullptr);
	static QQuickItem *getContentItem();
	void setContentItem(QQuickItem *root);
	static QObject *getRoot();
	void setRoot(QObject *root);
	static bool isTouchInput();
	static bool isMouseInput();

 signals:
	void contentItemChanged(QQuickItem *item);
	void rootChanged(QObject *root);
	void inputChanged();

 private:
	static QQuickItem *mpContentItem;
	static QObject *mpRoot;
	static InputEventFilter *mpInputDetector;
	static QMutex mMutex;
};

class RootItem : public QObject {
	Q_OBJECT
	QML_ATTACHED(RootItemAttachedType)
	QML_ELEMENT

 public:
	static RootItemAttachedType *qmlAttachedProperties(QObject *object) { return new RootItemAttachedType(object); }
};
