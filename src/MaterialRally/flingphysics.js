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
