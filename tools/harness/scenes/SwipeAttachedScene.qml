import QtQuick
import MaterialRally as Rally

// A Rally.SwipeView of four pages - two declared inline, two from a Repeater - each exposing its
// attached SwipeView properties, plus an item inside page 0 that is not a page itself.
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.SwipeView {
        id: view
        anchors.fill: parent

        Rectangle {
            id: page0
            readonly property int attachedIndex: Rally.SwipeView.index
            readonly property bool current: Rally.SwipeView.isCurrentItem
            readonly property bool next: Rally.SwipeView.isNextItem
            readonly property bool previous: Rally.SwipeView.isPreviousItem
            readonly property Item attachedView: Rally.SwipeView.view
            color: "#8a3a3a"

            Rectangle {
                id: inner
                readonly property int attachedIndex: Rally.SwipeView.index
                readonly property Item attachedView: Rally.SwipeView.view
                width: 50
                height: 50
            }
        }

        Rectangle {
            id: page1
            readonly property int attachedIndex: Rally.SwipeView.index
            readonly property bool current: Rally.SwipeView.isCurrentItem
            readonly property bool next: Rally.SwipeView.isNextItem
            readonly property bool previous: Rally.SwipeView.isPreviousItem
            color: "#3a8a3a"
        }

        Repeater {
            id: repeater
            model: 2

            Rectangle {
                required property int index
                objectName: "page" + (index + 2)
                readonly property int attachedIndex: Rally.SwipeView.index
                readonly property bool current: Rally.SwipeView.isCurrentItem
                readonly property bool next: Rally.SwipeView.isNextItem
                readonly property bool previous: Rally.SwipeView.isPreviousItem
                color: "#3a3a8a"
            }
        }
    }
}
