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

    \brief Displays short, transient notifications.

    SnackBar shows notifications pushed with \l pushMessage() as a stack of cards. Each
    notification can have a title, a message, an icon and a severity that determines its color
    (\c "info": blue-grey, \c "warning": amber, \c "error": red), and disappears on its own after
    a timeout.

    The user can interact with a notification:
    \list
    \li While the mouse hovers over it, its timeout is paused.
    \li Tapping it restarts its timeout.
    \li The close button removes it immediately.
    \endlist

    Place the SnackBar on top of the application content, e.g. at the bottom of the window, and
    give it a width (the implicit width is 400 px). Its height grows with the number of
    notifications.

    \image snack-bar.png "SnackBar"

    \section1 Example

    \qml
    import QtQuick
    import MaterialRally as Rally

    Rally.RallyApplicationWindow {

        Rally.ScrollView {
            anchors.fill: parent
            // ...
        }

        Rally.SnackBar {
            id: snackBar
            width: Math.min(parent.width - 20, 400)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            // add new notifications at the bottom, next to the window border
            inverted: true
        }

        Connections {
            target: backend
            function onTransferDone() {
                snackBar.pushMessage(qsTr("The money was transferred."))
            }
            function onTransferFailed(reason) {
                snackBar.pushMessage(reason, "error", 10000, qsTr("Transfer failed"))
            }
        }
    }
    \endqml

    \sa InlineMessage
*/
T.Control {

    id: control


    /*!
      \qmlproperty int SnackBar::maxCount
      \default 10

      The maximum number of notifications the snack bar shows at once. If a notification is
      pushed while \c maxCount notifications are shown, the oldest one is removed immediately.
    */
    property int maxCount: 10


    /*!
      \qmlproperty bool SnackBar::inverted
      \default false

      By default, new notifications are added at the top and the stack grows downwards. If
      \c inverted is \c true, new notifications are added at the bottom and the stack grows
      upwards - use this if the snack bar is anchored to the bottom of the window.
    */
    property bool inverted: false


    /*!
      \qmlmethod void SnackBar::pushMessage(string message, string severity, int timeout, string title, string iconName)

      Shows a new notification.

      \a message is the text of the notification.

      \a severity determines the background color. Allowed values are \c "info",
      \c "warning" and \c "error". Defaults to \c "info".

      \a timeout is the time, in milliseconds, after which the notification disappears.
      Defaults to 5000.

      \a title is an optional title, shown in bold above the message.

      \a iconName is the optional name of an icon from the current icon theme, shown on the
      left side of the notification.

      All parameters but \a message are optional:

      \code
      snackBar.pushMessage(qsTr("Saved"))
      snackBar.pushMessage(qsTr("The connection was lost."), "warning")
      snackBar.pushMessage(qsTr("Could not save the file."), "error", 10000, qsTr("Error"), "alert-outline")
      \endcode
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

      Removes all notifications immediately.
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
