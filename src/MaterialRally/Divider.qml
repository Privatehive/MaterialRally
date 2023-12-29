import QtQuick
import QtQuick.Controls.Material

Item {

    id: control
    property color color: Material.backgroundColor

    implicitWidth: 120
    implicitHeight: 16

    Rectangle {
        color: control.color
        width: parent.width
        implicitHeight: 2
        y: parent.height / 2 - height / 2
    }
}