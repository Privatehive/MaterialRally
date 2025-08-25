import QtQml
import QtQuick
import QtQuick.Controls

Popup {

    id: control
    // target needs 'widh' and 'height' property
    property QtObject target: Item {}
    property bool active: true

    visible: active
    modal: false
    padding: 0
    margins: 0

    width: label.implicitWidth
    height: label.implicitHeight

    Overlay.modeless: Item {}

    contentItem: Label {

        id: label
        padding: 10
        text: "w: " + control.target.width + " h: " + control.target.height
        z: 100

        Connections {
            target: control.target
            enabled: control.active

            function onWidthChanged() {
                control.visible = true
                sizeLabelTimer.restart()
            }

            function onHeightChanged() {
                control.visible = true
                sizeLabelTimer.restart()
            }
        }

        Timer {
            id: sizeLabelTimer
            interval: 1000
            onTriggered: {
                control.visible = false
            }
        }
    }

    background: Rectangle {
        color: "black"
        opacity: 0.4
        radius: 4
    }
}
