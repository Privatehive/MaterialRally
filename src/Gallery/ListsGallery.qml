import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MaterialRally as Rally

Pane {

    id: control

    ColumnLayout {

        anchors.fill: parent

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
            maxCount: 10
        }

        Rally.Button {
            text: qsTr("Add Info Snackbar Message")
            onClicked: {
                snackbarMessageTop.pushMessage("Info Message", "info")
                snackbarMessageBottom.pushMessage("Info Message", "info")
            }
        }

        Rally.Button {
            text: qsTr("Add Warning Snackbar Message")
            onClicked: {
                snackbarMessageTop.pushMessage("Warning Message", "warning")
                snackbarMessageBottom.pushMessage("Warning Message", "warning")
            }
        }

        Rally.Button {
            text: qsTr("Add Error Snackbar Message")
            onClicked: {
                snackbarMessageTop.pushMessage(
                            "Error Messageasd asd fasd fasd fasd fas dfasd fasasfd afds  afdsdfs fdssfda dsfads fa dsf dsf adsf ads dafsadsdsfda sf",
                            "error", 1000, "asdfasdf")
                snackbarMessageBottom.pushMessage(
                            "Error Messageasd asd fasd fasd fasd fas dfasd fasasfd afds  afdsdfs fdssfda dsfads fa dsf dsf adsf ads dafsadsdsfda sf",
                            "error", 1000, "asdfasdf")
            }
        }
    }

    Rally.SnackBar {

        id: snackbarMessageTop
        inverted: false
        parent: Overlay.overlay
        //width: 100
        anchors.left: parent.left
        //anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Rally.SnackBar {

        id: snackbarMessageBottom
        inverted: true
        parent: Overlay.overlay
        //width: 100
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        //anchors.top: parent.top
        anchors.right: parent.right
    }
}
