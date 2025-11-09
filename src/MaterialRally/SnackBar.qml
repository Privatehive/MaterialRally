import QtQml as T
import QtQuick as T
import QtQuick.Layouts as T
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally as Rally


/*!
    \qmltype SnackBar
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Control

    \brief Displays snack-bar notifikations.

    Displays multiple snack-bar notifications on top of each other. For each notification, you can individually specify which text & icon, is displayed, with what severity, and for how long.

    \image snack-bar.png "SnackBar"
*/
T.Control {

    id: control


    /*!
      \qmlproperty int SnackBar::maxCount
      \default 10

      This is the maximum number of snack-bar notifications the snack-bar can hold. If the maxCount is reached and an additional snack-bar notification is pushed the oldest notification will be removed immediately.
    */
    property int maxCount: 10


    /*!
      \qmlproperty bool SnackBar::inverted
      \default false

      By default, new snack-bar notifications are added to the top and old messages are removed from the bottom. By setting inverted to true new snack-bar notifications are added to the bottom and old messages are removed from the top.
    */
    property bool inverted: false


    /*!
      \qmlmethod void SnackBar::pushMessage(string message, string severity, int timeout, string title, string iconName)

      Push a new snack-bar notification. This function accepts five parameters:

      \a message: The message string to display

      \a severity: Determines the background color. Allowed values are: "info", "warning", "error". Defaults to "info"

      \a timeout: How long the snack-bar notification is displayed in milliseconds. Defaults to 5000

      \a title: Optionally give the notification a title. Defaults to null

      \a iconName: Optionally give the notification an icon. Defaults to null
    */
    function pushMessage(message, severity, timeout, title, iconName) {

        if (!message) {
            message = ""
        }

        if (!title) {
            title = ""
        }

        if (!severity) {
            severity = "info"
        }

        if (!timeout) {
            timeout = 5000
        }

        if (!iconName) {
            iconName = ""
        }

        const currentCount = messageModel.count + 1

        messageModel.insert(0, {
                                "title": title,
                                "severity": severity,
                                "displayMessage": message,
                                "timeout": timeout,
                                "iconName": iconName
                            })

        if (currentCount > control.maxCount) {

            messageModel.remove(currentCount - 1)
        }
    }


    /*!
      \qmlmethod void SnackBar::clear()

      Remove all snack-bar notifications
    */
    function clear() {

        messageModel.clear()
    }

    implicitWidth: 400

    T.ListModel {
        id: messageModel
    }

    contentItem: T.Column {

        spacing: 10
        width: parent.width

        rotation: control.inverted ? 180 : 0

        add: T.Transition {
            T.SequentialAnimation {
                T.PauseAnimation {
                    duration: 100
                }
                T.PropertyAction {
                    property: "opacity"
                    value: 0
                }
                T.PropertyAction {
                    property: "scale"
                    value: 0.9
                }
                T.NumberAnimation {
                    properties: "opacity, scale"
                    to: 1.0
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        move: T.Transition {
            T.SequentialAnimation {
                T.ParallelAnimation {
                    T.NumberAnimation {
                        properties: "opacity, scale"
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                    T.NumberAnimation {
                        properties: "x,y"
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        T.Repeater {

            id: repeater
            model: messageModel
            width: parent.width

            T.Control {

                id: entry

                width: parent.width

                implicitHeight: Math.max(content.implicitHeight + padding * 2, button.implicitHeight)

                rotation: control.inverted ? -180 : 0

                padding: 10
                rightPadding: button.width
                leftPadding: icon.visible ? icon.width + 20 : padding

                opacity: 0

                hoverEnabled: true

                function remove() {
                    removeAnimation.onFinished.connect(() => {
                                                           messageModel.remove(index)
                                                       })
                    removeAnimation.start()
                }

                T.SequentialAnimation {
                    id: removeAnimation
                    alwaysRunToEnd: true
                    T.ParallelAnimation {
                        T.NumberAnimation {
                            target: entry
                            property: "scale"
                            from: 1
                            to: 0.9
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                        T.NumberAnimation {
                            target: entry
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                    T.PropertyAction {
                        target: entry
                        property: "visible"
                        value: false
                    }
                }

                contentItem: T.ColumnLayout {

                    id: content
                    width: entry.availableWidth
                    spacing: 4

                    T.Label {
                        T.Layout.fillWidth: true
                        text: title
                        font.bold: true
                        visible: text.length > 0
                        wrapMode: T.Text.WordWrap
                    }

                    T.Label {
                        T.Layout.fillWidth: true
                        text: displayMessage
                        visible: displayMessage.length > 0
                        wrapMode: T.Text.WordWrap
                        verticalAlignment: T.Text.AlignVCenter
                    }
                }

                T.Timer {
                    id: timer
                    interval: timeout
                    running: entry.hovered ? false : true
                    onTriggered: {
                        entry.remove()
                    }
                }

                T.RoundButton {
                    id: button
                    icon.source: "qrc:/icons/material_private/48x48/close.svg"
                    flat: true
                    anchors.right: parent.right
                    anchors.top: parent.top
                    onClicked: {
                        entry.remove()
                    }
                }

                Rally.Icon {
                    id: icon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    name: iconName
                    visible: iconName.length > 0
                }

                T.TapHandler {
                    onTapped: {
                        timer.restart()
                    }
                }

                background: T.Rectangle {
                    border.color: "white"
                    border.width: 3
                    radius: 6
                    opacity: entry.hovered ? 1.0 : 0.8
                    color: {
                        switch (severity) {
                        case "error":
                            return control.T.Material.color(T.Material.Red)
                        case "warning":
                            return control.T.Material.color(T.Material.Amber)
                        case "info":
                            return control.T.Material.color(T.Material.BlueGrey)
                        default:
                            return control.T.Material.color(T.Material.BlueGrey)
                        }
                    }
                }
            }
        }
    }
}
