import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MaterialRally as Rally

Pane {

    ColumnLayout {

        anchors.fill: parent

        Rally.Icon {
            icon.name: "list-box"
        }

        Rally.GroupBox {
            title: qsTr("Scaling test")
            infoText: qsTr("This white rectangle should have a width and height of 1 cm")

            Rectangle {
                implicitHeight: Screen.pixelDensity * 10
                implicitWidth: Screen.pixelDensity * 10
            }
        }

        Rally.GroupBox {
            title: qsTr("Scaling test")
            infoText: qsTr("This white rectangle should have a width and height of 1 cm")

            Rectangle {
                implicitHeight: Screen.pixelDensity * 500
                implicitWidth: Screen.pixelDensity * 1
            }
        }

        Rally.GroupBox {

            title: qsTr("Action")
            Layout.fillWidth: true

            Timer {
                id: timer
                interval: 1000
                running: false
                repeat: false
                onTriggered: act.busy = false
            }

            mainAction: Rally.BusyAction {
                id: act
                text: qsTr("Start Action")
                icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
                onTriggered: {
                    busy = true
                    timer.restart()
                }
            }

            Label {
                text: qsTr("This GroupBox contains a BusyAction. As soon as the action is triggered a progressbar is shown.")
            }
        }

        Rally.Button {
            text: qsTr("Add Info Message")
            onClicked: inlineMessage.pushMessage("Info Message", "info", "Info Message")
        }

        Rally.Button {
            text: qsTr("Add Warning Message")
            onClicked: inlineMessage.pushMessage("Warning Message", "warning", "Warning Message")
        }

        Rally.Button {
            text: qsTr("Add Error Message")
            onClicked: inlineMessage.pushMessage("Error Message", "error", "Error Message")
        }

        Rally.InlineMessage {

            id: inlineMessage
            title: qsTr("Messages")
            Layout.fillWidth: true
            text: qsTr("asdfasdfasf")
        }

        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }

        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }
        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }
        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }
        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }
        Rally.Button {
            text: qsTr("Open Popup")
            onClicked: popup.open()
        }
    }
}
