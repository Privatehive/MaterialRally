import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import MaterialRally as Rally

Pane {

    ColumnLayout {

        width: parent.width

        Label {
            text: qsTr("Basic TilesLayout")
        }

        DocItem {

            Layout.fillWidth: true

            text: 'import QtQuick
            import QtQuick.Layouts
            import MaterialRally as Rally

            Rally.TilesLayout {
                width: 360
                cellSize: 40

                Rectangle { color: "#1eb980"; Layout.columnSpan: 2; Layout.rowSpan: 2 }
                Rectangle { color: "#ffcf44" }
                Rectangle { color: "#ff6859" }
                Rectangle { color: "#72deff"; Layout.columnSpan: 4; Layout.rowSpan: 2 }
                Rectangle { color: "#b15dff" }
                Rectangle { color: "#045d56" }
            }
            '
        }

        Rally.Divider {

            Layout.fillWidth: true
            color: "black"
        }

        Label {
            text: qsTr("Responsive - resize the window to reflow the tiles")
        }

        Rally.TilesLayout {

            Layout.fillWidth: true

            Repeater {

                // Small (1x1), medium (2x2), wide (4x2) and large (4x4) tiles as in Windows
                model: [
                    { columnSpan: 2, rowSpan: 2, color: "#1eb980" },
                    { columnSpan: 1, rowSpan: 1, color: "#ffcf44" },
                    { columnSpan: 1, rowSpan: 1, color: "#ff6859" },
                    { columnSpan: 4, rowSpan: 2, color: "#72deff" },
                    { columnSpan: 1, rowSpan: 1, color: "#b15dff" },
                    { columnSpan: 2, rowSpan: 2, color: "#045d56" },
                    { columnSpan: 4, rowSpan: 4, color: "#ff6859" },
                    { columnSpan: 1, rowSpan: 1, color: "#1eb980" },
                    { columnSpan: 2, rowSpan: 2, color: "#ffcf44" },
                    { columnSpan: 1, rowSpan: 1, color: "#72deff" },
                    { columnSpan: 4, rowSpan: 2, color: "#b15dff" },
                    { columnSpan: 2, rowSpan: 2, color: "#1eb980" }
                ]

                Rectangle {
                    required property int index
                    required property var modelData

                    Layout.columnSpan: modelData.columnSpan
                    Layout.rowSpan: modelData.rowSpan
                    color: modelData.color
                    radius: 4

                    Label {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        text: index + 1
                    }
                }
            }
        }
    }
}
