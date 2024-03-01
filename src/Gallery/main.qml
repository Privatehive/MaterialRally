import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MaterialRally as Controls

Controls.RallyRootPage {

    id: root

    Label {

        id: sizeLabel
        padding: 10
        text: "w: " + root.width + " h: " + root.height
        anchors.centerIn: root.contentItem
        z: 1

        Connections {
            target: root
            function onWidthChanged() {
                sizeLabel.visible = true
                sizeLabelTimer.restart()
            }
        }

        Timer {
            id: sizeLabelTimer
            interval: 1000
            onTriggered: {
                parent.visible = false
            }
        }

        background: Rectangle {
            color: "black"
            opacity: 0.5
            radius: 4
        }
    }

    ListModel {

        id: mainMenuModel

        ListElement {
            title: qsTr("Buttons")
            iconName: "button-cursor"
            defaultChecked: true
            qmlSource: "ButtonsGallery.qml"
        }

        ListElement {
            title: qsTr("Lists")
            iconName: "list-box"
            qmlSource: "ListsGallery.qml"
        }
    }

    header: Controls.ToolBar {

        Controls.TabBarFolding {

            id: tabBar
            anchors.centerIn: parent
            width: Math.min(parent.width, 500)

            onIndexSelected: index => view.currentIndex = index
            currentIndex: view.currentIndex

            Repeater {
                model: mainMenuModel
                Controls.TabButtonFolding {

                    checked: defaultChecked
                    icon.name: iconName
                    text: title
                }
            }
        }

        ProgressBar {
            anchors.top: parent.bottom
            width: parent.width
            indeterminate: true

            visible: false //loader.status != Loader.Ready

            Material.accent: Material.iconColor

            Component.onCompleted: {
                contentItem.implicitHeight = 2
            }

            background: Rectangle {
                implicitHeight: 2
                color: Material.iconColor
                opacity: 0.6
            }
        }
    }

    ScrollView {

        anchors.fill: parent

        contentWidth: width
        contentHeight: Math.max(view.implicitHeight, height)

        ScrollBar.vertical.policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.interactive: false

        SwipeView {

            id: view
            anchors.fill: parent

            Repeater {
                model: mainMenuModel
                Loader {
                    id: loader
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem
                            || SwipeView.isPreviousItem
                    asynchronous: true
                    source: Qt.resolvedUrl(qmlSource)
                    visible: status == Loader.Ready
                }
            }
        }
    }
}
