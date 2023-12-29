import QtQuick as T
import QtQuick.Controls as T

T.ScrollView {

    id: control

    contentWidth: availableWidth

    property bool enableVerticalScrollBar: true

    readonly property bool showVerticalScrollBar: contentHeight > height
                                                  && enableVerticalScrollBar

    readonly property real verticalScrollBarEffectiveWidth: control.T.ScrollBar.vertical.interactive
                                                            && showVerticalScrollBar ? control.T.ScrollBar.vertical.width : 0

    T.ScrollBar.vertical.policy: showVerticalScrollBar ? T.ScrollBar.AlwaysOn : T.ScrollBar.AlwaysOff
    T.ScrollBar.horizontal.policy: T.ScrollBar.AlwaysOff
    T.ScrollBar.horizontal.interactive: false

    rightPadding: verticalScrollBarEffectiveWidth

    T.Behavior on rightPadding {
        T.NumberAnimation { duration: 200 }
    }

    T.Component.onCompleted: {

        control.contentItem.boundsMovement = Qt.binding(() => {
                                                            if (control.T.ScrollBar.vertical.interactive) {
                                                                return T.Flickable.StopAtBounds
                                                            } else {
                                                                return T.Flickable.FollowBoundsBehavior
                                                            }
                                                        })
        control.contentItem.boundsBehavior = Qt.binding(() => {
                                                            if (control.T.ScrollBar.vertical.interactive) {
                                                                return T.Flickable.StopAtBounds
                                                            } else {
                                                                return T.Flickable.DragAndOvershootBounds
                                                            }
                                                        })
    }
}
