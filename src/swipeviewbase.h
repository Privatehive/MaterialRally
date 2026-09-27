#pragma once
#include <QPointer>
#include <QQuickItem>
#include <QtQml/qqmlregistration.h>

class SwipeViewBase;


/*!
    The attached SwipeView properties of a Rally.SwipeView page, with the same names and meaning as
    QtQuick.Controls' SwipeView attached properties. Like there, they are only set on the pages
    themselves (the SwipeView's direct children or a Repeater's delegates), not on items further
    down inside a page; elsewhere index is -1, view is null and every flag is false.
*/
class SwipeViewAttached : public QObject {

	Q_OBJECT
	Q_PROPERTY(int index READ index NOTIFY indexChanged FINAL)
	Q_PROPERTY(bool isCurrentItem READ isCurrentItem NOTIFY isCurrentItemChanged FINAL)
	Q_PROPERTY(bool isNextItem READ isNextItem NOTIFY isNextItemChanged FINAL)
	Q_PROPERTY(bool isPreviousItem READ isPreviousItem NOTIFY isPreviousItemChanged FINAL)
	Q_PROPERTY(QQuickItem *view READ view NOTIFY viewChanged FINAL)
	QML_ANONYMOUS

 public:
	explicit SwipeViewAttached(QObject *parent = nullptr) : QObject(parent) {}

	int index() const { return mIndex; }
	bool isCurrentItem() const { return mIndex >= 0 && mIndex == mCurrentIndex; }
	bool isNextItem() const { return mIndex >= 0 && mIndex == mCurrentIndex + 1; }
	bool isPreviousItem() const { return mIndex >= 0 && mIndex == mCurrentIndex - 1; }
	QQuickItem *view() const;

	void update(SwipeViewBase *view, int index, int currentIndex);

 signals:
	void indexChanged();
	void isCurrentItemChanged();
	void isNextItemChanged();
	void isPreviousItemChanged();
	void viewChanged();

 private:
	QPointer<SwipeViewBase> mView;
	int mIndex = -1;
	int mCurrentIndex = -1;
};

/*!
    The C++ root of Rally.SwipeView, there only to carry its attached properties: attached
    properties must come from a C++ type, and QML resolves them for a QML component through its
    C++ base type. Not meant to be used on its own.

    SwipeView.qml tells it the pages and the current index; it keeps every page's attached object
    up to date, and fills in one that a page creates later.
*/
class SwipeViewBase : public QQuickItem {

	Q_OBJECT
	QML_ELEMENT
	QML_ATTACHED(SwipeViewAttached)

 public:
	explicit SwipeViewBase(QQuickItem *parent = nullptr) : QQuickItem(parent) {}

	static SwipeViewAttached *qmlAttachedProperties(QObject *object);

	Q_INVOKABLE void _setPages(const QList<QQuickItem *> &pages, int currentIndex);
	Q_INVOKABLE void _setCurrentIndex(int currentIndex);

 private:
	int pageIndex(const QQuickItem *item) const;
	void updatePage(QQuickItem *page, int index);

	QList<QPointer<QQuickItem>> mPages;
	int mCurrentIndex = -1;
};
