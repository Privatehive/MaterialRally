#include "rootitemattachedtype.h"
#include <QDebug>
#include <qthread.h>

QQuickItem *RootItemAttachedType::mpContentItem = nullptr;
QObject *RootItemAttachedType::mpRoot = nullptr;
InputEventFilter *RootItemAttachedType::mpInputDetector = nullptr;
QMutex RootItemAttachedType::mMutex = QMutex();


bool InputEventFilter::eventFilter(QObject *obj, QEvent *event) {

	bool isTouchInput = mIsTouch;

	switch(event->type()) {
		// Hover events are deliberately ignored. Qt Quick synthesizes them itself: while a finger
		// is down it keeps the touch point as its "last mouse position" and, on every frame in
		// which something changed, re-sends a hover there (QQuickDeliveryAgent's frame-synchronous
		// hover) - carrying the primary pointing device, which is a mouse. Counting those flipped
		// a scrolling finger to "mouse" and, e.g., made the ScrollView's scroll bar grab the touch.
		// A real mouse or touchpad always shows up as MouseMove below as well.
		case QEvent::MouseButtonPress:
		case QEvent::MouseMove:
		case QEvent::MouseButtonRelease: {
			auto *me = static_cast<QMouseEvent *>(event);
			if(me->source() == Qt::MouseEventNotSynthesized) {
				isTouchInput = false;
			} else if(me->source() == Qt::MouseEventSynthesizedBySystem) {
				isTouchInput = true;
			} else if(me->source() == Qt::MouseEventSynthesizedByQt) {
				isTouchInput = true;
			}
			break;
		}
		case QEvent::TouchBegin:
		case QEvent::TouchUpdate:
		case QEvent::TouchEnd: {
			// auto *te = static_cast<QTouchEvent *>(event);
			isTouchInput = true;
			break;
		}
		default:
			break;
	}

	if(mIsTouch != isTouchInput) {
		mIsTouch = isTouchInput;
		emit touchInputChanged(isTouchInput);
	}
	return false;
}

RootItemAttachedType::RootItemAttachedType(QObject *parent) {

	mMutex.lock();
	if(!mpInputDetector) {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WATCHOS)
		auto isTouch = true;
#else
		auto isTouch = false;
#endif
		mpInputDetector = new InputEventFilter(isTouch, QCoreApplication::instance());
		QCoreApplication::instance()->installEventFilter(mpInputDetector);
	}
	// Direct, so bindings on isTouchInput/isMouseInput update before the event that changed it is
	// delivered - an application event filter runs ahead of delivery, and only ever for objects in
	// the main thread. Queued, the first touch after using a mouse still reached controls in their
	// mouse configuration (e.g. an interactive ScrollBar).
	connect(mpInputDetector, &InputEventFilter::touchInputChanged, this, &RootItemAttachedType::inputChanged, Qt::DirectConnection);
	mMutex.unlock();
}

QQuickItem *RootItemAttachedType::getContentItem() {

	QMutexLocker locker(&mMutex);
	return mpContentItem;
}

void RootItemAttachedType::setContentItem(QQuickItem *root) {

	QMutexLocker locker(&mMutex);
	mpContentItem = root;
	emit contentItemChanged(mpContentItem);
}

QObject *RootItemAttachedType::getRoot() {

	QMutexLocker locker(&mMutex);
	return mpRoot;
}

void RootItemAttachedType::setRoot(QObject *root) {

	QMutexLocker locker(&mMutex);
	mpRoot = root;
	emit rootChanged(mpRoot);
}

bool RootItemAttachedType::isTouchInput() {

	QMutexLocker locker(&mMutex);
	return mpInputDetector->isTouch();
}

bool RootItemAttachedType::isMouseInput() {

	QMutexLocker locker(&mMutex);
	return !mpInputDetector->isTouch();
}
