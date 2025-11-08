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
		case QEvent::HoverEnter:
		case QEvent::HoverLeave:
		case QEvent::HoverMove: {
			auto *hv = static_cast<QHoverEvent *>(event);
			if(hv->device()) {
				if(hv->device()->type() == QInputDevice::DeviceType::Mouse) {
					isTouchInput = false;
				} else if(hv->device()->type() == QInputDevice::DeviceType::TouchPad) {
					isTouchInput = false;
				} else {
					isTouchInput = true;
				}
			}
			break;
		}
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
	connect(mpInputDetector, &InputEventFilter::touchInputChanged, this, &RootItemAttachedType::inputChanged, Qt::QueuedConnection);
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
