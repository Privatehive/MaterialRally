import QtQuick
import QtQuick.Controls.Material
import QtQuick.Effects

Item {

    id: control

    property int edge: Qt.TopEdge
    property real pull: 0
    property color glowColor: Material.accent

    /*!
      Set while the owning Flickable is actively being dragged. The smoothing Behavior below is a
      release/settle animation; leaving it enabled during the drag meant every touch sample
      restarted a fresh 300 ms animation - hundreds of QAbstractAnimation restarts per second on a
      high-rate digitiser - and made the glow visibly chase the finger rather than track it.
      Android's EdgeEffect follows the pull 1:1 and only animates on release and absorb.
    */
    property bool tracking: false

    readonly property bool horizontalEdge: edge === Qt.LeftEdge || edge === Qt.RightEdge
    readonly property real thickness: horizontalEdge ? control.width : control.height
    readonly property real span: horizontalEdge ? control.height : control.width

    // One clamped value instead of the four separate Math.min(1, pull) calls the dome's bindings
    // used to each make on every frame the glow animates.
    readonly property real p: pull <= 0 ? 0 : (pull >= 1 ? 1 : pull)

    visible: p > 0.001
    clip: true

    function absorb(fraction: real) {
        absorbAnim.peak = Math.max(0.15, Math.min(1, fraction))
        absorbAnim.restart()
    }

    Behavior on pull {
        enabled: !absorbAnim.running && !control.tracking
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

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
            duration: 380
            easing.type: Easing.InQuad
        }
    }
}
