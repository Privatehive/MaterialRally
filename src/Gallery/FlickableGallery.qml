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
            text: qsTr("Basic Flickable")
        }

        DocItem {

            Layout.fillWidth: true

            text: 'import QtQuick
            import MaterialRally as Rally

            Rally.Flickable {
                width: 280
                height: 400
                contentHeight: col.implicitHeight

                Column {
                    id: col
                    width: parent.width

                    Repeater {
                        model: 400
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: index % 2 === 0 ? "#3d3d47" : "#33333d"

                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "Row " + index
                            }
                        }
                    }
                }
            }
            '
        }

        Rally.Divider {

            Layout.fillWidth: true
            color: "black"
        }

        Label {
            text: qsTr("Nested Flickables - orthogonal axes")
        }

        DocItem {

            Layout.fillWidth: true

            text: 'import QtQuick
            import MaterialRally as Rally

            Rally.Flickable {
                width: 280
                height: 260
                contentHeight: outerColumn.implicitHeight

                Column {
                    id: outerColumn
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: 3
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#33333d"
                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "Outer row " + index
                            }
                        }
                    }

                    Rally.Flickable {
                        width: parent.width
                        height: 120
                        flickableDirection: Flickable.HorizontalFlick
                        contentWidth: carousel.implicitWidth

                        Row {
                            id: carousel
                            spacing: 10

                            Repeater {
                                model: 6
                                Rectangle {
                                    width: 100
                                    height: 120
                                    radius: 8
                                    color: Qt.hsla(index / 6, 0.5, 0.4, 1)
                                    Text {
                                        anchors.centerIn: parent
                                        color: "white"
                                        text: "Card " + index
                                    }
                                }
                            }
                        }
                    }

                    Repeater {
                        model: 3
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#33333d"
                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "Outer row " + (index + 3)
                            }
                        }
                    }
                }
            }
            '
        }

        Rally.Divider {

            Layout.fillWidth: true
            color: "black"
        }

        Label {
            text: qsTr("Nested Flickables - same axis (no hand-off yet)")
        }

        DocItem {

            Layout.fillWidth: true

            text: 'import QtQuick
            import MaterialRally as Rally

            Rally.Flickable {
                width: 280
                height: 260
                contentHeight: outerColumn.implicitHeight

                Column {
                    id: outerColumn
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: 3
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#33333d"
                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "Outer row " + index
                            }
                        }
                    }

                    Rally.Flickable {
                        width: parent.width
                        height: 140
                        contentHeight: innerColumn.implicitHeight

                        Column {
                            id: innerColumn
                            width: parent.width

                            Repeater {
                                model: 15
                                Rectangle {
                                    width: parent.width
                                    height: 30
                                    color: index % 2 === 0 ? "#4d4d5a" : "#3d3d47"
                                    Text {
                                        anchors.centerIn: parent
                                        color: "white"
                                        text: "Inner row " + index
                                    }
                                }
                            }
                        }
                    }

                    Repeater {
                        model: 3
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#33333d"
                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "Outer row " + (index + 3)
                            }
                        }
                    }
                }
            }
            '
        }

        Rally.Divider {

            Layout.fillWidth: true
            color: "black"
        }

        Label {
            text: "is touch input: " + Rally.RootItem.isTouchInput
        }
    }
}
