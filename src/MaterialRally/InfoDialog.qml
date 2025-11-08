import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Effects
import MaterialRally

T.Dialog {

    id: control

    property alias text: label.text

    focus: true
    modal: true

    parent: T.Overlay.overlay
    width: Math.min(Math.max(parent.width / 1.5, 200), 500)

    anchors.centerIn: parent

    closePolicy: T.Popup.CloseOnEscape

    opacity: 0

    T.Overlay.modal: Item {

        anchors.fill: parent

        onOpacityChanged: {
            opacity = 1 // prevent the overlay from beeing hidden if dialog is getting closed
        }

        Item {

            id: modalOverlay

            anchors.fill: parent

            // Workaround: The overlay item is created with a delay
            states: [
                State {
                    when: priv.state === "open"
                    name: "open"
                },
                State {
                    when: priv.state === "close"
                    name: "close"
                }
            ]

            transitions: [
                Transition {
                    from: "*"
                    to: "open"
                    PropertyAnimation {
                        target: mainBlurEffect
                        property: "blur"
                        duration: 180
                        easing.type: Easing.OutQuart
                        from: 0
                        to: 1
                    }
                },
                Transition {
                    from: "*"
                    to: "close"
                    PropertyAnimation {
                        target: mainBlurEffect
                        property: "blur"
                        duration: 180
                        easing.type: Easing.InQuart
                        from: 1
                        to: 0
                    }
                }
            ]

            ShaderEffectSource {
                id: mainBlur
                anchors.fill: parent
                live: true
                sourceItem: control.RootItem.contentItem ? control.RootItem.contentItem : null
                hideSource: true
                sourceRect: control.RootItem.contentItem ? mainBlur.mapToItem(control.RootItem.contentItem, 0, 0,
                                                                              width, height) : null
                visible: false
            }

            MultiEffect {
                id: mainBlurEffect
                source: mainBlur
                anchors.fill: parent
                blurEnabled: true
                blur: 1
                autoPaddingEnabled: true
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.1
            }
        }
    }

    enter: Transition {
        ParallelAnimation {
            ScriptAction {
                script: {
                    priv.state = "open"
                }
            }
            NumberAnimation {
                property: "opacity"
                duration: 180
                easing.type: Easing.OutQuart
                from: 0
                to: 1.0
            }
            NumberAnimation {
                property: "scale"
                duration: 180
                easing.type: Easing.OutBack
                from: 0.8
                to: 1.0
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            ScriptAction {
                script: {
                    priv.state = "close"
                }
            }
            NumberAnimation {
                property: "opacity"
                duration: 180
                easing.type: Easing.InQuart
                from: 1.0
                to: 0
            }
            NumberAnimation {
                property: "scale"
                duration: 180
                easing.type: Easing.InBack
                from: 1.0
                to: 0.8
            }
        }
    }

    contentItem: T.Label {
        id: label
        font.pixelSize: 16
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        color: "black"
    }

    footer: ToolButton {
        text: qsTr("Dismiss")
        onClicked: control.close()
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            anchors.bottom: parent.top
            x: control.leftPadding - control.padding / 2
            color: control.T.Material.dividerColor
            height: 2
            width: control.availableWidth + control.padding / 2
        }
    }

    QtObject {
        id: priv
        property string state: ""
    }
}
