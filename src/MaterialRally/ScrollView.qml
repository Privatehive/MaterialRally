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

    \brief A vertically scrolling view for user-defined content.

    ScrollView provides vertical scrolling for its child items. The children are stacked in a
    \l [QML] {QtQuick::Column}{Column} that spans the width of the view, and are scrolled by a
    \l Flickable. The view can be scrolled as soon as the content is higher than the view.

    ScrollView adapts to the input device the user last interacted with (see
    \c {Rally.RootItem.isTouchInput}):
    \list
    \li With \b mouse input, the view is scrolled with the mouse wheel or the scroll bar. The
        scroll bar is interactive and gets wider while hovered.
    \li With \b touch input, the view is scrolled by swiping and flicking the content, and the
        scroll bar becomes a thin, non-interactive indicator. When the content is dragged past
        its top or bottom, it is stretched slightly (see \l boundsStretch).
    \endlist

    The scroll bar is only shown if the content is higher than the view.

    ScrollView works well with nested horizontal swiping, e.g. a \l SwipeView inside a
    ScrollView: a vertical drag scrolls the view, a horizontal one swipes the pages.

    \image scroll-view.png "ScrollView"

    \section1 Example

    Children are placed below each other. Bind their width to the view's width, so they do not
    need to scroll horizontally:

    \qml
    import QtQuick
    import QtQuick.Controls
    import MaterialRally as Rally

    Rally.ScrollView {
        anchors.fill: parent

        Rally.GroupBox {
            width: parent.width
            title: qsTr("Accounts")
            // ...
        }

        Rally.GroupBox {
            width: parent.width
            title: qsTr("Bills")
            // ...
        }

        Repeater {
            model: 20
            delegate: Label {
                required property int index
                text: qsTr("Line %1").arg(index)
            }
        }
    }
    \endqml

    A layout can be used as the single child as well. Its implicit height determines how far the
    view can be scrolled:

    \qml
    Rally.ScrollView {
        anchors.fill: parent

        ColumnLayout {
            width: parent.width
            spacing: 10

            Rally.TextField { Layout.fillWidth: true }
            Rally.TextArea { Layout.fillWidth: true }
        }
    }
    \endqml

    \sa Flickable, ScrollablePage
*/
T.Control {

    id: control


    /*!
      \qmlproperty bool ScrollView::reloadable
      \default false

      \warning Not usable yet - this feature is still in development.

      If \c true, the content can be dragged down past its top (touch input only) and a reload
      indicator appears. Dragging it further than a threshold and releasing it is meant to
      trigger a reload.
    */
    property bool reloadable: false


    /*!
      \qmlproperty bool ScrollView::boundsStretch
      \default Rally.RootItem.isTouchInput

      If \c true, the content is stretched slightly when it is dragged past its top or bottom,
      to show the user that the end of the content has been reached. By default this is only
      enabled while the user interacts by touch. Has no effect if the content is not higher than
      the view.
    */
    property bool boundsStretch: Rally.RootItem.isTouchInput

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)


    /*!
      \qmlproperty list<Item> ScrollView::otherChildren

      The scrolling content. This is the default property, so child items can simply be declared
      inside the ScrollView. They are stacked in a column that spans the width of the view.
    */
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

    // A wrapper Item, not the Flickable directly, so the ScrollBar can be a *sibling* of the
    // Flickable. It cannot be a child of either the ScrollView (whose default property is
    // otherChildren, i.e. the scrolling Column) or of Rally.Flickable (whose default property is
    // flickableChildren, i.e. the scrolling content) without scrolling along with the content.
    contentItem: T.Item {

        id: viewport

        // These must live here rather than on the Flickable: QQuickControlPrivate::getContentWidth()
        // reads contentItem->implicitWidth(), so a bare wrapper would report 0 and collapse
        // ScrollView's own implicit size.
        implicitWidth: flickContent.implicitWidth
        implicitHeight: flickContent.implicitHeight

        Rally.Flickable {

            id: flickable

            anchors.fill: parent

            // The old stock Flickable set clip: false. Clipping here is correct and costs nothing
            // visually: the Scale squash never escapes the viewport (a beginning-overscroll uses
            // origin.y 0 and grows downward, an end-overscroll uses origin.y flickContent.height
            // and grows upward), and main.qml/TestDialog.qml already clip at the ScrollView root.
            clip: true

            readonly property bool canScroll: flickable.contentHeight > flickable.height
            readonly property real verticalOvershootNormalized: flickable.verticalOvershoot * 2 / flickable.height

            contentHeight: Math.max(flickContent.implicitHeight, flickable.height)

            boundsMovement: T.Flickable.StopAtBounds
            boundsBehavior: control.boundsStretch
                            && flickable.canScroll ? T.Flickable.DragOverBounds : T.Flickable.StopAtBounds

            // The content squash below is this ScrollView's overscroll feedback; Rally.Flickable's
            // own Android edge glow on top of it would be doubled-up feedback.
            overscrollGlow: false

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

        // Rally.Flickable is a plain Item, so QtQuick.Controls' attached ScrollBar.vertical - which
        // only attaches to a QQuickFlickable - is not available. Driven manually instead; the
        // bindings reproduce QQuickFlickableVisibleArea::updateVisible() and the write-back
        // reproduces QQuickScrollBarAttachedPrivate::scrollVertical().
        T.ScrollBar {

            id: scrollBar

            // orientation is left at ScrollBar's own default, Qt.Vertical.
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            interactive: Rally.RootItem.isMouseInput
            policy: flickable.canScroll ? T.ScrollBar.AlwaysOn : T.ScrollBar.AlwaysOff

            hoverEnabled: true

            size: flickable.contentHeight > 0 ? flickable.height / flickable.contentHeight : 1

            // Deliberately the *unclamped* position: adding the overshoot back in is what makes the
            // handle squash against the end of the track during an overscroll, exactly as the
            // attached ScrollBar did (visibleArea.yPosition is computed from the unclamped value).
            position: flickable.contentHeight > 0
                      ? (flickable.contentY + flickable.verticalOvershoot) / flickable.contentHeight
                      : 0

            onPositionChanged: {
                const maxY = Math.max(0, flickable.contentHeight - flickable.height)
                const cy = Math.max(0, Math.min(scrollBar.position * flickable.contentHeight, maxY))
                // The fuzzy guard is what breaks the binding loop: when the change came *from* the
                // flickable, cy already equals contentY and nothing is written back. ScrollBar's own
                // handleMove() clamps to [0, 1-size], so during a bar drag this clamp is a no-op and
                // the two expressions stay exact inverses.
                if (Math.abs(cy - flickable.contentY) > 0.001) {
                    // Grabbing the bar mid-fling would otherwise leave the fling ticker and this
                    // write fighting over contentY on every frame.
                    flickable.cancelFlick()
                    flickable.contentY = cy
                }
            }

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
    }
}
