pragma ComponentBehavior: Bound

import QtQml
import QtQuick as T
import "./private" as RallyPrivate
import "flingphysics.js" as FlingPhysics


/*!
    \qmltype Flickable
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief A panning/flicking container built entirely on Qt Quick Input Handlers.

    Rally.Flickable is a drop-in-familiar replacement for QtQuick's Flickable, built only with
    DragHandler and WheelHandler (no MouseArea). Content is panned by dragging and decelerates
    naturally after a flick. Dragging past a bound never moves the content - instead an
    Android-style edge-glow indicator appears and fades back.

    Nested Rally.Flickable items do not fight over the pointer grab: each instance only enables
    the drag axis/axes it actually scrolls (via flickableDirection), so an inner Flickable
    scrolling a different axis than its ancestor simply never grabs drags meant for the ancestor.
    Cooperative hand-off between two same-axis nested Flickables (e.g. a list inside a list) is
    not implemented yet - the inner one simply stops consuming further drag at its own bounds.
*/
T.Item {

    id: control

    clip: true

    /*!
      The content children of this Flickable. This is the default property.
    */
    default
    property
        list < QtObject > flickableChildren

    property real contentX: 0
    property real contentY: 0
    property real contentWidth: width
    property real contentHeight: height

    property bool interactive: true

    /*!
      \qmlproperty bool Flickable::synchronousDrag
      \default true

      When true, the finger travel that was consumed getting past \l {DragHandler::}{dragThreshold}
      is replayed as soon as the drag activates, so the content sits under the finger from the very
      first frame it moves. When false, that travel is discarded and the content trails the finger
      by the threshold distance for the whole gesture - which reads as input lag. Mirrors the
      property of the same name on QtQuick's Flickable, which ScrollView already opts into.
    */
    property bool synchronousDrag: true

    /*!
      \qmlproperty int Flickable::dragThreshold
      \default 8

      How far, in px, a finger must travel before a drag starts. Below it the press is left
      entirely to whatever is underneath, so a tap on a control inside the content still works.
      This is the dead zone at the start of a gesture: nothing moves until it is crossed (with
      \l synchronousDrag the travel is then replayed, so it costs no offset - only the delay
      before movement begins).

      Deliberately 8 rather than Qt's Qt.styleHints.startDragDistance, which is a generic
      hardcoded 10 on every platform: QAndroidPlatformIntegration::styleHint() does not handle
      StartDragDistance, so it falls through to QPlatformTheme::defaultThemeHint()'s QVariant(10).
      Since Qt's Android HiDPI scaling makes 1 logical px behave as 1 dp, that is a 25% wider dead
      zone than native Android, whose ViewConfiguration touch slop is 8dp - which is why scrolling
      felt less immediate here than in an Android app. 8 matches the platform we take the rest of
      our fling physics from.

      Set to -1 to fall back to Qt.styleHints.startDragDistance, or raise it if content with small
      tap targets is picking up accidental scrolls.
    */
    property int dragThreshold: 8

    /*!
      \qmlproperty int Flickable::flickableDirection
      \default Flickable.VerticalFlick

      One of Flickable.HorizontalFlick, Flickable.VerticalFlick or Flickable.HorizontalAndVerticalFlick.
    */
    property int flickableDirection: T.Flickable.VerticalFlick

    /*!
      Velocity, in px/s, is clamped to this before computing the fling - matches Android's
      ViewConfiguration.getScaledMaximumFlingVelocity() acting as a safety cap.
    */
    property real maximumFlickVelocity: 9000

    /*!
      \qmlproperty real Flickable::flingFriction
      \default 0.0075

      Together with \l flingPhysicalCoefficient this drives the fling's exponential spline
      deceleration (see android.widget.OverScroller.SplineOverScroller) - higher friction means a
      shorter, more damped fling. Android's own literal ViewConfiguration.getScrollFriction()
      value is 0.015, but on-device testing with real touch-release velocities (logged via
      DragHandler.centroid.velocity, typically 600-2000 px/s for an ordinary swipe) showed that,
      combined with our baseline-density flingPhysicalCoefficient, 0.015 produced flings that were
      mathematically consistent with the formula but felt far too short/abrupt - most ordinary
      swipes only travelled 50-300px over well under a second. Halving it roughly doubles travel
      distance for the same gesture; treat this as a feel-tuning knob, not a physical constant to
      preserve exactly.
    */
    property real flingFriction: 0.0055

    /*!
      \qmlproperty real Flickable::flingPhysicalCoefficient

      Matches Android's OverScroller.computeDeceleration(0.84f): gravity * inches-per-meter *
      ppi * 0.84. Deliberately uses a fixed baseline ppi (160, Android's "mdpi"/density-1.0
      reference) rather than the screen's real physical density: contentX/contentY and the
      DragHandler velocity this drives the fling from are already in Qt's device-independent
      logical-pixel space (Qt's own HiDPI scaling means 1 QML px behaves like 1 Android dp, not
      1 raw physical pixel), so plugging in the real Screen.pixelDensity here would double-count
      that scaling - it made flings on a real ~400+ppi phone travel a fraction of the intended
      distance and stop almost immediately.
    */
    property real flingPhysicalCoefficient: 9.80665 * 39.37 * 160 * 0.84

    /*!
      Amount, in px, scrolled per classic (non-high-resolution) mouse wheel notch.
    */
    property real wheelStepSize: 60

    /*!
      \qmlproperty enumeration Flickable::boundsBehavior
      \default Flickable.StopAtBounds

      Mirrors QtQuick.Flickable. Only Flickable.StopAtBounds and Flickable.DragOverBounds are
      honoured - Flickable.OvershootBounds (a *fling* carrying past a bound) is not implemented,
      and a fling always stops at the bound and hands its residual energy to the EdgeGlow's
      absorb(). That matches stock's behaviour under DragOverBounds, where overShootDistance() is
      only consulted when OvershootBounds is set.

      Under DragOverBounds the drag past a bound is damped to exactly half the finger displacement,
      the same flat factor stock uses (qquickflickable.cpp, QQuickFlickablePrivate::drag()) - not
      an asymptotic rubber band.
    */
    property int boundsBehavior: T.Flickable.StopAtBounds

    /*!
      \qmlproperty enumeration Flickable::boundsMovement
      \default Flickable.StopAtBounds

      Mirrors QtQuick.Flickable. Flickable.StopAtBounds keeps contentX/contentY clamped to the
      content extents at all times and reports the overscroll only through \l horizontalOvershoot /
      \l verticalOvershoot, so the owner can render the overscroll itself (Rally.ScrollView squashes
      its content with a Scale transform). Flickable.FollowBoundsBehavior instead moves the content
      itself past the bound.
    */
    property int boundsMovement: T.Flickable.StopAtBounds

    /*!
      Set false to suppress the four EdgeGlow indicators - e.g. when the owner draws its own
      overscroll feedback from \l verticalOvershoot and would otherwise get both.
    */
    property bool overscrollGlow: true

    /*!
      \qmlproperty real Flickable::horizontalOvershoot

      How far, in px, the content has been dragged past a horizontal bound: negative past the
      beginning, positive past the end, 0 otherwise. Same sign convention and magnitude as
      QtQuick.Flickable. Always 0 unless \l boundsBehavior includes Flickable.DragOverBounds.
    */
    readonly property real horizontalOvershoot: control._overshootX

    /*!
      \qmlproperty real Flickable::verticalOvershoot

      The vertical counterpart of \l horizontalOvershoot.
    */
    readonly property real verticalOvershoot: control._overshootY

    // Not readonly: the rebound animations below drive these. Deliberately not named with a
    // leading underscore - QML would then expect on_ReboundingChanged handlers.
    property bool reboundingHorizontally: false
    property bool reboundingVertically: false
    readonly property bool rebounding: reboundingHorizontally || reboundingVertically

    readonly property bool atXBeginning: contentX <= 0
    readonly property bool atXEnd: contentX >= control._maxContentX
    readonly property bool atYBeginning: contentY <= 0
    readonly property bool atYEnd: contentY >= control._maxContentY

    readonly property bool draggingHorizontally: dragHandler.active && control._dragAxis !== "y"
        && control._canFlickX
    readonly property bool draggingVertically: dragHandler.active && control._dragAxis !== "x"
        && control._canFlickY
    readonly property bool dragging: draggingHorizontally || draggingVertically

    readonly property bool flickingHorizontally: flickTicker.flingAxis === T.Flickable.HorizontalFlick
    readonly property bool flickingVertically: flickTicker.flingAxis === T.Flickable.VerticalFlick
    readonly property bool flicking: flickingHorizontally || flickingVertically

    // The rebound term matters: stock's moving stays true through the 400 ms settle back from an
    // overshoot (it only ends at timelineCompleted -> movementEnding()), even though flicking is
    // false there - fixup() never emits flickingStarted().
    readonly property bool movingHorizontally: draggingHorizontally || flickingHorizontally
        || reboundingHorizontally
    readonly property bool movingVertically: draggingVertically || flickingVertically
        || reboundingVertically
    readonly property bool moving: movingHorizontally || movingVertically

        signal
    movementStarted
        signal
    movementEnded
        signal
    dragStarted
        signal
    dragEnded
        signal
    flickStarted
        signal
    flickEnded

    property string _dragAxis: ""
    property real _axisAccumX: 0
    property real _axisAccumY: 0
    property bool _wasMoving: false

    // Hoisted out of the per-touch-move path. Each of these used to be recomputed on every drag
    // update - a handler property read, two enum lookups through the QtQuick namespace, and three
    // separate copies of the same Math.max - even though they only change on a resize or a
    // flickableDirection change. Reading dragHandler.dragThreshold rather than
    // Qt.styleHints.startDragDistance keeps this in step with the handler that actually gates the
    // gesture, including when a caller overrides it.
    readonly property real _dragThreshold: dragHandler.dragThreshold
    readonly property bool _canFlickX: (flickableDirection & T.Flickable.HorizontalFlick) !== 0
    readonly property bool _canFlickY: (flickableDirection & T.Flickable.VerticalFlick) !== 0
    readonly property real _maxContentX: Math.max(0, contentWidth - width)
    readonly property real _maxContentY: Math.max(0, contentHeight - height)
    // An axis this Flickable both may and can scroll along. Along any other axis it leaves drags
    // and wheel events to the Flickable around it, as if it were plain content - see dragHandler's
    // xAxis/yAxis and wheelHandler.enabled.
    readonly property bool _scrollableX: _canFlickX && _maxContentX > 0
    readonly property bool _scrollableY: _canFlickY && _maxContentY > 0
    readonly property bool _dragOverBounds: (boundsBehavior & T.Flickable.DragOverBounds) !== 0
    readonly property bool _followBounds: boundsMovement === T.Flickable.FollowBoundsBehavior

    // Unclamped, pre-damping, absolute drag position. The damping has to be recomputed from the
    // absolute value on every touch sample rather than applied to each delta - that is what makes
    // the gesture exactly reversible (drag out, drag back, and you land on the bound again), and
    // it is what stock does: newY is pressPos + total finger displacement, damped afterwards.
    property real _rawContentX: 0
    property real _rawContentY: 0
    property real _overshootX: 0
    property real _overshootY: 0
    property real _reboundMidX: 0
    property real _reboundMidY: 0

    onDraggingChanged: {
        if (dragging)
            control.dragStarted()
        else
            control.dragEnded()
        control._updateMovementSignal()
    }

    onFlickingChanged: {
        if (flicking)
            control.flickStarted()
        else
            control.flickEnded()
        control._updateMovementSignal()
    }

    onReboundingChanged: control._updateMovementSignal()

    onOverscrollGlowChanged: {
        if (!control.overscrollGlow)
            control._releaseOverscroll()
    }

    function _updateMovementSignal() {
        var isMoving = control.dragging || control.flicking || control.rebounding
        if (isMoving === control._wasMoving)
            return
        control._wasMoving = isMoving
        if (isMoving)
            control.movementStarted()
        else
            control.movementEnded()
    }

    function _clamp(value: real, min: real, max: real): real {
        return Math.max(min, Math.min(value, max))
    }

    function _applyDrag(dx: real, dy: real) {
        if (control.flickableDirection === T.Flickable.HorizontalAndVerticalFlick && control._dragAxis === "") {
            control._axisAccumX += dx
            control._axisAccumY += dy
            const ax = control._axisAccumX
            const ay = control._axisAccumY
            const thr = control._dragThreshold
            // Squared compare: Math.hypot is a slow generic (it guards against intermediate
            // over/underflow we cannot hit here), and this runs on every touch move.
            //
            // With synchronousDrag this threshold is already satisfied by the very first call:
            // dragHandler replays the travel that got it past its own (identical) drag threshold,
            // so the axis locks and the content moves on the first frame instead of waiting for a
            // second, additive dead zone. With synchronousDrag false the old behaviour stands.
            if (ax * ax + ay * ay < thr * thr)
                return
            control._dragAxis = Math.abs(ax) >= Math.abs(ay) ? "x" : "y"
            dx = ax
            dy = ay
        }
        if (control._dragAxis === "x")
            dy = 0
        else if (control._dragAxis === "y")
            dx = 0
        control._moveContent(dx, dy)
    }

    function _moveContent(dx: real, dy: real) {
        if (dx !== 0 && control._canFlickX) {
            const rawX = control._rawContentX - dx
            control._rawContentX = rawX
            const maxX = control._maxContentX
            let dampedX = rawX
            if (control._dragOverBounds) {
                // Flat 50% of the finger displacement past the bound - stock's exact factor, see
                // boundsBehavior. Not an asymptotic curve: stock never saturates.
                if (rawX < 0)
                    dampedX = rawX * 0.5
                else if (rawX > maxX)
                    dampedX = maxX + (rawX - maxX) * 0.5
            }
            const clampedX = control._clamp(dampedX, 0, maxX)
            const overX = dampedX - clampedX
            control.contentX = control._followBounds ? dampedX : clampedX
            control._overshootX = control._dragOverBounds ? overX : 0
            control._updateOverscrollX(overX)
        }
        if (dy !== 0 && control._canFlickY) {
            const rawY = control._rawContentY - dy
            control._rawContentY = rawY
            const maxY = control._maxContentY
            let dampedY = rawY
            if (control._dragOverBounds) {
                if (rawY < 0)
                    dampedY = rawY * 0.5
                else if (rawY > maxY)
                    dampedY = maxY + (rawY - maxY) * 0.5
            }
            const clampedY = control._clamp(dampedY, 0, maxY)
            const overY = dampedY - clampedY
            control.contentY = control._followBounds ? dampedY : clampedY
            control._overshootY = control._dragOverBounds ? overY : 0
            control._updateOverscrollY(overY)
        }
    }

    function _updateOverscrollX(overPx: real) {
        if (!control.overscrollGlow)
            return
        const extent = Math.max(1, control.width)
        // Pulling one edge releases the opposite one, as Android's ScrollView does. The
        // overPx === 0 case releases both: dragging back inside the bounds while still holding
        // otherwise left the glow lit at whatever value it last reached, until the finger lifted.
        // release() only acts on a glow that is being pulled, so this leaves a glow that is still
        // receding from an earlier gesture (or absorbing a fling) alone.
        if (overPx > 0) {
            leftGlow.release()
            rightGlow.setPull(Math.min(1, Math.sqrt(overPx / (extent * 0.5))))
        } else if (overPx < 0) {
            rightGlow.release()
            leftGlow.setPull(Math.min(1, Math.sqrt(-overPx / (extent * 0.5))))
        } else {
            leftGlow.release()
            rightGlow.release()
        }
    }

    function _updateOverscrollY(overPx: real) {
        if (!control.overscrollGlow)
            return
        const extent = Math.max(1, control.height)
        // See _updateOverscrollX for why the zero case is handled explicitly.
        if (overPx > 0) {
            topGlow.release()
            bottomGlow.setPull(Math.min(1, Math.sqrt(overPx / (extent * 0.5))))
        } else if (overPx < 0) {
            bottomGlow.release()
            topGlow.setPull(Math.min(1, Math.sqrt(-overPx / (extent * 0.5))))
        } else {
            topGlow.release()
            bottomGlow.release()
        }
    }

    function _releaseOverscroll() {
        topGlow.release()
        bottomGlow.release()
        leftGlow.release()
        rightGlow.release()
    }

    function _startFling(vx: real, vy: real) {
        const allowX = control._canFlickX && control._dragAxis !== "y"
        const allowY = control._canFlickY && control._dragAxis !== "x"
        if (allowX && allowY) {
            // Combined direction, released before the axis-lock threshold was ever crossed -
            // pick whichever axis had the dominant velocity rather than flinging both at once
            // (only one axis can fling at a time - see flickTicker).
            if (Math.abs(vx) >= Math.abs(vy))
                control._beginFling(T.Flickable.HorizontalFlick, vx, "contentX", "width", "contentWidth", leftGlow, rightGlow)
            else
                control._beginFling(T.Flickable.VerticalFlick, vy, "contentY", "height", "contentHeight", topGlow, bottomGlow)
        } else if (allowX) {
            control._beginFling(T.Flickable.HorizontalFlick, vx, "contentX", "width", "contentWidth", leftGlow, rightGlow)
        } else if (allowY) {
            control._beginFling(T.Flickable.VerticalFlick, vy, "contentY", "height", "contentHeight", topGlow, bottomGlow)
        }
    }

    function _beginFling(axis, v, contentProp, sizeProp, contentSizeProp, beginGlow, endGlow) {
        if (Math.abs(v) < 30)
            return
        const vel = control._clamp(v, -control.maximumFlickVelocity, control.maximumFlickVelocity)
        let dist = FlingPhysics.flingDistance(vel, control.flingFriction, control.flingPhysicalCoefficient)
        let duration = FlingPhysics.flingDuration(vel, control.flingFriction, control.flingPhysicalCoefficient)
        if (dist <= 0 || duration <= 0)
            return
        // content follows the finger, so positive pointer velocity moves content the same way
        // drag deltas do: contentX/Y decreases - see _moveContent.
        dist = vel < 0 ? -dist : dist

        const maxValue = Math.max(0, control[contentSizeProp] - control[sizeProp])
        const rawTarget = control[contentProp] - dist
        const target = control._clamp(rawTarget, 0, maxValue)
        // Already at the bound this fling points towards: nothing to fling. Starting one anyway
        // ran a zero-duration fling whose single frame fired the absorb glow, right after the glow
        // pulled by the drag had receded - the edge indicator showed up twice. Android's
        // ScrollView doesn't fling here either (flingWithNestedDispatch's canFling).
        if (target === control[contentProp])
            return

        // If the bound clips the target short of the full computed distance, shorten the
        // duration by the same fraction. Our curve's shape only depends on distance/duration
        // (see splineProgress), so scaling both by the same factor keeps the animation starting
        // at the correct measured release velocity and just settles at the bound sooner - rather
        // than keeping the full original duration and crawling the much-shorter remaining
        // distance for many extra seconds (visible on real devices as content appearing to grind
        // to a near-halt right as it should be flying to the edge).
        if (target !== rawTarget) {
            const travelled = Math.abs(target - control[contentProp])
            const durationFraction = Math.abs(dist) > 0 ? Math.min(1, travelled / Math.abs(dist)) : 0
            duration = duration * durationFraction
        }

        flickTicker.flingAxis = axis
        flickTicker.flingStartValue = control[contentProp]
        flickTicker.flingTargetValue = target
        flickTicker.flingDurationMs = duration

        if (target !== rawTarget) {
            const clipped = Math.abs(rawTarget - target)
            flickTicker.flingAbsorbFraction = Math.min(1, Math.sqrt(clipped / Math.max(1, Math.abs(dist))))
            flickTicker.flingAbsorbGlow = control.overscrollGlow ? (rawTarget > target ? endGlow : beginGlow) : null
        } else {
            flickTicker.flingAbsorbGlow = null
        }

        // running is driven entirely by the `flingAxis !== 0` binding below; reset() only
        // zeroes elapsedTime/currentFrame (explicitly independent of running per its docs) so a
        // fresh fling starting while the ticker is already running (e.g. re-flicking mid-fling)
        // still gets a clean 0-based timeline.
        flickTicker.reset()
    }

    function _cancelFling() {
        flickTicker.flingAxis = 0
        flickTicker.flingAbsorbGlow = null
    }

    // Stock's rebound: adjustContentPos() with the default (null) rebound transition runs
    // timeline.move(toPos - dist/2, InQuad, fixupDuration/4) then
    // timeline.move(toPos, OutExpo, 3*fixupDuration/4), with fixupDuration = 400. So: 100 ms
    // InQuad to the midpoint, 300 ms OutExpo to the bound.
    function _startReboundX() {
        if (control._overshootX === 0) {
            control.reboundingHorizontally = false
            return
        }
        control._reboundMidX = control._overshootX / 2
        control.reboundingHorizontally = true
        reboundX.restart()
    }

    function _startReboundY() {
        if (control._overshootY === 0) {
            control.reboundingVertically = false
            return
        }
        control._reboundMidY = control._overshootY / 2
        control.reboundingVertically = true
        reboundY.restart()
    }

    function _cancelRebound() {
        reboundX.stop()
        reboundY.stop()
        control.reboundingHorizontally = false
        control.reboundingVertically = false
    }

    /*!
      Stops any running fling or overscroll rebound. Call this before writing contentX/contentY
      from outside, so the write isn't immediately overwritten by the fling ticker on the next
      frame - stock's setContentX/setContentY call resetTimeline() for the same reason.
    */
    function cancelFlick() {
        control._cancelFling()
        control._cancelRebound()
    }

    function _wheelStep(dx: real, dy: real, animate: bool) {
        // Wheel input drives contentX/contentY directly (or via wheelAnimX/Y below); make sure it
        // isn't fighting a still-running touch-originated fling or rebound over the same
        // properties. Zeroing the overshoot keeps a wheel event mid-rebound from freezing the
        // owner's stretch at whatever value the rebound had reached.
        control._cancelFling()
        control._cancelRebound()
        control._overshootX = 0
        control._overshootY = 0
        const targetX = control._clamp(control.contentX + dx, 0, control._maxContentX)
        const targetY = control._clamp(control.contentY + dy, 0, control._maxContentY)
        if (animate) {
            if (targetX !== control.contentX) {
                wheelAnimX.stop()
                wheelAnimX.to = targetX
                wheelAnimX.start()
            }
            if (targetY !== control.contentY) {
                wheelAnimY.stop()
                wheelAnimY.to = targetY
                wheelAnimY.start()
            }
        } else {
            control.contentX = targetX
            control.contentY = targetY
        }
    }

    T.Item {

        id: contentItem

        x: -control.contentX
        y: -control.contentY
        width: control.contentWidth
        height: control.contentHeight

        data: control.flickableChildren
    }

    // These stay direct children rather than Loader-gated on flickableDirection. Gating would save
    // instantiating the two glows a single-axis Flickable can never show, but it puts the glows
    // behind Loader.item, which is typed QObject - and that is enough to knock _updateOverscrollX/Y
    // and _releaseOverscroll out of qmlcachegen's AOT compilation (verified via
    // QT_QML_GENERATE_AOT_STATS). Those run on every touch move, so keeping them compiled is worth
    // far more than two idle items. An idle EdgeGlow is `visible: false`, so it holds no layer FBO.

    RallyPrivate.EdgeGlow {
        id: topGlow
        edge: Qt.TopEdge
        anchors.left: control.left
        anchors.right: control.right
        anchors.top: control.top
        height: 64
    }

    RallyPrivate.EdgeGlow {
        id: bottomGlow
        edge: Qt.BottomEdge
        anchors.left: control.left
        anchors.right: control.right
        anchors.bottom: control.bottom
        height: 64
    }

    RallyPrivate.EdgeGlow {
        id: leftGlow
        edge: Qt.LeftEdge
        anchors.top: control.top
        anchors.bottom: control.bottom
        anchors.left: control.left
        width: 64
    }

    RallyPrivate.EdgeGlow {
        id: rightGlow
        edge: Qt.RightEdge
        anchors.top: control.top
        anchors.bottom: control.bottom
        anchors.right: control.right
        width: 64
    }

    T.DragHandler {

        id: dragHandler

        target: null
        enabled: control.interactive
        // Mouse/touchpad users only scroll via the wheel (see wheelHandler below) - dragging to
        // pan/flick is a touch (and stylus) gesture only. This is a hard device-type exclusion,
        // not the Rally.RootItem.isTouchInput heuristic (which tracks "which input was used
        // most recently" and can lag/misfire); acceptedDevices is deterministic per-gesture.
        acceptedDevices: T.PointerDevice.AllDevices & ~T.PointerDevice.Mouse & ~T.PointerDevice.TouchPad
        // A negative value is how QQuickPointerHandler spells "use the style hint", so
        // dragThreshold: -1 on the Flickable falls back to Qt.styleHints.startDragDistance.
        dragThreshold: control.dragThreshold
        // Once dragging, keep the gesture: approve a takeover only by an Item (Controls popups and
        // drawers rely on that) or a cancellation, never by another pointer handler. Qt's default
        // approves anything, and its "different type" check compares metaObject class names - every
        // QML-declared handler with its own properties is a distinct subclass, so e.g. a nested
        // Rally.SwipeView counted as a different type and stole a vertical drag as soon as the
        // finger's total travel became mostly horizontal. Matches Android, where a scroll
        // container that has claimed a gesture keeps it. While not dragging the handler only
        // holds a passive grab, so this has no say in which handler wins the gesture.
        grabPermissions: T.PointerHandler.CanTakeOverFromItems | T.PointerHandler.CanTakeOverFromHandlersOfDifferentType
                         | T.PointerHandler.ApprovesTakeOverByItems | T.PointerHandler.ApprovesCancellation
        // Only claim a drag along an axis that has something to scroll. Otherwise a nested
        // Flickable whose content fits swallowed the drag and nothing moved; now the drag is left
        // to the Flickable around it, as if this one were plain content. Matches Android, where a
        // ScrollView that cannot scroll never intercepts a drag (and a NestedScrollView passes the
        // whole, unconsumed scroll on to its parent). QQuickDragHandler also refuses to activate
        // for a drag that is mostly along a disabled axis, so this decides the axis, not just the
        // movement.
        xAxis.enabled: control._scrollableX
        yAxis.enabled: control._scrollableY

        // Allocated once. Recording a sample allocates nothing, which matters because it happens
        // on every touch move. Shared with Rally.SwipeView - see FlingPhysics.VelocityTracker
        // for why Qt's own centroid.velocity is not used.
        readonly property var _tracker: new FlingPhysics.VelocityTracker(60)

        onActiveChanged: {
            if (dragHandler.active) {
                dragHandler._tracker.reset()
                control._axisAccumX = 0
                control._axisAccumY = 0
                control._dragAxis = ""
                control._cancelFling()
                control._cancelRebound()

                // Seed from the *damped* position (contentX + overshoot), not from whatever raw
                // value a previous gesture left behind: stock's pressPos is move.value(), which is
                // post-damping. This is what makes grabbing mid-rebound continue from where the
                // content visually is.
                control._rawContentX = control.contentX + control._overshootX
                control._rawContentY = control.contentY + control._overshootY

                // DragHandler only activates once the pointer has passed dragThreshold. With
                // synchronousDrag that travel is replayed right here, which both keeps the content
                // under the finger and hands _applyDrag enough displacement to lock the drag axis on
                // the first frame instead of accumulating towards a second, additive dead zone.
                // Without it, the travel so far counts as already applied and is thrown away.
                dragHandler._appliedX = control.synchronousDrag ? 0 : dragHandler._travelX()
                dragHandler._appliedY = control.synchronousDrag ? 0 : dragHandler._travelY()
                dragHandler._applyTravel()
            } else {
                const tr = dragHandler._tracker
                tr.compute()
                const overX = control._overshootX !== 0
                const overY = control._overshootY !== 0
                // Releasing from an overshoot rebounds instead of flinging. Letting _startFling run
                // here would also hit a bad edge: contentX/contentY is pinned at the bound, so
                // target === current, travelled === 0, flingDurationMs === 0, and the ticker fires
                // once at t >= 1 - a one-frame `flicking` blip plus a spurious glow.absorb().
                if (overX)
                    control._startReboundX()
                if (overY)
                    control._startReboundY()
                if (!overX && !overY)
                    control._startFling(tr.vx, tr.vy)
                control._releaseOverscroll()
            }
        }

        // Travel is measured from the centroid rather than from activeTranslation, whose origin
        // is version-dependent: Qt 6.11 measures it from the press position but only starts
        // updating it on the move *after* activation, so replaying the threshold travel and then
        // applying activeTranslation deltas counted that travel twice. Scene coordinates are
        // deliberate - centroid.position is relative to the handler's parent item, which for a
        // nested Flickable moves with the outer content.
        //
        // The origin is _anchorX/_anchorY (see onCentroidChanged), not centroid.scenePressPosition:
        // QQuickHandlerPoint only records a press position when it sees the point in the Pressed
        // state. A handler can pick a finger up later - a second finger lands before the first
        // has started a drag, then the first lifts, and the handler switches to the second - and
        // scenePressPosition is then left at (0,0), which made the content jump by the finger's
        // whole scene position. activeTranslation derives from the same value, so it is no help.
        property real _appliedX: 0
        property real _appliedY: 0
        property int _anchorId: -1
        property real _anchorPressX: 0
        property real _anchorPressY: 0
        property real _anchorX: 0
        property real _anchorY: 0

        function _travelX(): real {
            return control._canFlickX ? dragHandler.centroid.scenePosition.x - dragHandler._anchorX : 0
        }

        function _travelY(): real {
            return control._canFlickY ? dragHandler.centroid.scenePosition.y - dragHandler._anchorY : 0
        }

        // Applies whatever finger travel since press has not been applied yet.
        function _applyTravel() {
            const tx = dragHandler._travelX()
            const ty = dragHandler._travelY()
            const dx = tx - dragHandler._appliedX
            const dy = ty - dragHandler._appliedY
            dragHandler._appliedX = tx
            dragHandler._appliedY = ty
            dragHandler._tracker.record(tx, ty)
            if (dx !== 0 || dy !== 0)
                control._applyDrag(dx, dy)
        }

        onActiveTranslationChanged: dragHandler._applyTravel()

        // Stops an in-flight fling as soon as a finger goes down, before the drag threshold is
        // crossed - the "lay your finger on it to catch the scroll" gesture.
        //
        // This has to hang off the DragHandler rather than a TapHandler, even though a TapHandler
        // reads better. QQuickSinglePointHandler::wantsPointerEvent() (which TapHandler inherits)
        // skips any point that already has an exclusive grabber:
        //
        //     if (!event->exclusiveGrabber(p) && wantsEventPoint(event, p))
        //
        // with no grab-permission negotiation at all. So as soon as this Flickable has a
        // descendant that grabs on press - a stock Flickable/ListView, as inside the Gallery's
        // SwipeView - the TapHandler silently never sees the press and the fling ran on
        // unstoppable. QQuickMultiPointHandler::eligiblePoints() (DragHandler's base) instead
        // rejects a grabbed point only when !canGrab(), i.e. it consults grabPermissions, which is
        // exactly why dragging kept working in the very same place.
        //
        // The centroid is a straight copy of the single point (DragHandler is min/max 1), so its
        // id is the live point id while tracking and -1 once reset. The guard matters on release:
        // wantsPointerEvent() calls setActive(false) - which is what starts the fling - *before*
        // centroid.reset() emits centroidChanged(), so without it we would cancel the fling we
        // had just started.
        //
        // Only the fling is cancelled, not a running rebound: a rebound is driven by _overshootY,
        // and stopping it on press with no matching release signal (this fires before the handler
        // is active, so onActiveChanged may never run) would strand the owner's stretch.
        //
        // It also anchors the travel measurement (see _travelX) at the first scene position seen
        // for a point: its press position for a normal press, and where the finger was at the
        // hand-over for a finger picked up late. A new point is recognised by its id changing or
        // by its press position changing - ids are reused from one gesture to the next, and a
        // handler that never activated keeps the previous gesture's id in its centroid. A finger
        // picked up late changes only the id, since its press position is never updated.
        // centroidChanged is emitted before the handler activates and before activeTranslation
        // changes, so the anchor is always set in time.
        onCentroidChanged: {
            const c = dragHandler.centroid
            const p = c.scenePressPosition
            if (c.id !== dragHandler._anchorId || p.x !== dragHandler._anchorPressX || p.y !== dragHandler._anchorPressY) {
                dragHandler._anchorId = c.id
                dragHandler._anchorPressX = p.x
                dragHandler._anchorPressY = p.y
                dragHandler._anchorX = c.scenePosition.x
                dragHandler._anchorY = c.scenePosition.y
            }
            if (flickTicker.flingAxis !== 0 && c.id !== -1)
                control._cancelFling()
        }
    }

    // NB: tap-to-stop-a-fling used to live in a TapHandler here. It is now dragHandler's
    // onCentroidChanged - see the comment there for why a TapHandler cannot do this job once the
    // Flickable has a descendant that grabs on press.

    T.WheelHandler {

        id: wheelHandler

        target: null
        // Same rule as dragHandler's axes: with nothing to scroll, the wheel is left to the
        // Flickable around it (as on Android, where a ScrollView that cannot move passes the scroll
        // on). This has to be decided before the event arrives - the handler's `blocking` marks the
        // event accepted before onWheel runs, and Qt never reads onWheel's event.accepted back.
        enabled: control.interactive && (control._scrollableX || control._scrollableY)
        acceptedDevices: T.PointerDevice.Mouse | T.PointerDevice.TouchPad

        onWheel: (event) => {
            var dx, dy
            if (event.pixelDelta.x !== 0 || event.pixelDelta.y !== 0) {
                dx = -event.pixelDelta.x
                dy = -event.pixelDelta.y
                control._wheelStep(dx, dy, false)
            } else {
                dx = -(event.angleDelta.x / 120) * control.wheelStepSize
                dy = -(event.angleDelta.y / 120) * control.wheelStepSize
                control._wheelStep(dx, dy, true)
            }
            event.accepted = true
        }
    }

    // Drives the fling per-frame from FlingPhysics.splineProgress(), the same lookup-table
    // curve android.widget.OverScroller.SplineOverScroller.update() samples every frame - a
    // fixed easing curve (e.g. NumberAnimation + Easing.OutQuad) can't reproduce this shape.
    T.FrameAnimation {

        id: flickTicker

        // flingAxis reuses Flickable's own direction flags: 0 = idle, HorizontalFlick = x,
        // VerticalFlick = y. It was a string, compared twice per frame; an int also keeps this
        // handler AOT-compilable. Likewise the absorb payload, which used to be an object literal
        // allocated per bound-clipped fling and stored in a `property var` - reading fields off it
        // was enough on its own to force this per-frame handler back into the interpreter.
        property int flingAxis: 0
        property real flingStartValue: 0
        property real flingTargetValue: 0
        property real flingDurationMs: 0
        property RallyPrivate.EdgeGlow flingAbsorbGlow: null
        property real flingAbsorbFraction: 0

        running: flingAxis !== 0

        onTriggered: {
            const t = flickTicker.flingDurationMs > 0
                ? Math.min(1, flickTicker.elapsedTime * 1000 / flickTicker.flingDurationMs) : 1
            const progress = FlingPhysics.splineProgress(t)
            const value = flickTicker.flingStartValue
                + progress * (flickTicker.flingTargetValue - flickTicker.flingStartValue)

            if (flickTicker.flingAxis === T.Flickable.HorizontalFlick)
                control.contentX = value
            else if (flickTicker.flingAxis === T.Flickable.VerticalFlick)
                control.contentY = value

            if (t >= 1) {
                const glow = flickTicker.flingAbsorbGlow
                const fraction = flickTicker.flingAbsorbFraction
                flickTicker.flingAxis = 0
                flickTicker.flingAbsorbGlow = null
                if (glow)
                    glow.absorb(fraction)
            }
        }
    }

    // Mirrors stock's two-stage fixup timeline exactly - see _startReboundY.
    T.SequentialAnimation {
        id: reboundX
        T.NumberAnimation {
            target: control
            property: "_overshootX"
            to: control._reboundMidX
            duration: 100
            easing.type: T.Easing.InQuad
        }
        T.NumberAnimation {
            target: control
            property: "_overshootX"
            to: 0
            duration: 300
            easing.type: T.Easing.OutExpo
        }
        onStopped: control.reboundingHorizontally = false
    }

    T.SequentialAnimation {
        id: reboundY
        T.NumberAnimation {
            target: control
            property: "_overshootY"
            to: control._reboundMidY
            duration: 100
            easing.type: T.Easing.InQuad
        }
        T.NumberAnimation {
            target: control
            property: "_overshootY"
            to: 0
            duration: 300
            easing.type: T.Easing.OutExpo
        }
        onStopped: control.reboundingVertically = false
    }

    T.NumberAnimation {
        id: wheelAnimX
        target: control
        property: "contentX"
        duration: 100
        easing.type: T.Easing.OutQuad
    }

    T.NumberAnimation {
        id: wheelAnimY
        target: control
        property: "contentY"
        duration: 100
        easing.type: T.Easing.OutQuad
    }
}
