import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.TextArea {

    id: control
    selectByMouse: true

    topPadding: 12
    bottomPadding: 12
    leftPadding: 12
    rightPadding: 12
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0
    tabStopDistance: 20

    background: Rectangle {
        property real borderOpacity: control.activeFocus && !control.readOnly ? 1 : 0
        implicitWidth: 250
        implicitHeight: control.Material.buttonHeight
        color: "#26282f"
        border.color: Qt.rgba(control.Material.accentColor.r, control.Material.accentColor.g,
                              control.Material.accentColor.b, control.Material.accentColor.a * borderOpacity)
        border.width: 1 //control.activeFocus && !control.readOnly ? 1 : 0

        Behavior on borderOpacity {
            SmoothedAnimation {
                duration: 250
                velocity: -1
            }
        }
    }
}
