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

    \section1 Responsive navigation

    Set a \l navigationRail to switch between a mobile and a desktop layout: below
    \l wideLayoutBreakpoint the \c header is shown, above it the rail is shown on the left and
    the header is hidden. Both menus can bind to the same current index to stay in sync.

    \qml
    Rally.RallyApplicationWindow {
        header: Rally.ToolBar {
            Rally.TabBarFolding {
                anchors.centerIn: parent
                currentIndex: view.currentIndex
                onIndexSelected: index => view.currentIndex = index
                // Rally.TabButtonFolding { ... }
            }
        }

        navigationRail: Item {
            implicitWidth: 180
            Rally.TabBarFolding {
                anchors.horizontalCenter: parent.horizontalCenter
                orientation: Qt.Vertical
                currentIndex: view.currentIndex
                onIndexSelected: index => view.currentIndex = index
                // Rally.TabButtonFolding { ... }
            }
        }

        // ... content containing "view"
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

    /*!
      \qmlproperty Item RallyApplicationWindow::navigationRail

      An optional navigation item, typically a vertical \l TabBarFolding, shown along the left
      edge of the window while \l wideLayout is \c true. While the rail is shown, the \c header
      is hidden - so a menu can live in the header on narrow (mobile) layouts and in the rail on
      wide (desktop) layouts. The rail's width is taken from its \c implicitWidth.

      \note While a navigation rail is set, the window manages the \c visible property of the
      \c header.
    */
    property Item navigationRail: null

    /*!
      \qmlproperty real RallyApplicationWindow::wideLayoutBreakpoint

      The width from which on \l wideLayout becomes \c true. The default of 840 corresponds to
      the Material "expanded" window size class.
    */
    property real wideLayoutBreakpoint: 840

    /*!
      \qmlproperty bool RallyApplicationWindow::wideLayout
      \readonly

      Whether the window is at least \l wideLayoutBreakpoint wide (desktop layout).
    */
    readonly property bool wideLayout: root.width >= root.wideLayoutBreakpoint

    /*!
      \qmlproperty bool RallyApplicationWindow::navigationRailActive
      \readonly

      Whether the \l navigationRail is currently shown (and the \c header hidden).
    */
    readonly property bool navigationRailActive: root.wideLayout && root.navigationRail !== null

    onNavigationRailChanged: {
        if (root.navigationRail) {
            root.navigationRail.parent = railContainer
            root.navigationRail.anchors.fill = railContainer
        }
    }

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
            header.visible = Qt.binding(() => {
                                            return !root.navigationRailActive
                                        })
        }
    }

    Item {
        id: railContainer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.navigationRailActive ? root.navigationRail.implicitWidth : 0
        visible: root.navigationRailActive
    }

    Page {
        id: content
        anchors.left: railContainer.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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
