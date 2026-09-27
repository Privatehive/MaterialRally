import QtQuick
import MaterialRally as Rally

// A full-window vertical Rally.Flickable over 40 numbered 100px stripes (contentHeight 4000),
// so contentY maps directly onto what is visible: stripe N starts at y = N * 100.
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: stripes.height

        Column {
            id: stripes
            width: flick.width

            Repeater {
                model: 40

                Rectangle {
                    required property int index
                    width: stripes.width
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
}
