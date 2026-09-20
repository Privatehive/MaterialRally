import QtQml
import QtQuick as T
import MaterialRally as Rally
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

    readonly property bool atXBeginning: contentX <= 0
    readonly property bool atXEnd: contentX >= Math.max(0, contentWidth - width)
    readonly property bool atYBeginning: contentY <= 0
    readonly property bool atYEnd: contentY >= Math.max(0, contentHeight - height)

    readonly property bool draggingHorizontally: dragHandler.active && control._dragAxis !== "y"
        && (control.flickableDirection & T.Flickable.HorizontalFlick)
    readonly property bool draggingVertically: dragHandler.active && control._dragAxis !== "x"
        && (control.flickableDirection & T.Flickable.VerticalFlick)
    readonly property bool dragging: draggingHorizontally || draggingVertically

    readonly property bool flickingHorizontally: flickTicker.flingAxis === "x"
    readonly property bool flickingVertically: flickTicker.flingAxis === "y"
    readonly property bool flicking: flickingHorizontally || flickingVertically

    readonly property bool movingHorizontally: draggingHorizontally || flickingHorizontally
    readonly property bool movingVertically: draggingVertically || flickingVertically
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
    property var _pendingAbsorbX: null
    property var _pendingAbsorbY: null

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

    function _updateMovementSignal() {
        var isMoving = control.dragging || control.flicking
        if (isMoving === control._wasMoving)
            return
        control._wasMoving = isMoving
        if (isMoving)
            control.movementStarted()
        else
            control.movementEnded()
    }

    function _clamp(value, min, max) {
        return Math.max(min, Math.min(value, max))
    }

    function _applyDrag(dx, dy) {
        if (control.flickableDirection === T.Flickable.HorizontalAndVerticalFlick && control._dragAxis === "") {
            control._axisAccumX += dx
            control._axisAccumY += dy
            var threshold = Qt.styleHints ? Qt.styleHints.startDragDistance : 15
            if (Math.hypot(control._axisAccumX, control._axisAccumY) < threshold)
                return
            control._dragAxis = Math.abs(control._axisAccumX) >= Math.abs(control._axisAccumY) ? "x" : "y"
            dx = control._axisAccumX
            dy = control._axisAccumY
        }
        if (control._dragAxis === "x")
            dy = 0
        else if (control._dragAxis === "y")
            dx = 0
        control._moveContent(dx, dy)
    }

    function _moveContent(dx, dy) {
        if (dx !== 0 && (control.flickableDirection & T.Flickable.HorizontalFlick)) {
            var maxX = Math.max(0, control.contentWidth - control.width)
            var rawX = control.contentX - dx
            var clampedX = control._clamp(rawX, 0, maxX)
            control.contentX = clampedX
            control._updateOverscrollX(rawX - clampedX)
        }
        if (dy !== 0 && (control.flickableDirection & T.Flickable.VerticalFlick)) {
            var maxY = Math.max(0, control.contentHeight - control.height)
            var rawY = control.contentY - dy
            var clampedY = control._clamp(rawY, 0, maxY)
            control.contentY = clampedY
            control._updateOverscrollY(rawY - clampedY)
        }
    }

    function _updateOverscrollX(overPx) {
        var extent = Math.max(1, control.width)
        if (overPx > 0) {
            leftGlow.pull = 0
            rightGlow.pull = Math.min(1, Math.sqrt(overPx / (extent * 0.5)))
        } else if (overPx < 0) {
            rightGlow.pull = 0
            leftGlow.pull = Math.min(1, Math.sqrt(-overPx / (extent * 0.5)))
        }
    }

    function _updateOverscrollY(overPx) {
        var extent = Math.max(1, control.height)
        if (overPx > 0) {
            topGlow.pull = 0
            bottomGlow.pull = Math.min(1, Math.sqrt(overPx / (extent * 0.5)))
        } else if (overPx < 0) {
            bottomGlow.pull = 0
            topGlow.pull = Math.min(1, Math.sqrt(-overPx / (extent * 0.5)))
        }
    }

    function _releaseOverscroll() {
        topGlow.pull = 0
        bottomGlow.pull = 0
        leftGlow.pull = 0
        rightGlow.pull = 0
    }

    function _startFling(velocity) {
        var vx = velocity ? velocity.x : 0
        var vy = velocity ? velocity.y : 0
        var allowX = (control.flickableDirection & T.Flickable.HorizontalFlick) && control._dragAxis !== "y"
        var allowY = (control.flickableDirection & T.Flickable.VerticalFlick) && control._dragAxis !== "x"
        if (allowX && allowY) {
            // Combined direction, released before the axis-lock threshold was ever crossed -
            // pick whichever axis had the dominant velocity rather than flinging both at once
            // (only one axis can fling at a time - see flickTicker).
            if (Math.abs(vx) >= Math.abs(vy))
                control._beginFling("x", vx, "contentX", "width", "contentWidth", leftGlow, rightGlow)
            else
                control._beginFling("y", vy, "contentY", "height", "contentHeight", topGlow, bottomGlow)
        } else if (allowX) {
            control._beginFling("x", vx, "contentX", "width", "contentWidth", leftGlow, rightGlow)
        } else if (allowY) {
            control._beginFling("y", vy, "contentY", "height", "contentHeight", topGlow, bottomGlow)
        }
    }

    function _beginFling(axis, v, contentProp, sizeProp, contentSizeProp, beginGlow, endGlow) {
        if (Math.abs(v) < 30)
            return
        var vel = control._clamp(v, -control.maximumFlickVelocity, control.maximumFlickVelocity)
        var dist = FlingPhysics.flingDistance(vel, control.flingFriction, control.flingPhysicalCoefficient)
        var duration = FlingPhysics.flingDuration(vel, control.flingFriction, control.flingPhysicalCoefficient)
        if (dist <= 0 || duration <= 0)
            return
        // content follows the finger, so positive pointer velocity moves content the same way
        // drag deltas do: contentX/Y decreases - see _moveContent.
        dist = vel < 0 ? -dist : dist

        var maxValue = Math.max(0, control[contentSizeProp] - control[sizeProp])
        var rawTarget = control[contentProp] - dist
        var target = control._clamp(rawTarget, 0, maxValue)

        // If the bound clips the target short of the full computed distance, shorten the
        // duration by the same fraction. Our curve's shape only depends on distance/duration
        // (see splineProgress), so scaling both by the same factor keeps the animation starting
        // at the correct measured release velocity and just settles at the bound sooner - rather
        // than keeping the full original duration and crawling the much-shorter remaining
        // distance for many extra seconds (visible on real devices as content appearing to grind
        // to a near-halt right as it should be flying to the edge).
        if (target !== rawTarget) {
            var travelled = Math.abs(target - control[contentProp])
            var fraction = Math.abs(dist) > 0 ? Math.min(1, travelled / Math.abs(dist)) : 0
            duration = duration * fraction
        }

        flickTicker.flingAxis = axis
        flickTicker.flingStartValue = control[contentProp]
        flickTicker.flingTargetValue = target
        flickTicker.flingDurationMs = duration

        if (target !== rawTarget) {
            var clipped = Math.abs(rawTarget - target)
            var fraction = Math.min(1, Math.sqrt(clipped / Math.max(1, Math.abs(dist))))
            flickTicker.flingPendingAbsorb = {"glow": rawTarget > target ? endGlow : beginGlow, "fraction": fraction}
        } else {
            flickTicker.flingPendingAbsorb = null
        }

        // running is driven entirely by the `flingAxis !== ""` binding below; reset() only
        // zeroes elapsedTime/currentFrame (explicitly independent of running per its docs) so a
        // fresh fling starting while the ticker is already running (e.g. re-flicking mid-fling)
        // still gets a clean 0-based timeline.
        flickTicker.reset()
    }

    function _cancelFling() {
        flickTicker.flingAxis = ""
        flickTicker.flingPendingAbsorb = null
    }

    function _wheelStep(dx, dy, animate) {
        var maxX = Math.max(0, control.contentWidth - control.width)
        var maxY = Math.max(0, control.contentHeight - control.height)
        var targetX = control._clamp(control.contentX + dx, 0, maxX)
        var targetY = control._clamp(control.contentY + dy, 0, maxY)
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

    RallyPrivate.EdgeGlow {
        id: topGlow
        edge: Qt.TopEdge
        anchors.left: control.left
        anchors.right: control.right
        anchors.top: control.top
        height: 64
        visible: (control.flickableDirection & T.Flickable.VerticalFlick) !== 0
    }

    RallyPrivate.EdgeGlow {
        id: bottomGlow
        edge: Qt.BottomEdge
        anchors.left: control.left
        anchors.right: control.right
        anchors.bottom: control.bottom
        height: 64
        visible: (control.flickableDirection & T.Flickable.VerticalFlick) !== 0
    }

    RallyPrivate.EdgeGlow {
        id: leftGlow
        edge: Qt.LeftEdge
        anchors.top: control.top
        anchors.bottom: control.bottom
        anchors.left: control.left
        width: 64
        visible: (control.flickableDirection & T.Flickable.HorizontalFlick) !== 0
    }

    RallyPrivate.EdgeGlow {
        id: rightGlow
        edge: Qt.RightEdge
        anchors.top: control.top
        anchors.bottom: control.bottom
        anchors.right: control.right
        width: 64
        visible: (control.flickableDirection & T.Flickable.HorizontalFlick) !== 0
    }

    T.DragHandler {

        id: dragHandler

        target: null
        enabled: control.interactive
        acceptedButtons: Rally.RootItem.isTouchInput ? Qt.LeftButton : Qt.NoButton
        xAxis.enabled: (control.flickableDirection & T.Flickable.HorizontalFlick) !== 0
        yAxis.enabled: (control.flickableDirection & T.Flickable.VerticalFlick) !== 0

        property var _lastTranslation: Qt.vector2d(0, 0)
        // Qt's own centroid.velocity is a smoothed estimate tuned for general pointer tracking,
        // which systematically undershoots a real flick's release speed (a flick typically
        // accelerates right up to the moment of release). We track our own short rolling window
        // of raw (position, timestamp) samples instead, and compute velocity as total
        // displacement/time across that window - responsive to the true recent motion without
        // being as noisy as a single last-frame delta.
        property var _velocitySamples: []
        readonly property real _velocityWindowMs: 60

        function _recordVelocitySample(x, y) {
            var now = Date.now()
            dragHandler._velocitySamples.push({"x": x, "y": y, "t": now})
            while (dragHandler._velocitySamples.length > 1
                && now - dragHandler._velocitySamples[0].t > dragHandler._velocityWindowMs)
                dragHandler._velocitySamples.shift()
        }

        function _computeVelocity() {
            var samples = dragHandler._velocitySamples
            if (samples.length < 2)
                return Qt.vector2d(0, 0)
            var first = samples[0]
            var last = samples[samples.length - 1]
            var dt = (last.t - first.t) / 1000
            if (dt <= 0)
                return Qt.vector2d(0, 0)
            return Qt.vector2d((last.x - first.x) / dt, (last.y - first.y) / dt)
        }

        onActiveChanged: {
            if (dragHandler.active) {
                dragHandler._lastTranslation = Qt.vector2d(0, 0)
                dragHandler._velocitySamples = []
                control._axisAccumX = 0
                control._axisAccumY = 0
                control._dragAxis = ""
                control._cancelFling()
            } else {
                control._startFling(dragHandler._computeVelocity())
                control._releaseOverscroll()
            }
        }

        onActiveTranslationChanged: {
            var t = dragHandler.activeTranslation
            var dx = t.x - dragHandler._lastTranslation.x
            var dy = t.y - dragHandler._lastTranslation.y
            dragHandler._lastTranslation = t
            dragHandler._recordVelocitySample(t.x, t.y)
            control._applyDrag(dx, dy)
        }
    }

    // DragHandler.active only becomes true once the drag threshold is crossed, so pressing down
    // on a Flickable that's mid-fling without moving enough to start a new drag never reached
    // _cancelFling() - the fling kept running underneath the finger until it was cancelled by
    // (a) reaching the end of its own duration, or (b) the incidental threshold-crossing side
    // effect of the user then moving their finger. TapHandler.pressed instead fires immediately
    // on touch-down/mouse-press, before any threshold, and (using the default passive grab) does
    // this without stealing the point from children's own taps/clicks.
    T.TapHandler {

        id: tapToStopHandler

        enabled: control.interactive
        acceptedButtons: Rally.RootItem.isTouchInput ? Qt.LeftButton : Qt.NoButton

        onPressedChanged: {
            if (tapToStopHandler.pressed)
                control._cancelFling()
        }
    }

    T.WheelHandler {

        id: wheelHandler

        target: null
        enabled: control.interactive
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

        property string flingAxis: ""
        property real flingStartValue: 0
        property real flingTargetValue: 0
        property real flingDurationMs: 0
        property var flingPendingAbsorb: null

        running: flingAxis !== ""

        onTriggered: {
            var t = flickTicker.flingDurationMs > 0
                ? Math.min(1, flickTicker.elapsedTime * 1000 / flickTicker.flingDurationMs) : 1
            var progress = FlingPhysics.splineProgress(t)
            var value = flickTicker.flingStartValue
                + progress * (flickTicker.flingTargetValue - flickTicker.flingStartValue)

            if (flickTicker.flingAxis === "x")
                control.contentX = value
            else if (flickTicker.flingAxis === "y")
                control.contentY = value

            if (t >= 1) {
                var pending = flickTicker.flingPendingAbsorb
                flickTicker.flingAxis = ""
                flickTicker.flingPendingAbsorb = null
                if (pending)
                    pending.glow.absorb(pending.fraction)
            }
        }
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
