import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally

T.Dialog {

    id: control

    property alias busy: progressBar.visible

    signal backButtonClicked

    T.Material.elevation: 0
    T.Material.roundedScale: T.Material.NotRounded

    enabled: !busy

    focus: true
    modal: true

    parent: T.Overlay.overlay
    width: parent.width

    margins: 0
    padding: 0

    function openWithAnimOffset(yOffset) {

        if (yOffset)
            priv.yAnimOffset = yOffset
        control.open()
    }

    property list<BusyAction> actions

    default property list<QtObject> content: []

    Component.onCompleted: {
        if (control.RootItem.root.SafeArea) {
            control.leftPadding = Qt.binding(() => {
                                                 return control.RootItem.root.SafeArea.margins.left
                                             })
            control.rightPadding = Qt.binding(() => {
                                                  return control.RootItem.root.SafeArea.margins.right
                                              })
            control.bottomPadding = Qt.binding(() => {
                                                   return control.RootItem.root.SafeArea.margins.bottom
                                               })
            control.topPadding = Qt.binding(() => {
                                                return control.RootItem.root.SafeArea.margins.top
                                            })
        }
    }

    onFooterChanged: {
        if (control.footer && content) {
            // reassign footer to RallyRootPage so the SafeArea applies
            const footer = control.footer
            control.footer = null
            content.footer = footer
        }
    }

    onHeaderChanged: {
        if (control.header && content) {
            // reassign header to RallyRootPage so the SafeArea applies
            const header = control.header
            control.header = null
            content.header = header
        }
    }

    contentItem: T.Page {

        id: content

        padding: 0

        contentData: control.content

        background: Item {}

        header: ToolBar {

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
    }

    T.Overlay.modal: Item {

        id: modalOverlayRoot

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
                id: mainBlur
                anchors.fill: parent
                live: false
                sourceItem: control.RootItem.contentItem ? control.RootItem.contentItem : null
                hideSource: true
                sourceRect: control.RootItem.contentItem ? mainBlur.mapToItem(control.RootItem.contentItem, 0, 0,
                                                                              width, height) : null
            }
        }
    }

    header: Item {}

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
                NumberAnimation {
                    target: control.contentItem
                    property: "opacity"
                    duration: 400
                    easing.type: Easing.OutQuart
                    from: 0
                    to: 1
                }
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                NumberAnimation {
                    targets: [control.contentItem, control.contentItem.header, control.contentItem.footer]
                    property: "topPadding"
                    duration: 400
                    from: priv.yStart
                    to: 0
                    easing.type: Easing.OutQuart
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
                targets: [control.contentItem, control.contentItem.header, , control.contentItem.footer]
                property: "topPadding"
                duration: 400
                from: 0
                to: priv.yStart
                easing.type: Easing.OutQuart
            }
        }
    }

    onAboutToShow: {

        control.contentItem.opacity = 0
        if (content) {
            content.topPadding = priv.yStart
            if (content.header && content.header.hasOwnProperty("topPadding"))
                content.header.topPadding = priv.yStart
            if (content.footer && content.footer.hasOwnProperty("topPadding"))
                content.footer.topPadding = priv.yStart
        }
    }

    onOpened: {
        control.height = control.parent.height
        control.height = Qt.binding(function () {
            return control.parent.height
        })
    }

    QtObject {
        id: priv
        readonly property real yStart: 80
        property real yAnimOffset: control.parent.height / 2
        property string state: ""
    }
}
