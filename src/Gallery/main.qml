import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MaterialRally as Rally

Rally.RallyRootPage {

    id: root

    SafeArea.additionalMargins.bottom: 40
    SafeArea.additionalMargins.left: 40
    SafeArea.additionalMargins.right: 40
    SafeArea.additionalMargins.top: 40

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

    header: Rally.ToolBar {

        Rally.TabBarFolding {

            id: tabBar
            anchors.centerIn: parent
            width: Math.min(parent.width, 500)

            onIndexSelected: index => view.currentIndex = index
            currentIndex: view.currentIndex

            Repeater {
                model: mainMenuModel
                Rally.TabButtonFolding {

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

    Rally.ScrollView {

        anchors.fill: parent

        reloadable: false
        clip: true

        SwipeView {

            id: view
            width: parent.width

            Repeater {

                model: mainMenuModel

                Loader {
                    id: loader
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                    asynchronous: true
                    source: Qt.resolvedUrl(qmlSource)
                    visible: status == Loader.Ready
                }
            }
        }
    }
}
