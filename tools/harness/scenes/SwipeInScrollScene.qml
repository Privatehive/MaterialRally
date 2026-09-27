import QtQuick
import MaterialRally as Rally

// The nesting the library is meant to support: a horizontal Rally.SwipeView of three tall pages
// inside a vertical Rally.ScrollView. Each page is 2000px tall so the ScrollView can scroll
// (implicitHeight, because Rally.SwipeView sizes itself from the current page's implicitHeight).
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.ScrollView {
        id: scroll
        anchors.fill: parent

        Rally.SwipeView {
            id: view
            width: scroll.width

            Repeater {
                model: 3

                Rectangle {
                    required property int index
                    objectName: "page" + index
                    width: view.width
                    implicitHeight: 2000
                    gradient: Gradient {
                        GradientStop { position: 0; color: ["#8a3a3a", "#3a8a3a", "#3a3a8a"][index] }
                        GradientStop { position: 1; color: "#202020" }
                    }

                    Text {
                        x: 20
                        y: 20
                        text: "page " + parent.index
                        color: "white"
                        font.pixelSize: 32
                    }
                }
            }
        }
    }
}
