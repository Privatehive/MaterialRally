import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "./private" as RallyPrivate
import MaterialRally as Rally



/*!
    \qmltype RallyApplicationWindow
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits ApplicationWindow

    \brief The root window of a Material Rally application loaded with QQmlApplicationEngine.

    Use RallyApplicationWindow as the root item of your main QML file if the application loads it
    with QQmlApplicationEngine::load(). If the application uses QQuickView::setSource() instead,
    use \l RallyRootPage.

    RallyApplicationWindow registers itself and its content item with the \c RootItem attached
    type (\c {Rally.RootItem.root} and \c {Rally.RootItem.contentItem}). Several controls rely
    on this:

    \list
    \li \l Helper creates dialogs as children of the content item.
    \li \l Dialog and \l InfoDialog use the content item for their modal background effect.
    \endlist

    It also provides \c {Rally.RootItem.isTouchInput} and \c {Rally.RootItem.isMouseInput},
    which tell whether the user last interacted by touch or by mouse - \l ScrollView uses them to
    switch between swipe scrolling and an interactive scroll bar.

    A \c header or \c footer assigned to the window is moved onto an inner \l [QML] {QtQuick.Controls::Page}{Page},
    so it is laid out together with the content. In debug builds, the current window size is shown
    in an overlay while the window is being resized.

    \section1 Example

    \qml
    // main.qml, loaded with QQmlApplicationEngine::load()
    import QtQuick
    import QtQuick.Controls
    import MaterialRally as Rally

    Rally.RallyApplicationWindow {
        id: window

        width: 800
        height: 600
        title: qsTr("Rally")

        header: Rally.ToolBar {
            Label {
                anchors.centerIn: parent
                text: window.title
            }
        }

        Rally.ScrollView {
            anchors.fill: parent

            Rally.GroupBox {
                width: parent.width
                title: qsTr("Accounts")
                // ...
            }
        }

        Rally.SnackBar {
            id: snackBar
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    \endqml

    \sa RallyRootPage
*/
ApplicationWindow {

    id: root

    visible: true

    minimumWidth: 350
    minimumHeight: 300

    Rally.RootItem.root: root
    Rally.RootItem.contentItem: content



    /*!
      \qmlproperty list<QtObject> RallyApplicationWindow::content

      The content of the window. This is the default property, so child items can simply be
      declared inside the RallyApplicationWindow. They are placed on an inner page that fills the
      window below the header and above the footer.
    */
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
