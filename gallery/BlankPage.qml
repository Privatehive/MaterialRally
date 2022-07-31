import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import MaterialRally 1.0 as Rally
import QtQuick.Layouts 1.12

Page {

    implicitHeight: 500
    implicitWidth: 500

    Label {
        anchors.centerIn: parent
        text: "Page"
        scale: 2
    }

    background: Rectangle {
        color: Qt.lighter(Material.backgroundColor, 1.25)
    }
}
