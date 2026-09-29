import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "./private" as RallyPrivate
import MaterialRally as Rally



/*!
    \qmltype RallyRootPage
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Page

    \brief The root item of a Material Rally application shown with QQuickView.

    Use RallyRootPage as the root item of your main QML file if the application shows it with
    QQuickView::setSource(). If the application uses QQmlApplicationEngine::load() instead, use
    \l RallyApplicationWindow.

    Like RallyApplicationWindow, RallyRootPage registers itself and its content item with the
    \c RootItem attached type, which \l Helper, \l Dialog and \l InfoDialog rely on.

    In addition, RallyRootPage keeps its content inside the window's safe area: its padding is
    bound to the \c SafeArea margins, so nothing is covered by a notch, the status bar or the
    navigation bar on mobile devices. A \c header or \c footer assigned to the page is moved onto
    an inner page, so it also stays inside the safe area.

    \note RallyRootPage accesses a context property called \c quickview. If it is set to the
    QQuickView showing the page, the view's color is set to the Material background color.
    Make sure the property exists (it may be \c null).

    \section1 Example

    \code
    // main.cpp
    QQuickView view;
    view.rootContext()->setContextProperty("quickview", &view);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/qt/qml/MyApp/main.qml"));
    view.show();
    \endcode

    \qml
    // main.qml
    import QtQuick
    import QtQuick.Controls
    import MaterialRally as Rally

    Rally.RallyRootPage {

        header: Rally.ToolBar {
            Label {
                anchors.centerIn: parent
                text: qsTr("Rally")
            }
        }

        Rally.ScrollView {
            anchors.fill: parent
            // ...
        }
    }
    \endqml

    \sa RallyApplicationWindow
*/
Page {

    id: root

    Rally.RootItem.root: root
    Rally.RootItem.contentItem: content



    /*!
      \qmlproperty list<QtObject> RallyRootPage::content

      The content of the page. This is the default property, so child items can simply be
      declared inside the RallyRootPage. They are placed on an inner page that fills the safe area
      below the header and above the footer.
    */
    default property list<QtObject> content: []

    /*!
      \qmlproperty Item RallyRootPage::navigationRail

      An optional navigation item, typically a vertical \l TabBarFolding, shown along the left
      edge of the page while \l wideLayout is \c true. While the rail is shown, the \c header
      is hidden - so a menu can live in the header on narrow (mobile) layouts and in the rail on
      wide (desktop) layouts. The rail's width is taken from its \c implicitWidth.

      \note While a navigation rail is set, the page manages the \c visible property of the
      \c header.
    */
    property Item navigationRail: null

    /*!
      \qmlproperty real RallyRootPage::wideLayoutBreakpoint

      The width from which on \l wideLayout becomes \c true. The default of 840 corresponds to
      the Material "expanded" window size class.
    */
    property real wideLayoutBreakpoint: 840

    /*!
      \qmlproperty bool RallyRootPage::wideLayout
      \readonly

      Whether the page is at least \l wideLayoutBreakpoint wide (desktop layout).
    */
    readonly property bool wideLayout: root.width >= root.wideLayoutBreakpoint

    /*!
      \qmlproperty bool RallyRootPage::navigationRailActive
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
        background: null
    }

    RallyPrivate.SizeLabel {
        target: root
        active: rallyIsDebug
        parent: Overlay.overlay
        anchors.centerIn: parent
    }
}
