#include "velocitytracker.h"


VelocityTracker::VelocityTracker(QObject *parent) : QObject(parent) {

	mClock.start();
}

void VelocityTracker::setWindowMs(int windowMs) {

	if(mWindowMs == windowMs) return;
	mWindowMs = windowMs;
	emit windowMsChanged();
}

void VelocityTracker::reset() {

	mHead = 0;
	mCount = 0;
	mVx = 0;
	mVy = 0;
	mLastX = 0;
	mLastY = 0;
}

void VelocityTracker::record(qreal x, qreal y) {

	mSamples[mHead] = {x, y, mClock.nsecsElapsed()};
	mHead = (mHead + 1) & Mask;
	if(mCount < Capacity) ++mCount;
	mLastX = x;
	mLastY = y;
}

void VelocityTracker::compute() {

	mVx = 0;
	mVy = 0;
	if(mCount < 2) return;
	const int newest = (mHead - 1) & Mask;
	const qint64 tNew = mSamples[newest].ns;
	if(mClock.nsecsElapsed() - tNew > PointerStoppedMs * 1000000) return;
	const qint64 windowNs = qint64(mWindowMs) * 1000000;
	int oldest = newest;
	for(int k = 1; k < mCount; ++k) {
		const int j = (newest - k) & Mask;
		if(tNew - mSamples[j].ns > windowNs) break;
		oldest = j;
	}
	if(oldest == newest) return;
	const qint64 dtNs = tNew - mSamples[oldest].ns;
	if(dtNs <= 0) return;
	const qreal dt = qreal(dtNs) / 1e9;
	mVx = (mSamples[newest].x - mSamples[oldest].x) / dt;
	mVy = (mSamples[newest].y - mSamples[oldest].y) / dt;
}
