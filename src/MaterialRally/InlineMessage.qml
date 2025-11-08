import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQml.Models
import MaterialRally

GroupBox {

    id: control

    property bool fold: true
    property string text: ""
    readonly property alias count: messageModel.count
    property int maxCount: 1000

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

        const currentCount = messageModel.count + 1

        messageModel.insert(0, {
                                "title": title,
                                "severity": severity,
                                "displayMessage": message
                            })

        if (currentCount > control.maxCount) {

            messageModel.remove(currentCount - 1)
        }
    }

    function clear() {

        messageModel.clear()
    }

    readonly property BusyAction defaultAction: BusyAction {

        //visible: messageModel.count > grid.columns
        text: control.fold ? qsTr("SEE ALL") + " (" + messageModel.count + ")" : qsTr("SEE LESS")

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
                    control.icon.color = control.T.Material.color(T.Material.Amber)
                    break
                case "info":
                    control.icon.source = "qrc:/icons/material_private/48x48/information-outline.svg"
                    control.icon.color = control.T.Material.color(T.Material.BlueGrey)
                    break
                default:
                    control.icon.source = "qrc:/icons/material_private/48x48/information-outline.svg"
                    control.icon.color = control.T.Material.color(T.Material.BlueGrey)
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

            property real minWidth: (parent.width - (grid.columns - 1) * columnSpacing) / grid.columns

            columns: Math.max(parent.width / 400, 1)
            columnSpacing: 50
            rowSpacing: 10

            add: Transition {
                SequentialAnimation {
                    PauseAnimation {
                        duration: 100
                    }
                    PropertyAction {
                        property: "opacity"
                        value: 0
                    }
                    PropertyAction {
                        property: "scale"
                        value: 0.9
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
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Repeater {

                id: rep
                model: messageModel

                ColumnLayout {

                    id: entry

                    property bool proposedVisible: control.fold ? index < grid.columns : true
                    property real dummy: 0

                    width: grid.minWidth
                    spacing: 10
                    opacity: 0

                    onProposedVisibleChanged: {
                        if (!entry.proposedVisible) {
                            removeAnimation.start()
                        } else {
                            entry.visible = true
                        }
                    }

                    SequentialAnimation {
                        id: removeAnimation
                        alwaysRunToEnd: true
                        PropertyAction {
                            id: implicitHeightAction
                            target: entry
                            property: "implicitHeight"
                            value: 0
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: entry
                                property: "scale"
                                from: 1
                                to: 0.9
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: entry
                                property: "opacity"
                                from: 1
                                to: 0
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }
                        PropertyAction {
                            target: entry
                            property: "visible"
                            value: false
                        }
                    }

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
                                if (entry.visible) {
                                    removeAnimation.onFinished.connect(() => {
                                                                           messageModel.remove(index)
                                                                       })
                                    if (control.fold) {
                                        implicitHeightAction.property = ""
                                    }
                                    removeAnimation.start()
                                } else {
                                    messageModel.remove(index)
                                }
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
