import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Controls.Material.impl as T
import MaterialRally

T.ItemDelegate {

    id: control

    property bool showChevron: false

    rightPadding: showChevron ? 10 + chevronIcon.width : padding
    width: T.ListView.view.width
    height: Math.max(contentItem.implicitHeight,
                     background.implicitHeight) + topPadding + bottomPadding

    bottomInset: 1

    onClicked: {

        if(typeof T.ListView.view.clicked === 'function') {
            T.ListView.view.clicked(index)
        }
    }

    background: T.Rectangle {

        implicitHeight: control.T.Material.delegateHeight
        color: control.highlighted ? control.T.Material.listHighlightColor : "transparent"

        T.Ripple {
            width: parent.width
            height: parent.height

            clip: visible
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus
                                || control.hovered)
            color: control.T.Material.rippleColor
        }

        Icon {
            id: chevronIcon
            visible: control.showChevron
            icon.source: "qrc:/icons/material_private/48x48/chevron-right.svg"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        T.Rectangle {
            height: 1
            color: T.Material.backgroundColor
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: control.leftPadding
            anchors.rightMargin: control.rightPadding
        }
    }
}
