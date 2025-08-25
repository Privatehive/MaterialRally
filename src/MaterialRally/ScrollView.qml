import QtQml as T
import QtQuick as T
import QtQuick.Controls as T
import MaterialRally as Rally
import "./private" as RallyPrivate

T.Control {

    id: control

    property bool reloadable: false

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)

    default property list<T.Item> otherChildren: []

    clip: true

    RallyPrivate.ReloadIndicator {

        visible: control.reloadable && preparing
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height + -flickable.verticalOvershoot / 2
        startAngle: -flickable.verticalOvershoot / 500 - 0.1
        endAngle: -flickable.verticalOvershoot / 100 - 0.1
        color: remainingAngle > 0.1 ? Qt.alpha("white", 0.5) : "white"

        property bool reloading: !control.movingVertically && remainingAngle <= 0.1

        property bool preparing: flickable.draggingVertically && flickable.atYBeginning

        onPreparingChanged: {
            console.log("preparing")
        }

        onReloadingChanged: {
            console.log("reloading")
        }
    }

    contentItem: T.Flickable {

        id: flickable

        readonly property bool canScroll: flickable.contentHeight > flickable.height
        readonly property real verticalOvershootNormalized: flickable.verticalOvershoot * 2 / flickable.height

        //clip: true
        implicitWidth: flickContent.implicitWidth
        implicitHeight: flickContent.implicitHeight

        contentWidth: flickable.width
        contentHeight: Math.max(flickContent.implicitHeight, flickable.height)

        flickDeceleration: 200
        maximumFlickVelocity: Number.MAX_VALUE
        synchronousDrag: true
        flickableDirection: T.Flickable.VerticalFlick
        boundsMovement: T.Flickable.StopAtBounds
        boundsBehavior: T.Flickable.DragOverBounds

        T.ScrollBar.vertical: T.ScrollBar {

            id: scrollBar
            interactive: false //Rally.RootItem.isMouseInput
            policy: flickable.canScroll ? T.ScrollBar.AlwaysOn : T.ScrollBar.AlwaysOff
        }

        T.Column {

            id: flickContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: scrollBar.interactive && flickable.canScroll ? scrollBar.width : 0

            clip: true

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
