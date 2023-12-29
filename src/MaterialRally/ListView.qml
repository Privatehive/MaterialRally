import QtQuick as T
import QtQuick.Controls as T

T.ListView {

    id: control

    signal clicked(var index)

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    interactive: false

    T.Rectangle {
        anchors.fill: parent
        z: -1
        color: "#393942"
        radius: control.T.Material.roundedScale
    }

    add: T.Transition {
        id: transition
        T.SequentialAnimation {
            T.PropertyAction {
                property: "opacity"
                value: 0
            }
            T.PropertyAction {
                property: "scale"
                value: 0.9
            }
            T.PauseAnimation {
                duration: transition.T.ViewTransition.index * 20
            }
            T.NumberAnimation {
                properties: "opacity, scale"
                to: 1.0
                duration: 200
                easing.type: T.Easing.OutQuad
            }
        }
    }

    displaced: T.Transition {
        id: transition1
        T.SequentialAnimation {
            T.PauseAnimation {
                duration: transition1.ViewTransition.index * 20
            }
            T.NumberAnimation {
                properties: "opacity, scale"
                to: 1.0
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
