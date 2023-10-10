import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQml.Models

GroupBox {

    id: control

    property bool fold: true
    property string text: ""
    property alias count: messageModel.count

    // severity one of "error", "warning", "info"
    function pushMessage(message, severity, title) {

        if (!message) {
            message = ""
        }

        if (!title) {
            title = ""
        }

        if (!severity) {
            severity = "info"
        }

        messageModel.insert(0, {
                                "title": title,
                                "severity": severity,
                                "displayMessage": message
                            })
        //propertyAnimIn.start()
    }

    function hide() {//propertyAnimIn.stop()
        //propertyAnimOut.start()
    }

    readonly property BusyAction defaultAction: BusyAction {

        //visible: messageModel.count > grid.columns
        text: control.fold ? qsTr("SEE ALL") + " (" + messageModel.count + ")" : qsTr(
                                 "SEE LESS")

        onTriggered: {
            control.fold = !control.fold
        }
    }

    mainAction: messageModel.count > grid.columns ? defaultAction : null

    ListModel {
        id: messageModel

        onCountChanged: {

            if (messageModel.count > 0 && messageModel.get(0)) {
                control.title = messageModel.get(0).title
                const severity = messageModel.get(0).severity
                switch (severity) {
                case "error":
                    control.icon.source = "qrc:/icons/material_private/48x48/alert-outline.svg"
                    control.icon.color = control.T.Material.color(T.Material.Red)
                    break
                case "warning":
                    control.icon.source = "qrc:/icons/material_private/48x48/alert-outline.svg"
                    control.icon.color = control.T.Material.color(T.Material.Yellow)
                    break
                case "info":
                    control.icon.source = "qrc:/icons/material_private/48x48/information-outline.svg"
                    control.icon.color = control.T.Material.accentColor
                    break
                default:
                    control.icon.source = "qrc:/icons/material_private/48x48/information-outline.svg"
                    control.icon.color = control.T.Material.accentColor
                }
            } else {
                control.title = ""
            }
        }
    }

    ColumnLayout {

        id: columLayout
        width: parent.width
        spacing: 10

        Grid {

            id: grid

            property real minWidth: (parent.width - (grid.columns - 1)
                                     * columnSpacing) / grid.columns

            columns: Math.max(parent.width / 400, 1)
            columnSpacing: 50
            rowSpacing: 10

            add: Transition {
                id: transition
                SequentialAnimation {
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.9
                    }
                    PauseAnimation {
                        duration: grid.columns > 1
                                  && messageModel.count > 1 ? 200 : 0
                    }
                    NumberAnimation {
                        properties: "opacity, scale"
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }

            move: Transition {
                id: transition1
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            properties: "opacity, scale"
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            properties: "x,y"
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }


            /*
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }*/
            Repeater {

                id: rep
                model: messageModel

                ColumnLayout {

                    width: grid.minWidth
                    spacing: 10
                    visible: control.fold ? index < grid.columns : true
                    opacity: 0

                    RowLayout {

                        Layout.fillWidth: true

                        T.Label {
                            text: displayMessage
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            Layout.alignment: Qt.AlignTop
                        }

                        T.RoundButton {
                            icon.source: "qrc:/icons/material_private/48x48/playlist-remove.svg"
                            flat: true
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: -10
                            onClicked: {
                                messageModel.remove(index)
                            }
                        }
                    }

                    Rectangle {
                        height: 1
                        color: control.T.Material.backgroundColor
                        Layout.fillWidth: true
                    }
                }
            }
        }

        T.Label {
            visible: messageModel.count === 0
            text: qsTr("No messages")
        }
    }
}
