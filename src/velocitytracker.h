#pragma once
#include <QElapsedTimer>
#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <array>


/*!
    Short rolling-window release-velocity tracker, shared by Rally.Flickable and Rally.SwipeView.

    Qt's own centroid.velocity is a smoothed estimate tuned for general pointer tracking, which
    systematically undershoots a real flick's release speed (a flick accelerates right up to the
    moment of release). This instead keeps raw (position, timestamp) samples over a short window
    and takes total displacement / elapsed time across it - responsive to the true recent motion
    without being as noisy as a single last-frame delta.

    A C++ type rather than a JS object so the per-touch-move code calling record() stays
    AOT-compiled (qmlcachegen cannot compile calls into an untyped JS object), and so samples get
    a monotonic nanosecond timestamp instead of Date.now()'s whole milliseconds.

    vx, vy, lastX and lastY have no notify signal on purpose: they are read imperatively right
    after compute()/record(), never bound to, and record() runs on every touch move.
*/
class VelocityTracker : public QObject {

	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int windowMs READ windowMs WRITE setWindowMs NOTIFY windowMsChanged FINAL)
	Q_PROPERTY(qreal vx READ vx FINAL)
	Q_PROPERTY(qreal vy READ vy FINAL)
	Q_PROPERTY(qreal lastX READ lastX FINAL)
	Q_PROPERTY(qreal lastY READ lastY FINAL)

 public:
	// A pointer whose newest sample is older than this when the velocity is computed has stopped,
	// so its velocity is zero. Touch digitisers send no moves while a finger rests, so without this
	// a finger that stopped and then lifted would fling at the speed it had before it stopped. Same
	// value as Android's VelocityTracker (ASSUME_POINTER_STOPPED_TIME).
	static constexpr qint64 PointerStoppedMs = 40;

	explicit VelocityTracker(QObject *parent = nullptr);

	int windowMs() const { return mWindowMs; }
	void setWindowMs(int windowMs);
	qreal vx() const { return mVx; }
	qreal vy() const { return mVy; }
	qreal lastX() const { return mLastX; }
	qreal lastY() const { return mLastY; }

	Q_INVOKABLE void reset();
	Q_INVOKABLE void record(qreal x, qreal y);
	// Velocity is the total displacement over the oldest sample still within windowMs of the
	// newest, or zero if there is no such second sample, or if the newest sample is more than
	// PointerStoppedMs old. At sample rates above ~530 Hz the oldest in-window samples are simply
	// dropped, which slightly narrows the effective window but never yields a wrong velocity.
	Q_INVOKABLE void compute();

 signals:
	void windowMsChanged();

 private:
	struct Sample {
		qreal x = 0;
		qreal y = 0;
		qint64 ns = 0;
	};

	// Must stay a power of two for the `& Mask` wrap.
	static constexpr int Capacity = 32;
	static constexpr int Mask = Capacity - 1;

	QElapsedTimer mClock;
	std::array<Sample, Capacity> mSamples{};
	int mHead = 0;
	int mCount = 0;
	int mWindowMs = 60;
	qreal mVx = 0;
	qreal mVy = 0;
	qreal mLastX = 0;
	qreal mLastY = 0;
};
