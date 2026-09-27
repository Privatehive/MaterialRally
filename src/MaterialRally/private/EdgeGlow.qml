import QtQuick
import QtQuick.Controls.Material
import QtQuick.Effects

Item {

    id: control

    property int edge: Qt.TopEdge
    // Driven through setPull()/release()/absorb() rather than written directly: each of those
    // stops whatever animation the others started, so e.g. a drag that begins while the glow is
    // still receding takes over from where it is instead of being overwritten by the animation.
    property real pull: 0
    property color glowColor: Material.accent

    readonly property bool horizontalEdge: edge === Qt.LeftEdge || edge === Qt.RightEdge
    readonly property real thickness: horizontalEdge ? control.width : control.height
    readonly property real span: horizontalEdge ? control.height : control.width

    // One clamped value instead of the four separate Math.min(1, pull) calls the dome's bindings
    // used to each make on every frame the glow animates.
    readonly property real p: pull <= 0 ? 0 : (pull >= 1 ? 1 : pull)

    visible: p > 0.001
    clip: true

    // Follows the finger 1:1, like Android's EdgeEffect.onPull() - no smoothing while dragging.
    function setPull(value: real) {
        absorbAnim.stop()
        recedeAnim.stop()
        control.pull = value
    }

    // Android's EdgeEffect.onRelease(): recede from wherever the glow is. Like there, it only
    // acts on a glow that is being pulled - one already receding or absorbing is left alone - so
    // it is safe to call on every touch move.
    function release() {
        if (control.pull <= 0 || recedeAnim.running || absorbAnim.running)
            return
        recedeAnim.restart()
    }

    function absorb(fraction: real) {
        recedeAnim.stop()
        absorbAnim.peak = Math.max(0.15, Math.min(1, fraction))
        absorbAnim.restart()
    }

    // Android's EdgeEffect RECEDE state, which follows both a release and an absorb: 600 ms
    // (RECEDE_TIME) with a DecelerateInterpolator, i.e. 1 - (1 - t)^2 - Easing.OutQuad.
    readonly property int _recedeDuration: 600

    // `edge` never changes after construction, so the four-way switch that used to run inside
    // dome.x and dome.y on every animating frame is hoisted into these two, which depend on the
    // edge and the geometry but not on `pull`.
    readonly property bool _leadingEdge: edge === Qt.TopEdge || edge === Qt.LeftEdge
    readonly property real _domeBase: _leadingEdge ? -dome.diameter
                                                   : (horizontalEdge ? control.width : control.height)
    readonly property real _domeOffset: _domeBase + (_leadingEdge ? thickness * p : -thickness * p)

    Rectangle {

        id: dome

        readonly property real diameter: control.span * 1.4

        width: diameter
        height: diameter
        radius: diameter / 2
        // Alpha via opacity rather than Qt.alpha(): identical result for a single opaque shape,
        // but a float write instead of constructing a fresh QColor on every animating frame.
        color: control.glowColor
        opacity: 0.35 * control.p
        scale: 0.85 + 0.15 * control.p

        x: control.horizontalEdge ? control._domeOffset : (control.width - diameter) / 2
        y: control.horizontalEdge ? (control.height - diameter) / 2 : control._domeOffset

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.4
            blurMax: 32
        }
    }

    SequentialAnimation {

        id: absorbAnim

        property real peak: 1

        NumberAnimation {
            target: control
            property: "pull"
            to: absorbAnim.peak
            duration: 90
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: control
            property: "pull"
            to: 0
            duration: control._recedeDuration
            easing.type: Easing.OutQuad
        }
    }

    NumberAnimation {
        id: recedeAnim
        target: control
        property: "pull"
        to: 0
        duration: control._recedeDuration
        easing.type: Easing.OutQuad
    }
}
