import QtQuick
import MaterialRally as Rally

// A vertical Rally.Flickable (a feed) with a horizontal Rally.Flickable (a carousel) nested in it:
// 300px of feed, the 200px carousel (10 cells of 150px, contentWidth 1500), then 2500px of feed.
// With the feed at rest the carousel spans y 300..500.
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
                id: carousel
                width: feed.width
                height: 200
                flickableDirection: Flickable.HorizontalFlick
                contentWidth: cells.width

                Row {
                    id: cells

                    Repeater {
                        model: 10

                        Rectangle {
                            required property int index
                            width: 150
                            height: 200
                            color: index % 2 ? "#8a5f3a" : "#8a3a5f"

                            Text {
                                anchors.centerIn: parent
                                text: parent.index
                                color: "white"
                                font.pixelSize: 32
                            }
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
