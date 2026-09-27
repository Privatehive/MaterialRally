import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import MaterialRally as Rally

Rally.RallyApplicationWindow {

    id: root

    //SafeArea.additionalMargins.bottom: 40
    //SafeArea.additionalMargins.left: 40
    //SafeArea.additionalMargins.right: 40
    //SafeArea.additionalMargins.top: 40

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

        ListElement {
            title: qsTr("Flickable")
            iconName: "list-box"
            qmlSource: "FlickableGallery.qml"
        }
    }

    header: Rally.ToolBar
    {

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

        // Rally.SwipeView rather than the stock one: a stock (Flickable-based) horizontal
        // SwipeView hijacks vertical drags meant for the ScrollView around it, because
        // QQuickFlickable decides to steal from |dx| alone without ever comparing it to |dy|,
        // and once it has the grab an ancestor cannot take it back. Rally.SwipeView is
        // DragHandler-based, and a DragHandler refuses to activate when the drag is mostly
        // along its disabled axis.
        Rally.SwipeView {

            id: view
            width: parent.width

            Repeater {

                model: mainMenuModel

                Loader {
                    id: loader
                    required property int index
                    required property string qmlSource
                    // Rally.SwipeView has no attached isCurrentItem/isNextItem/isPreviousItem -
                    // compare against currentIndex directly, which is the same "current plus its
                    // two neighbours" window.
                    active: Math.abs(loader.index - view.currentIndex) <= 1
                    asynchronous: true
                    source: Qt.resolvedUrl(loader.qmlSource)
                    visible: status == Loader.Ready
                }
            }
        }
    }
}
