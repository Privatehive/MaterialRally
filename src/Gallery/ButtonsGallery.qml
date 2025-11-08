import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MaterialRally as Rally

Pane {

    ColumnLayout {

        width: parent.width

        Button {
            text: "dialog"
            onClicked: Rally.Helper.createDialog(Qt.resolvedUrl("TestDialog.qml"))
        }

        Label {
            text: "is touch input: " + Rally.RootItem.isTouchInput
        }

        Rally.GroupBox {

            Layout.fillWidth: true
            infoText: "test"
            title: qsTr("Test")

            height: 300

            mainAction: Rally.BusyAction {
                checkable: false
                text: "test"
                busy: true
            }

            Rally.ScrollView {

                anchors.fill: parent

                ColumnLayout {

                    TextField {
                        placeholderText: "asdfasdf"
                        text: "asdfadsf"
                    }

                    TextField {
                        placeholderText: "asdfasdf"
                        text: "asdfadsf"
                    }

                    TextField {
                        placeholderText: "asdfasdf"
                        text: "asdfadsf"
                    }

                    TextField {
                        placeholderText: "asdfasdf"
                        text: "asdfadsf"
                    }

                    TextField {
                        placeholderText: "asdfasdf"
                        text: "asdfadsf"
                    }

                    Label {
                        text: "9"
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

                    Button {
                        id: toggleButton
                        text: "toggle"
                        checkable: true
                    }

                    Rally.CollapsibleControl {

                        collapsed: toggleButton.checked

                        ColumnLayout {

                            TextField {
                                placeholderText: "asdfasdf"
                                text: "asdfadsf"
                            }

                            TextField {
                                placeholderText: "asdfasdf"
                                text: "asdfadsf"
                            }
                        }
                    }
                }
            }
        }

        Rally.ComboBox {

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

        Rally.FormLayout {

            Layout.fillWidth: true

            Label {
                text: "test"
            }

            TextField {

                Material.containerStyle: Material.Filled
            }

            Rally.Divider {}

            Label {
                text: "test"
            }

            TextField {

                Material.containerStyle: Material.Filled
            }

            Rally.PasswordTextField {}
        }

        Rally.ListView {

            Layout.fillWidth: true

            model: 3

            header: Component {

                Rectangle {
                    implicitWidth: 100
                    implicitHeight: 100
                    color: "red"
                }
            }

            delegate: Rally.ItemDelegate {

                text: "Test mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm " + index
            }
        }

        Row {
            Rally.Icon {

                icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
            }

            Rally.IconLabel {

                icon.source: "qrc:/icons/material_private/48x48/information-outline.svg"
                text: "test"
                display: AbstractButton.TextUnderIcon
            }
        }
    }
}
