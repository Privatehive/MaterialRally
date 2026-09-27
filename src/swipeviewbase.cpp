#include "swipeviewbase.h"
#include <QtQml/qqml.h>


QQuickItem *SwipeViewAttached::view() const {

	return mView;
}

void SwipeViewAttached::update(SwipeViewBase *view, int index, int currentIndex) {

	const bool wasCurrent = isCurrentItem();
	const bool wasNext = isNextItem();
	const bool wasPrevious = isPreviousItem();
	const bool viewChanges = mView != view;
	const bool indexChanges = mIndex != index;
	mView = view;
	mIndex = index;
	mCurrentIndex = currentIndex;
	if(viewChanges) emit viewChanged();
	if(indexChanges) emit indexChanged();
	if(wasCurrent != isCurrentItem()) emit isCurrentItemChanged();
	if(wasNext != isNextItem()) emit isNextItemChanged();
	if(wasPrevious != isPreviousItem()) emit isPreviousItemChanged();
}

SwipeViewAttached *SwipeViewBase::qmlAttachedProperties(QObject *object) {

	auto *attached = new SwipeViewAttached(object);
	// A page that reads its attached properties only after the SwipeView already knows it (e.g. a
	// page created later by a Repeater) would otherwise miss the state until the next change. The
	// nearest SwipeView is the one to ask: a page is a child of that view's internal page strip.
	if(auto *item = qobject_cast<QQuickItem *>(object)) {
		for(auto *p = item->parentItem(); p; p = p->parentItem()) {
			if(auto *view = qobject_cast<SwipeViewBase *>(p)) {
				const int index = view->pageIndex(item);
				if(index >= 0) attached->update(view, index, view->mCurrentIndex);
				break;
			}
		}
	}
	return attached;
}

void SwipeViewBase::_setPages(const QList<QQuickItem *> &pages, int currentIndex) {

	// Pages that left the view lose their attached state, as with stock SwipeView.
	for(const auto &old : std::as_const(mPages)) {
		if(old && !pages.contains(old.data())) updatePage(old, -1);
	}
	mPages.clear();
	for(auto *page : pages) mPages.append(page);
	mCurrentIndex = currentIndex;
	for(int i = 0; i < mPages.size(); ++i) updatePage(mPages[i], i);
}

void SwipeViewBase::_setCurrentIndex(int currentIndex) {

	if(mCurrentIndex == currentIndex) return;
	mCurrentIndex = currentIndex;
	for(int i = 0; i < mPages.size(); ++i) updatePage(mPages[i], i);
}

int SwipeViewBase::pageIndex(const QQuickItem *item) const {

	for(int i = 0; i < mPages.size(); ++i) {
		if(mPages[i] == item) return i;
	}
	return -1;
}

void SwipeViewBase::updatePage(QQuickItem *page, int index) {

	if(!page) return;
	// Only pages that use their attached properties have an object - don't create one for the rest.
	auto *attached = qobject_cast<SwipeViewAttached *>(qmlAttachedPropertiesObject<SwipeViewBase>(page, false));
	if(attached) attached->update(index >= 0 ? this : nullptr, index, index >= 0 ? mCurrentIndex : -1);
}
