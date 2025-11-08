import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "./private" as RallyPrivate
import MaterialRally as Rally

// Use this Item as the entrypoint if you use QQuickView::setSource
Page {

    id: root

    Rally.RootItem.root: root
    Rally.RootItem.contentItem: content

    default property list<QtObject> content: []

    background: null

    Component.onCompleted: {
        console.log("Creating RallyRootPage")
        if (quickview) {
            quickview.color = Material.background
        }
        if (root.SafeArea) {
            root.leftPadding = Qt.binding(() => {
                                              return root.SafeArea.margins.left
                                          })
            root.rightPadding = Qt.binding(() => {
                                               return root.SafeArea.margins.right
                                           })
            root.bottomPadding = Qt.binding(() => {
                                                return root.SafeArea.margins.bottom
                                            })
            root.topPadding = Qt.binding(() => {
                                             return root.SafeArea.margins.top
                                         })
        }
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
        background: null
    }

    RallyPrivate.SizeLabel {
        target: root
        active: rallyIsDebug
        parent: Overlay.overlay
        anchors.centerIn: parent
    }
}
