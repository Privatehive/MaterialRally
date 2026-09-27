import QtQuick
import QtQuick.Controls

Column {

    id: control

    property alias text: ta.text

    spacing: 10

    Component.onCompleted: {

        Qt.createQmlObject(control.text, holder)
    }

    Column {
        id: holder
    }

    TextArea {

        id: ta
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: "Roboto Mono"
        activeFocusOnPress: false
        readOnly: true

        RoundButton {

            id: copyButton
            icon.source: "qrc:/icons/material_private/48x48/content-copy.svg"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 10

            onClicked: {
                ta.selectAll()
                ta.copy()
                copySuccessLabel.visible = true
            }
        }

        Label {
            id: copySuccessLabel
            text: qsTr("Copied")

            visible: false
            anchors.verticalCenter: copyButton.verticalCenter
            anchors.right: copyButton.left
            anchors.rightMargin: 10

            Timer {
                running: parent.visible
                repeat: false
                interval: 1000
                onTriggered: {
                    parent.visible = false
                }
            }
        }
    }
}
