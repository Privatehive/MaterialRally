import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally

T.Dialog {

    id: control

    signal backButtonClicked

    readonly property real yStart: 80
    property alias busy: progressBar.visible

    T.Material.elevation: 0
    T.Material.roundedScale: T.Material.NotRounded

    topPadding: yStart
    enabled: !busy

    focus: true
    modal: true

    parent: T.Overlay.overlay
    width: parent.width

    padding: 0

    function openWithAnimOffset(yOffset) {

        if (yOffset)
            priv.yAnimOffset = yOffset
        control.open()
    }

    property list<BusyAction> actions

    T.Overlay.modal: Item {

        onOpacityChanged: {
            opacity = 1 // prevent the overlay from beeing hidden if dialog is getting closed
        }

        anchors.fill: parent

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
                    ScaleAnimator {
                        target: modalOverlay
                        from: 1
                        to: 0.85
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                },
                Transition {
                    from: "*"
                    to: "close"
                    ScaleAnimator {
                        target: modalOverlay
                        from: 0.85
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            ]

            ShaderEffectSource {
                id: headerBlur
                width: control.RootItem.header ? control.RootItem.header.width : 0
                height: control.RootItem.header ? control.RootItem.header.height : 0
                sourceItem: control.RootItem.header ? control.RootItem.header : null
                hideSource: true
            }

            ShaderEffectSource {
                id: mainBlur
                width: control.RootItem.contentItem ? control.RootItem.contentItem.width : 0
                height: control.RootItem.contentItem ? control.RootItem.contentItem.height : 0
                sourceItem: control.RootItem.contentItem ? control.RootItem.contentItem : null
                anchors.top: headerBlur.bottom
                hideSource: true
            }

            ShaderEffectSource {
                id: footerBlur
                width: control.RootItem.footer ? control.RootItem.footer.width : 0
                height: control.RootItem.footer ? control.RootItem.footer.height : 0
                sourceItem: control.RootItem.footer ? control.RootItem.footer : null
                anchors.top: mainBlur.bottom
                hideSource: true
            }
        }
    }

    header: ToolBar {

        y: control.yStart

        T.RoundButton {
            icon.source: "qrc:/icons/material_private/48x48/arrow-left.svg"
            flat: true
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                control.backButtonClicked()
            }
        }

        T.Label {
            id: titleLabel
            anchors.centerIn: parent
            text: control.title
            font.pixelSize: 16
            font.letterSpacing: 1.1
        }

        Row {
            id: titleActions
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: titleActions.x - (titleLabel.x + titleLabel.width) > 10
            Repeater {
                model: control.actions
                T.ToolButton {
                    action: control.actions[index]
                    flat: true
                    enabled: !action.busy
                    T.BusyIndicator {
                        width: 40
                        height: 40
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        visible: action.busy
                    }
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: !titleActions.visible
            Repeater {
                model: control.actions
                T.ToolButton {
                    action: control.actions[index]
                    flat: true
                    display: T.AbstractButton.IconOnly
                    enabled: !action.busy
                    T.BusyIndicator {
                        width: 40
                        height: 40
                        anchors.centerIn: parent.contentItem
                        visible: action.busy
                    }
                }
            }
        }

        T.ProgressBar {
            id: progressBar
            anchors.top: parent.bottom
            width: parent.width
            indeterminate: true

            visible: false

            T.Material.accent: T.Material.iconColor

            Component.onCompleted: {
                contentItem.implicitHeight = 2
            }

            background: Rectangle {
                implicitHeight: 2
                color: T.Material.iconColor
                opacity: 0.6
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
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: control.contentItem
                        property: "opacity"
                        duration: 400
                        easing.type: Easing.OutQuart
                        from: 0
                        to: 1
                    }
                    NumberAnimation {
                        target: control.header
                        property: "opacity"
                        duration: 400
                        easing.type: Easing.OutQuart
                        from: 0
                        to: 1
                    }
                }
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }

                ParallelAnimation {
                    NumberAnimation {
                        targets: [control]
                        property: "topPadding"
                        duration: 400
                        from: control.yStart
                        to: 0
                        easing.type: Easing.OutQuart
                    }
                    NumberAnimation {
                        targets: [control.header]
                        property: "y"
                        duration: 400
                        from: control.yStart
                        to: 0
                        easing.type: Easing.OutQuart
                    }
                }
            }
            NumberAnimation {
                property: "height"
                duration: 300
                from: 0.0
                to: control.parent.height
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "y"
                duration: 300
                from: priv.yAnimOffset
                to: 0
                easing.type: Easing.OutCubic
            }
            ColorAnimation {
                target: control.background
                property: "color"
                duration: 230
                from: control.T.Material.primaryColor
                to: Qt.lighter(control.T.Material.backgroundColor, 1.2)
                easing.type: Easing.OutCubic
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
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                ParallelAnimation {
                    NumberAnimation {
                        property: "height"
                        duration: 300
                        from: control.parent.height
                        to: 0.0
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "y"
                        duration: 300
                        from: 0
                        to: priv.yAnimOffset
                        easing.type: Easing.OutCubic
                    }
                    ColorAnimation {
                        target: control.background
                        property: "color"
                        duration: 230
                        from: Qt.lighter(control.T.Material.backgroundColor,
                                         1.2)
                        to: control.T.Material.backgroundColor
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        duration: 300
                        from: 1
                        to: 0
                        easing.type: Easing.OutCubic
                    }
                }
            }
            NumberAnimation {
                target: control.contentItem
                property: "opacity"
                duration: 400
                easing.type: Easing.OutQuart
                from: 1
                to: 0
            }
            NumberAnimation {
                target: control.header
                property: "opacity"
                duration: 400
                easing.type: Easing.OutQuart
                from: 1
                to: 0
            }
            NumberAnimation {
                targets: [control]
                property: "topPadding"
                duration: 400
                from: 0
                to: control.yStart
                easing.type: Easing.OutQuart
            }
            NumberAnimation {
                targets: [control.header]
                property: "y"
                duration: 400
                from: 0
                to: control.yStart
                easing.type: Easing.OutQuart
            }
        }
    }

    onAboutToShow: {

        control.header.opacity = 0
        control.contentItem.opacity = 0
        control.header.y = control.yStart
        control.topPadding = control.yStart
    }

    onOpened: {
        control.height = control.parent.height
        control.height = Qt.binding(function () {
            return control.parent.height
        })
    }

    QtObject {
        id: priv
        property real yAnimOffset: control.parent.height / 2
        property string state: ""
    }
}
