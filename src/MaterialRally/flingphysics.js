.pragma library

// Based on android.widget.OverScroller.SplineOverScroller's fling physics (AOSP,
// frameworks/base/core/java/android/widget/OverScroller.java). Android's fling distance and
// duration are NOT a constant-deceleration curve - they come from a velocity-dependent
// exponential model, which is what makes a hard flick travel much further (not just faster)
// than a gentle one. flingDistance()/flingDuration() below are that same closed-form formula.
//
// The per-frame position curve (splineProgress) approximates Android's internal curve - which
// is built from an undocumented runtime lookup table we can't verify bit-for-bit here - with a
// power-ease-out curve, progress(t) = 1-(1-t)^n. Its exponent is chosen so the animation's
// starting speed exactly matches the release velocity (no perceptible jump/slowdown at the
// finger-lift handoff), not for stylistic reasons:
//
//   distance/duration_s always works out to INFLEXION*|v| (falls out of the flingDistance/
//   flingDuration formulas below), and progress'(0) for 1-(1-t)^n is just n, so the animation's
//   real initial velocity is n*INFLEXION*|v|. Setting n = 1/INFLEXION makes that equal |v|
//   exactly. (Using DECELERATION_RATE as the exponent here, as an earlier version of this file
//   did, undershoots to ~82.5% of the true release velocity - it *looked* like a plausible
//   "Android-ish" curve shape but wasn't derived from this continuity constraint.)

var DECELERATION_RATE = Math.log(0.78) / Math.log(0.9) // ~2.358, used by flingDistance/flingDuration
var INFLEXION = 0.35 // Where the velocity spline flattens
var PROGRESS_EXPONENT = 1.0 / INFLEXION // ~2.857, see derivation above

function splineDeceleration(velocity, friction, physicalCoeff) {
    return Math.log(INFLEXION * Math.abs(velocity) / (friction * physicalCoeff))
}

// Total (unsigned) distance in px the fling travels before naturally coming to rest.
function flingDistance(velocity, friction, physicalCoeff) {
    if (velocity === 0)
        return 0
    var l = splineDeceleration(velocity, friction, physicalCoeff)
    var decelMinusOne = DECELERATION_RATE - 1.0
    return friction * physicalCoeff * Math.exp(DECELERATION_RATE / decelMinusOne * l)
}

// Duration of the fling, in milliseconds.
function flingDuration(velocity, friction, physicalCoeff) {
    if (velocity === 0)
        return 0
    var l = splineDeceleration(velocity, friction, physicalCoeff)
    var decelMinusOne = DECELERATION_RATE - 1.0
    return 1000.0 * Math.exp(l / decelMinusOne)
}

// Given normalized elapsed time t (0..1), returns the normalized distance-fraction (0..1) the
// fling has covered so far. See file header for what this approximates and why.
function splineProgress(t) {
    if (t <= 0.0)
        return 0.0
    if (t >= 1.0)
        return 1.0
    return 1.0 - Math.pow(1.0 - t, PROGRESS_EXPONENT)
}

// Short rolling-window release-velocity tracker, shared by Rally.Flickable and Rally.SwipeView.
//
// Qt's own centroid.velocity is a smoothed estimate tuned for general pointer tracking, which
// systematically undershoots a real flick's release speed (a flick accelerates right up to the
// moment of release). This instead keeps raw (position, timestamp) samples over a short window
// and takes total displacement / elapsed time across it - responsive to the true recent motion
// without being as noisy as a single last-frame delta.
//
// Fixed-size ring buffer, allocated once per tracker and never resized: recording a sample must
// not allocate, because it happens on every touch move (a few hundred times a second on a
// high-rate digitiser). CAPACITY must stay a power of two for the `& MASK` wrap.
//
// Results are written to this.vx / this.vy rather than returned, so computing a velocity does
// not allocate either. Deliberately plain numbers and no Qt.* calls - a .pragma library script
// has no QML global object.
var VELOCITY_CAPACITY = 32
var VELOCITY_MASK = 31

function VelocityTracker(windowMs) {
    this.windowMs = (windowMs === undefined) ? 60 : windowMs
    this._x = new Float64Array(VELOCITY_CAPACITY)
    this._y = new Float64Array(VELOCITY_CAPACITY)
    this._t = new Float64Array(VELOCITY_CAPACITY)
    this._head = 0
    this._count = 0
    this.vx = 0
    this.vy = 0
    // The most recently recorded sample, so callers can take a per-move delta without keeping
    // their own copy of it (which, as a QML property, would emit a change signal every move).
    this.lastX = 0
    this.lastY = 0
}

VelocityTracker.prototype.reset = function () {
    this._head = 0
    this._count = 0
    this.vx = 0
    this.vy = 0
    this.lastX = 0
    this.lastY = 0
}

VelocityTracker.prototype.record = function (x, y, now) {
    var i = this._head
    this._x[i] = x
    this._y[i] = y
    this._t[i] = (now === undefined) ? Date.now() : now
    this._head = (i + 1) & VELOCITY_MASK
    if (this._count < VELOCITY_CAPACITY)
        this._count = this._count + 1
    this.lastX = x
    this.lastY = y
}

// Velocity is the total displacement over the oldest sample still within windowMs of the newest,
// or zero if there is no such second sample. At sample rates above ~530 Hz the oldest in-window
// samples are simply dropped, which slightly narrows the effective window but never yields a
// wrong velocity.
VelocityTracker.prototype.compute = function () {
    this.vx = 0
    this.vy = 0
    if (this._count < 2)
        return
    var newest = (this._head - 1) & VELOCITY_MASK
    var tNew = this._t[newest]
    var oldest = newest
    for (var k = 1; k < this._count; ++k) {
        var j = (newest - k) & VELOCITY_MASK
        if (tNew - this._t[j] > this.windowMs)
            break
        oldest = j
    }
    if (oldest === newest)
        return
    var dt = (tNew - this._t[oldest]) / 1000
    if (dt <= 0)
        return
    this.vx = (this._x[newest] - this._x[oldest]) / dt
    this.vy = (this._y[newest] - this._y[oldest]) / dt
}
