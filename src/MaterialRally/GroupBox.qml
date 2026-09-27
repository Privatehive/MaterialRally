import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Layouts
import MaterialRally
import "helper.js" as Helper


/*!
    \qmltype GroupBox
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::GroupBox

    \brief Visual frame and title for a logical group of controls.

    A group box visually groups its child items on a card with a header. The header shows the
    \c title, optionally an \l icon to the left of the title and an info button to the right of
    it (see \l infoText). Below the header a divider separates it from the content.

    A \l mainAction can be added to the right side of the header:
    \list
    \li A regular BusyAction is shown as an upper case text button. While the action is
        \l {BusyAction::delayedBusy}{busy}, the divider turns into a progress bar and the button
        is disabled.
    \li A \c checkable BusyAction is shown as a switch. Switching it off
        folds the group box to its header, switching it on unfolds it again.
    \endlist

    Height changes of the group box are animated, see \l animationDuration.

    \image group-box.png "GroupBox"

    \section1 Examples

    A group box with a title, an icon, a help text and a reload action:

    \qml
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import MaterialRally as Rally

    Rally.GroupBox {
        width: 400
        title: qsTr("Accounts")
        icon.source: "qrc:/icons/bank.svg"
        infoText: qsTr("All accounts of the current user. Pull the data again with 'Reload'.")

        mainAction: Rally.BusyAction {
            text: qsTr("Reload")
            onTriggered: {
                busy = true
                backend.reload(() => busy = false)
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Label { text: qsTr("Checking: 2.215,13 €") }
            Label { text: qsTr("Home Savings: 8.676,88 €") }
        }
    }
    \endqml

    A group box that can be folded with a switch in its header:

    \qml
    Rally.GroupBox {
        Layout.fillWidth: true
        title: qsTr("Proxy")

        mainAction: Rally.BusyAction {
            checkable: true
            onToggled: settings.proxyEnabled = checked
        }

        Rally.FormLayout {
            Label { text: qsTr("Host") }
            Rally.TextField { text: settings.proxyHost }
        }
    }
    \endqml

    \sa BusyAction, CollapsibleControl
*/
T.GroupBox {

    id: control


    /*!
      \qmlproperty BusyAction GroupBox::mainAction
      \default null

      A BusyAction the user can trigger from the header of the group box. A non-checkable action
      is shown as a text button, a progress bar is shown while the action is busy. A checkable
      action is shown as a switch that folds and unfolds the group box.

      \sa BusyAction
    */
    property BusyAction mainAction


    /*!
      \qmlproperty string GroupBox::infoText
      \default ""

      If not empty, an info icon is shown to the right of the title. When the user clicks it, an
      \l InfoDialog with this text opens. Use it for help texts that are too long for the title.
    */
    property string infoText: ""


    /*!
      \qmlproperty icon GroupBox::icon

      The icon shown to the left of the title. Set \c {icon.source} or \c {icon.name}, and
      optionally \c {icon.color}. No icon is shown by
      default.

      \qml
      Rally.GroupBox {
          title: qsTr("Warnings")
          icon.source: "qrc:/icons/alert.svg"
          icon.color: Material.color(Material.Amber)
      }
      \endqml
    */
    property alias icon: iconLabel.icon


    /*!
      \qmlproperty int GroupBox::animationDuration
      \default 200

      The duration, in milliseconds, of the animation that runs when the height of the group box
      changes, e.g. when it is folded. Set this to 0 to disable the animation.
    */
    property alias animationDuration: animation.duration

    T.Material.roundedScale: T.Material.NotRounded

    topPadding: padding + control.implicitLabelHeight

    clip: true

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: "#393942"
        radius: control.T.Material.roundedScale
    }

    Behavior on implicitHeight {
        NumberAnimation {
            id: animation
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    label: Item {

        z: 1
        x: control.leftPadding
        visible: control.title.length > 0 || control.mainAction
        implicitWidth: visible ? control.availableWidth : 0
        implicitHeight: visible ? control.T.Material.delegateHeight - 4 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: {
                control.focus = false
            }
        }

        RowLayout {

            id: row
            anchors.fill: parent

            Icon {
                id: iconLabel
            }

            Item {

                Layout.fillWidth: true

                T.Label {
                    id: label
                    text: control.title
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - (icon.visible ? icon.width : 0) - 6)
                }

                Icon {
                    id: icon
                    visible: control.infoText.length > 0
                    icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
                    icon.width: 20
                    icon.height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: label.right
                    anchors.leftMargin: 6

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const dialog = Helper.createDialog("InfoDialog.qml", control, {
                                "text": control.infoText
                            })
                        }
                    }
                }
            }

            T.ToolButton {
                id: actionButton

                action: control.mainAction
                leftPadding: 0
                rightPadding: 0
                visible: action && !action.checkable
                enabled: control.mainAction ? !control.mainAction.delayedBusy : false
                implicitHeight: parent.height

                font.capitalization: Font.AllUppercase
                font.styleName: "Bold"
                font.letterSpacing: 2.8

                background: Rectangle {

                    T.Label {
                        // TextMetrics does not work, retrns wrong width
                        id: text
                        text: actionButton.text
                        font: actionButton.font
                        visible: false
                    }

                    color: actionButton.icon.color
                    anchors.bottom: actionButton.contentItem.bottom
                    anchors.bottomMargin: 5
                    anchors.right: actionButton.contentItem.right

                    width: text.implicitWidth
                    height: actionButton.hovered && actionButton.enabled ? 2 : 0

                    antialiasing: true

                    Behavior on height {
                        enabled: actionButton.enabled
                        SmoothedAnimation {
                            duration: 250
                            velocity: -1
                        }
                    }
                }
            }

            T.Switch {

                id: toggleButton

                Binding {
                    target: control
                    property: "contentHeight"
                    when: toggleButton.visible && !toggleButton.checked
                    value: 0
                }

                Binding {
                    target: control
                    property: "topPadding"
                    when: toggleButton.visible && !toggleButton.checked
                    value: control.implicitLabelHeight
                }

                Binding {
                    target: control
                    property: "bottomPadding"
                    when: toggleButton.visible && !toggleButton.checked
                    value: 0
                }

                Binding {
                    target: control.contentItem
                    property: "opacity"
                    when: toggleButton.visible && !toggleButton.checked
                    value: 0
                }

                action: control.mainAction
                leftPadding: 0
                rightPadding: 0
                checked: true
                visible: action && action.checkable
                enabled: control.mainAction ? !control.mainAction.delayedBusy : false
                scale: 0.75
            }
        }

        Rectangle {
            id: devider
            width: control.availableWidth
            color: control.T.Material.backgroundColor
            implicitHeight: 2
            anchors.top: row.bottom

            T.ProgressBar {

                anchors.fill: parent

                visible: control.mainAction ? control.mainAction.delayedBusy : false

                indeterminate: true

                Component.onCompleted: {
                    contentItem.implicitHeight = 2
                }
            }
        }
    }
}
