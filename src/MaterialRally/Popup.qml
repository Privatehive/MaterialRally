import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally

T.Dialog {

    id: control

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

    T.Overlay.modal: Item {}

    header: ToolBar {

        y: control.yStart

        T.RoundButton {
            icon.source: "qrc:/icons/material_private/48x48/arrow-left.svg"
            flat: true
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                control.close()
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

    exit: Transition {
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
                    from: Qt.lighter(control.T.Material.backgroundColor, 1.2)
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

    ScaleAnimator {
        id: animIn
        from: 1
        to: 0.85
        duration: 200
        running: false
        easing.type: Easing.InQuad
    }

    ScaleAnimator {
        id: an1mOut
        from: 0.85
        to: 1
        duration: 250
        running: false
        easing.type: Easing.OutQuad
    }

    onAboutToShow: {

        control.header.opacity = 0
        control.contentItem.opacity = 0
        control.header.y = control.yStart
        control.topPadding = control.yStart
        animIn.target = control.RootItem.contentItem
        animIn.start()
    }

    onAboutToHide: {

        animIn.stop()
        an1mOut.target = control.RootItem.contentItem
        an1mOut.start()
    }

    onOpened: {
        control.height = control.parent.height
        control.height = Qt.binding(function () {
            return control.parent.height
        })
    }

    onClosed: {

        control.opacity = 1
        control.RootItem.contentItem.scale = 1
    }

    QtObject {
        id: priv
        property real yAnimOffset: control.parent.height / 2
    }
}
