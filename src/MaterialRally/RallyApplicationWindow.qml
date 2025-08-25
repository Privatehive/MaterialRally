import QtQuick
import QtQuick.Controls
import "./private" as RallyPrivate
import MaterialRally as Rally

// Use this Item as the entrypoint if you use QQmlApplicationEngine::load
ApplicationWindow {

    id: root

    visible: true

    minimumWidth: 350
    minimumHeight: 300

    Rally.RootItem.contentItem: root.contentItem
    Rally.RootItem.header: root.header
    Rally.RootItem.footer: root.footer

    RallyPrivate.SizeLabel {
        target: root
        active: rallyIsDebug
        parent: Overlay.overlay
        anchors.centerIn: parent
    }
}
