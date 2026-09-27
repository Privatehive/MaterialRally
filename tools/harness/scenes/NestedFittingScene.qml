import QtQuick
import MaterialRally as Rally

// A vertical Rally.Flickable (a feed) with a vertical Rally.Flickable nested in it whose content
// fits exactly (contentHeight == height), so the nested one has nothing to scroll. 300px of feed,
// the 200px nested Flickable, then 2500px of feed. With the feed at rest the nested one spans
// y 300..500.
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.Flickable {
        id: outer
        anchors.fill: parent
        contentHeight: feed.height

        Column {
            id: feed
            width: outer.width

            Rectangle {
                width: feed.width
                height: 300
                color: "#5a8f5a"
            }

            Rally.Flickable {
                id: inner
                width: feed.width
                height: 200
                contentHeight: rows.height

                Column {
                    id: rows
                    width: inner.width

                    Repeater {
                        model: 4

                        Rectangle {
                            required property int index
                            width: rows.width
                            height: 50
                            color: index % 2 ? "#8a5f3a" : "#8a3a5f"
                        }
                    }
                }
            }

            Rectangle {
                width: feed.width
                height: 2500
                gradient: Gradient {
                    GradientStop { position: 0; color: "#3a5f8a" }
                    GradientStop { position: 1; color: "#202020" }
                }
            }
        }
    }
}
