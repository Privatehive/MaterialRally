import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import Qt5Compat.GraphicalEffects
import MaterialRally

T.Dialog {

    id: control

    property alias text: label.text

    modal: true
    parent: T.Overlay.overlay
    focus: true
    anchors.centerIn: parent
    width: Math.min(Math.max(parent.width / 2, 200), 500)

    closePolicy: T.Popup.CloseOnEscape

    opacity: 0

    T.Overlay.modal: Item {

        id: modalOverlay

        anchors.fill: parent

        opacity: 0
        layer.enabled: true

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
                    target: modalOverlay
                    property: "opacity"
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
                    target: modalOverlay
                    property: "opacity"
                    duration: 180
                    easing.type: Easing.InQuart
                    from: 1
                    to: 0
                }
            }
        ]

        Rectangle {
            anchors.fill: parent
            color: control.T.Material.backgroundColor
        }

        FastBlur {
            id: headerBlur
            width: control.RootItem.header ? control.RootItem.header.width : 0
            height: control.RootItem.header ? control.RootItem.header.height : 0
            source: control.RootItem.header ? control.RootItem.header : null
            radius: 32
            transparentBorder: true
        }

        FastBlur {
            id: mainBlur
            width: control.RootItem.contentItem ? control.RootItem.contentItem.width : 0
            height: control.RootItem.contentItem ? control.RootItem.contentItem.height : 0
            source: control.RootItem.contentItem ? control.RootItem.contentItem : null
            radius: 32
            transparentBorder: true
            anchors.top: headerBlur.bottom
        }

        FastBlur {
            id: footerBlur
            width: control.RootItem.footer ? control.RootItem.footer.width : 0
            height: control.RootItem.footer ? control.RootItem.footer.height : 0
            source: null
            radius: 32
            transparentBorder: true
            anchors.top: mainBlur.bottom
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.1
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

    QtObject {
        id: priv
        property string state: ""
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
}
