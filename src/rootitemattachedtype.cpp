#include "rootitemattachedtype.h"
#include <QDebug>

QQuickItem *RootItemAttachedType::mpContentItem = nullptr;
QQuickItem *RootItemAttachedType::mpHeader = nullptr;
QQuickItem *RootItemAttachedType::mpFooter = nullptr;
InputEventFilter *RootItemAttachedType::mpInputDetector = nullptr;
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WATCHOS)
bool RootItemAttachedType::mTouchInput = true;
#else
bool RootItemAttachedType::mTouchInput = false;
#endif


bool InputEventFilter::eventFilter(QObject *obj, QEvent *event) {

	static bool firstEvent = true;
	static bool isTouch = false;

	/*
	switch(event->type()) {
	  case QEvent::MouseMove:
	    if(firstEvent || isTouch == true) {
	      firstEvent = false;
	      isTouch = false;
	      emit touchInputChanged(false);
	    }
	    break;
	  case QEvent::HoverMove:
	    if(firstEvent || isTouch == false) {
	      firstEvent = false;
	      isTouch = true;
	      emit touchInputChanged(true);
	    }
	    break;
	  default:
	    break;
	}
	*/
	return false;
}

RootItemAttachedType::RootItemAttachedType(QObject *parent) {

	if(!mpInputDetector) {
		mpInputDetector = new InputEventFilter(nullptr);
	}

	connect(
	 mpInputDetector, &InputEventFilter::touchInputChanged, this,
	 [this](bool isTouch) {
		 if(isTouch != mTouchInput) {
			 if(isTouch) {
				 qInfo() << "Input method changed from mouse to touch";
			 } else {
				 qInfo() << "Input method changed from touch to mouse";
			 }
			 mTouchInput = isTouch;
		 }
		 emit inputChanged(); // don't move into if block
	 },
	 Qt::QueuedConnection);
}

QQuickItem *RootItemAttachedType::getContentItem() {

	return mpContentItem;
}

void RootItemAttachedType::setContentItem(QQuickItem *root) {

	if(mpContentItem && mpContentItem != root) {
		mpContentItem->removeEventFilter(mpInputDetector);
	}
	if(root) {
		root->installEventFilter(mpInputDetector);
	}

	mpContentItem = root;
	emit contentItemChanged(mpContentItem);
}

QQuickItem *RootItemAttachedType::getHeader() {

	return mpHeader;
}

void RootItemAttachedType::setHeader(QQuickItem *root) {

	if(mpHeader && mpHeader != root) {
		mpHeader->removeEventFilter(mpInputDetector);
	}
	if(root) {
		root->installEventFilter(mpInputDetector);
	}

	mpHeader = root;
	emit headerChanged(mpHeader);
}

QQuickItem *RootItemAttachedType::getFooter() {

	return mpFooter;
}

void RootItemAttachedType::setFooter(QQuickItem *root) {

	if(mpFooter && mpFooter != root) {
		mpFooter->removeEventFilter(mpInputDetector);
	}
	if(root) {
		root->installEventFilter(mpInputDetector);
	}

	mpFooter = root;
	emit footerChanged(mpFooter);
}

bool RootItemAttachedType::isTouchInput() const {

	return mTouchInput;
}

bool RootItemAttachedType::isMouseInput() const {

	return !mTouchInput;
}
