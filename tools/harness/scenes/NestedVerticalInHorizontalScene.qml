import QtQuick
import MaterialRally as Rally

// A horizontal Rally.Flickable of three 400px panes (contentWidth 1200); the first pane is a
// vertical Rally.Flickable list of 30 rows of 100px (contentHeight 3000).
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.Flickable {
        id: outer
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: panes.width

        Row {
            id: panes

            Rally.Flickable {
                id: list
                width: outer.width
                height: outer.height
                contentHeight: rows.height

                Column {
                    id: rows
                    width: list.width

                    Repeater {
                        model: 30

                        Rectangle {
                            required property int index
                            width: rows.width
                            height: 100
                            color: index % 2 ? "#3a5f8a" : "#5a8f5a"

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
                width: outer.width
                height: outer.height
                color: "#8a3a3a"
            }

            Rectangle {
                width: outer.width
                height: outer.height
                color: "#3a3a8a"
            }
        }
    }
}
