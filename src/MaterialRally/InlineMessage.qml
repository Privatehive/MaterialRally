import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQml.Models
import MaterialRally


/*!
    \qmltype InlineMessage
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits MaterialRally::GroupBox

    \brief A group box that collects messages inline in the page.

    InlineMessage is a Rally \l GroupBox that lists messages pushed with \l pushMessage(). Unlike
    the transient notifications of a \l SnackBar, the messages stay until the user removes them
    (with the button next to each message) or \l clear() is called - use it e.g. for validation or
    synchronization errors that belong to a certain part of a page.

    The header of the group box always reflects the newest message: its title is shown as the
    group box title, and an icon and color matching its severity is shown next to it:

    \table
    \header \li Severity \li Icon color
    \row \li \c "error" \li red
    \row \li \c "warning" \li amber
    \row \li \c "info" \li blue-grey
    \endtable

    Messages are laid out in a grid with one column per 400 px of width, the newest message
    first. While \l fold is \c true only the first row of messages is shown. As soon as there are
    more messages than fit into one row, a \e {See all (n)} / \e {See less} action in the header
    toggles \l fold. If there are no messages, "No messages" is shown.

    \section1 Example

    \qml
    import QtQuick
    import QtQuick.Layouts
    import MaterialRally as Rally

    ColumnLayout {

        Rally.InlineMessage {
            id: syncMessages
            Layout.fillWidth: true
            maxCount: 20
        }

        Connections {
            target: backend
            function onSyncFailed(reason) {
                syncMessages.pushMessage(reason, "error", qsTr("Synchronization failed"))
            }
            function onSyncFinished() {
                syncMessages.clear()
                syncMessages.pushMessage(qsTr("All accounts are up to date."), "info",
                                         qsTr("Synchronized"))
            }
        }
    }
    \endqml

    \sa SnackBar, GroupBox
*/
GroupBox {

    id: control


    /*!
      \qmlproperty bool InlineMessage::fold
      \default true

      If \c true, only the first row of messages is shown. If \c false, all messages are shown.
      The user toggles this property with the \e {See all} / \e {See less} action in the header.
    */
    property bool fold: true

    /*! \internal Not used at the moment. */
    property string text: ""


    /*!
      \qmlproperty int InlineMessage::count
      \readonly

      The number of messages, including the ones hidden because the InlineMessage is folded.
    */
    readonly property alias count: messageModel.count


    /*!
      \qmlproperty int InlineMessage::maxCount
      \default 1000

      The maximum number of messages the InlineMessage holds. If a message is pushed while
      \c maxCount messages are shown, the oldest message is removed.
    */
    property int maxCount: 1000


    /*!
      \qmlmethod void InlineMessage::pushMessage(string message, string severity, string title)

      Adds a new message in front of all other messages.

      \a message is the text of the message.

      \a severity determines the icon and its color in the header. Allowed values are
      \c "error", \c "warning" and \c "info". Defaults to \c "info".

      \a title is shown as the title of the group box while this is the newest message.
      Defaults to an empty string.

      \code
      inlineMessage.pushMessage(qsTr("The IBAN is invalid."), "warning", qsTr("Transfer"))
      \endcode
    */
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


    /*!
      \qmlmethod void InlineMessage::clear()

      Removes all messages.
    */
    function clear() {

        messageModel.clear()
    }

    /*! \internal */
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
