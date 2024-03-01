import QtQuick
import QtQml
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MaterialRally as Controls

Pane {

    ColumnLayout {

        width: parent.width

        Button {
            text: "dialog"
            onClicked: Controls.Helper.createDialog(Qt.resolvedUrl(
                                                        "TestDialog.qml"))
        }

        Controls.GroupBox {

            Layout.fillWidth: true
            title: qsTr("Test")

            mainAction: Controls.BusyAction {

                checkable: false
                text: "test"
            }

            ColumnLayout {

                Layout.fillWidth: true

                Label {
                    text: "asdfasdf"
                }

                Label {
                    text: "asdfasdf"
                }

                Label {
                    text: "asdfasdf"
                }

                Label {
                    text: "asdfasdf"
                }
            }
        }

        Controls.ComboBox {

            Layout.fillWidth: true

            placeholderText: qsTr("terst")
            model: [{
                    "text": "Element1"
                }, {
                    "text": "Element2"
                }, {
                    "text": "Element3"
                }]
            textRole: "text"
        }

        ComboBox {

            Layout.fillWidth: true

            model: [{
                    "text": "Element1"
                }, {
                    "text": "Element2"
                }, {
                    "text": "Element3"
                }]
            textRole: "text"
        }

        TextField {

            Material.containerStyle: Material.Filled
            placeholderText: "terst"
        }

        Controls.FormLayout {

            Layout.fillWidth: true

            Label {
                text: "test"
            }

            TextField {

                Material.containerStyle: Material.Filled
            }

            Controls.Divider {}

            Label {
                text: "test"
            }

            TextField {

                Material.containerStyle: Material.Filled
            }

            Controls.PasswordTextField {}
        }

        Controls.ListView {

            Layout.fillWidth: true

            model: 3

            header: Component {

                Rectangle {
                    implicitWidth: 100
                    implicitHeight: 100
                    color: "red"
                }
            }

            delegate: Controls.ItemDelegate {

                text: "Test mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm " + index
            }
        }

        Row {
            Controls.Icon {

                icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
            }

            Controls.IconLabel {

                icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
                text: "test"
                display: AbstractButton.TextUnderIcon
            }
        }
    }

    Dialog {

        id: dialog
        parent: Overlay.overlay

        title: "asdfasdf"
        width: parent.width / 2
        x: 100
        y: 100
        height: Window.height

        Label {
            text: "asdfasdfasd fasdas sd"
        }
    }
}
