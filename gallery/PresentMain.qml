import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import MaterialRally 1.0 as Rally

Page {

    clip: true

    ListModel {

        id: mainMenuModel

        ListElement {
            title: qsTr("Page 1")
            iconSrc: "/icons/ic_settings.svg"
            defaultChecked: true
            qmlSource: "BlankPage.qml"
        }

        ListElement {
            title: qsTr("Page 2")
            iconSrc: "/icons/ic_settings.svg"
            qmlSource: "BlankPage.qml"
        }

        ListElement {
            title: qsTr("Page 3")
            iconSrc: "/icons/ic_settings.svg"
            qmlSource: "BlankPage.qml"
        }

        ListElement {
            title: qsTr("Page 4")
            iconSrc: "/icons/ic_settings.svg"
            qmlSource: "BlankPage.qml"
        }

        ListElement {
            title: qsTr("Page 5")
            iconSrc: "/icons/ic_settings.svg"
            qmlSource: "BlankPage.qml"
        }
    }

    header: Rally.ToolBar {

        background: Rectangle {
            color: Qt.lighter(Material.backgroundColor, 1.2)
        }

        Rally.TabBarFolding {

            width: parent.width

            onIndexSelected: index => view.currentIndex = index
            currentIndex: view.currentIndex

            Repeater {
                model: mainMenuModel

                Rally.TabButtonFolding {

                    checked: defaultChecked
                    icon.source: iconSrc
                    text: title
                }
            }
        }
    }

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