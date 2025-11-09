import QtQml as T
import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally as Rally
import "./private" as RallyPrivate


/*!
    \qmltype ScrollView
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Control

    \brief Scrollable view.

    ScrollView provides vertical scrolling for user-defined content. A vertical scrollbar is displayed if the content height is greater than the height of the ScrolView - otherwise it is hidden.
    If Mouse input is detected, the view can only be scrolled via mouse wheel or via the scrollbar.
    If Touch input is detected, the view can only be swiped and the scrollbar becomes a non-interactive indicator.

    \image scroll-view.png "ScrollView"
*/
T.Control {

    id: control


    /*!
      \qmlproperty bool ScrollView::reloadable
      \default false

      Not usable right now - in development!

      Only works with Touch input!

      If \a reloadable equals true, the ScrollView can be dragged over its top bounds. Then a reload indicator becomes visible. If draged further until the reload indicator exceeds the threshold the user can release the drag and the reload signal is emitted.
    */
    property bool reloadable: false


    /*!
      \qmlproperty bool ScrollView::boundsStretch
      \default Rally.RootItem.isTouchInput

      If \boundsStretch equals true, the ScrollView will stretch its content as soon as the top or bottom bounds are reached. This is useful for touch input to indicate that the bounds have been reached.
    */
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
