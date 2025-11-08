import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "./private" as RallyPrivate
import MaterialRally as Rally

// Use this Item as the entrypoint if you use QQmlApplicationEngine::load
ApplicationWindow {

    id: root

    visible: true

    minimumWidth: 350
    minimumHeight: 300

    Rally.RootItem.root: root
    Rally.RootItem.contentItem: content

    default property list<QtObject> content: []

    Component.onCompleted: {
        console.log("Creating RallyApplicationWindow")
        console.log("------------ " + content.background)
    }

    onFooterChanged: {
        if (root.footer) {
            // reassign footer to RallyRootPage so the SafeArea applies
            const footer = root.footer
            root.footer = null
            content.footer = footer
        }
    }

    onHeaderChanged: {
        if (root.header) {
            // reassign header to RallyRootPage so the SafeArea applies
            const header = root.header
            root.header = null
            content.header = header
        }
    }

    Page {
        id: content
        anchors.fill: parent
        contentData: root.content
        //background: null
    }

    RallyPrivate.SizeLabel {
        target: root
        active: rallyIsDebug
        parent: Overlay.overlay
        anchors.centerIn: parent
    }
}
