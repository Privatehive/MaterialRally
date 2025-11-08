import QtQml as T
import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally as Rally
import "./private" as RallyPrivate

T.Control {

    id: control

    property bool reloadable: false
    property bool boundsStretch: Rally.RootItem.isTouchInput

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)

    default property list<T.Item> otherChildren: []

    RallyPrivate.ReloadIndicator {

        visible: control.reloadable && preparing
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height + -flickable.verticalOvershoot / 2
        startAngle: -flickable.verticalOvershoot / 500 - 0.1
        endAngle: -flickable.verticalOvershoot / 100 - 0.1
        color: remainingAngle > 0.1 ? Qt.alpha("white", 0.5) : "white"

        property bool reloading: !control.movingVertically && remainingAngle <= 0.1

        property bool preparing: flickable.draggingVertically && flickable.atYBeginning
    }

    contentItem: T.Flickable {

        id: flickable

        readonly property bool canScroll: flickable.contentHeight > flickable.height
        readonly property real verticalOvershootNormalized: flickable.verticalOvershoot * 2 / flickable.height

        clip: false

        implicitWidth: flickContent.implicitWidth
        implicitHeight: flickContent.implicitHeight

        contentWidth: flickable.width
        contentHeight: Math.max(flickContent.implicitHeight, flickable.height)

        flickDeceleration: 200
        maximumFlickVelocity: Number.MAX_VALUE
        synchronousDrag: true
        flickableDirection: T.Flickable.VerticalFlick
        boundsMovement: T.Flickable.StopAtBounds
        boundsBehavior: control.boundsStretch
                        && flickable.canScroll ? T.Flickable.DragOverBounds : T.Flickable.StopAtBounds

        T.Component.onCompleted: {
            if ("acceptedButtons" in flickable) {
                flickable.acceptedButtons = Qt.binding(() => {
                                                           if (Rally.RootItem.isTouchInput) {
                                                               return Qt.LeftButton
                                                           }
                                                           return Qt.NoButton
                                                       })
            }
        }

        T.ScrollBar.vertical: T.ScrollBar {

            id: scrollBar
            interactive: Rally.RootItem.isMouseInput
            policy: flickable.canScroll ? T.ScrollBar.AlwaysOn : T.ScrollBar.AlwaysOff

            hoverEnabled: true

            contentItem: T.Item {
                T.Rectangle {
                    height: parent.height
                    width: scrollBar.interactive && (scrollBar.hovered || scrollBar.pressed) ? 6 : 3
                    radius: width / 2
                    anchors.right: parent.right
                    anchors.rightMargin: scrollBarBg.width / 2 - width / 2
                    color: scrollBar.pressed ? control.T.Material.accent : T.Material.color(T.Material.Grey)
                }
            }

            background: T.Item {
                implicitWidth: scrollBar.interactive && (scrollBar.hovered || scrollBar.pressed) ? 12 : 9

                T.Rectangle {

                    id: scrollBarBg

                    T.Behavior on width {
                        T.NumberAnimation {
                            duration: 60
                            easing.type: T.Easing.OutQuad
                        }
                    }

                    anchors.right: parent.right
                    width: parent.width
                    height: parent.height
                    color: T.Material.color(T.Material.Grey)
                    opacity: 0.3
                    visible: scrollBar.interactive && (scrollBar.hovered || scrollBar.pressed)
                }
            }
        }

        T.Column {

            id: flickContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            children: control.otherChildren

            function easeOutQuad(x) {
                return 1 - Math.pow(1 - x, 4)
            }

            transform: [
                T.Scale {
                    origin.x: flickContent.width / 2
                    origin.y: {
                        if (flickable.verticalOvershoot < 0) {
                            // dragged beyond the beginning
                            return 0
                        } else if (flickable.verticalOvershoot > 0) {
                            // dragged beyond the beginning
                            return flickContent.height
                        } else {
                            return 0
                        }
                    }
                    yScale: {
                        if (flickable.verticalOvershoot < 0 && !control.reloadable) {
                            // dragged beyond the beginning
                            return 1 + flickContent.easeOutQuad(-1 * flickable.verticalOvershootNormalized) / 20
                        } else if (flickable.verticalOvershoot > 0) {
                            // dragged beyond the beginning
                            return 1 + flickContent.easeOutQuad(flickable.verticalOvershootNormalized) / 20
                        } else {
                            return 1
                        }
                    }
                }
            ]
        }
    }
}
