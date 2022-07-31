import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import MaterialRally 1.0 as Rally
import Qt.file 1.0

Pane {

    id: control

    Material.elevation: 6

    property alias title: title.text
    property alias code: codeArea.text
    property string file: ""
    property var currentItem: null

    padding: 0
    implicitHeight: groupB.implicitHeight
    implicitWidth: groupB.implicitWidth

    onFileChanged: {

        if (file.length > 0) {
            control.code = FileLoader.loadFileContent(control.file)
        }
    }

    GroupBox {

        id: groupB
        width: parent.width

        Column {

            spacing: 20
            width: parent.width

            RowLayout {

                width: parent.width

                Label {
                    id: title
                    text: ""
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }

                RoundButton {
                    flat: true
                    icon.source: "/icons/code.svg"
                    onClicked: {
                        codeArea.visible = !codeArea.visible
                    }
                }
            }

            Rally.TextArea {
                id: codeArea

                width: parent.width
                font.family: "Roboto Mono"
                font.pointSize: 10
                visible: false

                onTextChanged: {
                    console.warn("loading")
                    if (control.currentItem
                            && typeof control.currentItem.destroy === "function") {
                        control.currentItem.destroy()
                    }
                    control.currentItem = Qt.createQmlObject(text, holder)
                }
            }

            RowLayout {

                id: layout
                width: parent.width

                Item {
                    id: holder
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    implicitHeight: control.currentItem ? control.currentItem.implicitHeight : 0
                    implicitWidth: control.currentItem ? control.currentItem.implicitWidth : 0
                }
            }
        }
    }
}
