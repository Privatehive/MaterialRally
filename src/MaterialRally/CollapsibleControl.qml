import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Layouts as T

T.Control {

    id: control

    default property T.Item mainItem: T.Item{}
    property int animationDuration: 200
    property bool collapsed: false

    implicitHeight: collapsed ? 0 : contentItem.implicitHeight + control.topPadding + control.bottomPadding
    implicitWidth: contentItem.implicitWidth + control.leftPadding + control.rightPadding
    clip: collapsed

    opacity: collapsed ? 0 : 1

    T.Behavior on implicitHeight {
        T.NumberAnimation {
            duration: control.animationDuration
            easing.type: T.Easing.OutQuad
        }
    }

    T.Behavior on opacity {
        T.NumberAnimation {
            duration: control.animationDuration
            easing.type: T.Easing.OutQuad
        }
    }

    contentItem: control.mainItem
}
