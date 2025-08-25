import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialRally as Rally

Rally.Dialog {

    title: "test"

    onBackButtonClicked: {
        close()
    }

    Rally.ScrollView {

        anchors.fill: parent

        contentItem: Rally.FormLayout {

            width: Math.min(parent.width, 600)

            Rally.GroupBox {

                title: "group"
                Layout.fillWidth: true

                mainAction: Rally.BusyAction
                {
                    checkable: true
                    checked: false
                }

                Rally.FormLayout {

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }
                }
            }

            Rally.GroupBox {

                title: "group"
                Layout.fillWidth: true

                Rally.FormLayout {

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }
                }
            }

            Rally.GroupBox {

                title: "group"
                Layout.fillWidth: true

                Rally.FormLayout {

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }
                }
            }

            Rally.GroupBox {

                title: "group"
                Layout.fillWidth: true

                Rally.FormLayout {

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }

                    Label {
                        text: "test"
                    }

                    ComboBox {
                    }
                }
            }
        }
    }
}
