import QtQuick
import MaterialRally as Rally

// A full-window Rally.ScrollView over 4000px of content, for its ScrollBar along the right edge.
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    Rally.ScrollView {
        id: scroll
        anchors.fill: parent

        Rectangle {
            width: scroll.width
            implicitHeight: 4000
            gradient: Gradient {
                GradientStop { position: 0; color: "#3a5f8a" }
                GradientStop { position: 1; color: "#5a8f5a" }
            }
        }
    }
}
