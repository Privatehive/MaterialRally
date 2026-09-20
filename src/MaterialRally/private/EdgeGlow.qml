import QtQuick
import QtQuick.Controls.Material
import QtQuick.Effects

Item {

    id: control

    property int edge: Qt.TopEdge
    property real pull: 0
    property color glowColor: Material.accent

    readonly property bool horizontalEdge: edge === Qt.LeftEdge || edge === Qt.RightEdge
    readonly property real thickness: horizontalEdge ? control.width : control.height
    readonly property real span: horizontalEdge ? control.height : control.width

    visible: pull > 0.001
    clip: true

    function absorb(fraction) {
        absorbAnim.peak = Math.max(0.15, Math.min(1, fraction))
        absorbAnim.restart()
    }

    Behavior on pull {
        enabled: !absorbAnim.running
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {

        id: dome

        readonly property real diameter: control.span * 1.4

        width: diameter
        height: diameter
        radius: diameter / 2
        color: Qt.alpha(control.glowColor, 0.35 * Math.min(1, control.pull))
        scale: 0.85 + 0.15 * Math.min(1, control.pull)

        x: {
            if (!control.horizontalEdge)
                return (control.width - diameter) / 2
            return control.edge === Qt.LeftEdge ? -diameter + control.thickness * Math.min(1, control.pull)
                                                 : control.width - control.thickness * Math.min(1, control.pull)
        }

        y: {
            if (control.horizontalEdge)
                return (control.height - diameter) / 2
            return control.edge === Qt.TopEdge ? -diameter + control.thickness * Math.min(1, control.pull)
                                                : control.height - control.thickness * Math.min(1, control.pull)
        }

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
