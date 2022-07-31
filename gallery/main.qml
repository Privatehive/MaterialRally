import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import MaterialRally 1.0 as Rally
import QtQuick.Layouts 1.12

ApplicationWindow {

    id: root

    visible: true
    width: 640
    height: 480
    title: qsTr("Minimal Qml")

    header: ToolBar {

        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "Title"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("⋮")
                onClicked: menu.open()
            }
        }
    }

    Row {

        spacing: 0

        Rally.ScrollablePage {

            width: root.width * 0.20
            height: root.height
            leftPadding: 0
            rightPadding: 0

            Column {
                Repeater {
                    model: ListModel {
                        ListElement {
                            menuText: "Main"
                        }
                        ListElement {
                            menuText: "Main"
                        }
                        ListElement {
                            menuText: "Main"
                        }
                    }

                    ItemDelegate {
                        width: parent.width
                        text: menuText
                        highlighted: true
                    }
                }
            }
        }

        Rectangle {
            height: root.height
            width: 1
            color: Material.backgroundColor
        }

        Rally.ScrollablePage {

            width: root.width * 0.80
            height: root.height

            ColumnLayout {

                width: parent.width

                Presenter {

                    Layout.fillWidth: true

                    title: qsTr("Main Page")
                    file: ":/PresentMain.qml"
                }
            }
        }
    }
}
