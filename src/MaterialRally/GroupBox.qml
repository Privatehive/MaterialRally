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
    \inherits T.GroupBox

    \brief Visual frame and title for a logical group of controls.

    A group-box visually groups any child items together. A group-box shows a title and optionally an icon. A group-box may contain a busy-action that can be triggered by the user.
    The group-box can also show a help pop-up.

    \image group-box.png "GroupBox"
*/
T.GroupBox {

    id: control


    /*!
      \qmlproperty BusyAction GroupBox::mainAction
      \default null

      A BusyAction that can be triggerd by the user. The text of the action is shown in the header of the group-box. If triggered, the group-box will show a progress indicator.
    */
    property BusyAction mainAction


    /*!
      \qmlproperty string GroupBox::infoText
      \default ""

        If provided, an info icon is displayed to the right of the group-box title. When the user clicks on it, a pop-up opens with the specified text.
    */
    property string infoText: ""


    /*!
      \qmlproperty icon group GroupBox::icon
      \default ""

        If provided, the specified icon is displayed to the left of the group-box title. Use icon.name or icon.source and icon.color.
    */
    property alias icon: iconLabel.icon


    /*!
      \qmlproperty int group GroupBox::animationDuration
      \default 200

        Animates changes in the height of the group-box. Set this to 0 to disable animations.
    */
    property alias animationDuration: animation.duration

    T.Material.roundedScale: T.Material.NotRounded

    topPadding: padding + control.implicitLabelHeight

    clip: true

    TapHandler {
        onTapped: {
            control.focus = false
        }
    }

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
