import QtQml
import QtQuick
import QtQuick.Controls
import MaterialRally as Rally

Rally.RallyApplicationWindow {

    id: root

    Rally.NavigationView {

        anchors.fill: parent

        // Absolute: with QML hot reloading main.qml is loaded from disk, where the logo does not live
        logo: "qrc:/qt/qml/Gallery/Gallery/RallyGallery.svg"

        model: ListModel {

            ListElement {
                title: qsTr("Buttons")
                iconName: "button-cursor"
                source: "ButtonsGallery.qml"
            }

            ListElement {
                title: qsTr("Lists")
                iconName: "list-box"
                source: "ListsGallery.qml"
            }

            ListElement {
                title: qsTr("Flickable")
                iconName: "list-box"
                source: "FlickableGallery.qml"
            }
        }
    }
}
