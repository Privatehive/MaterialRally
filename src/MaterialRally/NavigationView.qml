import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialRally as Rally

/*!
    \qmltype NavigationView
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Page

    \brief A ready to use responsive main navigation with swipeable pages.

    NavigationView shows one page per entry of its \l model and a menu to switch between them. The
    menu adapts to the available width:

    \list
    \li Below \l wideLayoutBreakpoint (mobile) a \l ToolBar with a horizontal \l TabBarFolding is
        shown as header.
    \li From \l wideLayoutBreakpoint on (desktop) a navigation rail with an optional \l logo and
        a vertical \l TabBarFolding is shown on the left, and the header is hidden.
    \endlist

    Both menus and the \l SwipeView holding the pages stay in sync, so resizing the window keeps
    the current page. The pages are loaded lazily: only the current page and its two neighbours are
    loaded, and they are placed inside a \l ScrollView.

    Every model entry needs the roles \c title (menu label), \c source (URL of the page's QML
    file) and either \c iconName (icon theme name) or \c iconSource (URL of an icon image). A
    relative \c source or \c iconSource is resolved against the QML file that declares the model.

    Pages are at least as tall as the view, so a page that only fills its parent (e.g. a chart)
    gets the full height, while a taller page scrolls.

    \section1 Example

    \qml
    Rally.RallyApplicationWindow {

        Rally.NavigationView {
            anchors.fill: parent
            logo: "qrc:/qt/qml/MyApp/logo.svg"

            model: ListModel {
                ListElement { title: qsTr("Overview"); iconName: "chart-pie"; source: "Overview.qml" }
                ListElement { title: qsTr("Accounts"); iconName: "currency-usd"; source: "Accounts.qml" }
            }
        }
    }
    \endqml

    \sa TabBarFolding, SwipeView
*/
Page {

    id: control

    /*!
      \qmlproperty model NavigationView::model

      The pages to navigate between. Each entry provides the roles \c title, \c source and
      either \c iconName or \c iconSource.
    */
    property var model

    /*!
      \qmlproperty url NavigationView::logo

      An optional image shown on top of the navigation rail in the wide layout.
    */
    property url logo

    /*!
      \qmlproperty int NavigationView::currentIndex

      The index of the current page.
    */
    property alias currentIndex: view.currentIndex

    /*!
      \qmlproperty real NavigationView::wideLayoutBreakpoint

      The width from which on the navigation rail replaces the header. The default of 840
      corresponds to the Material "expanded" window size class.
    */
    property real wideLayoutBreakpoint: 840

    /*!
      \qmlproperty bool NavigationView::wideLayout
      \readonly

      Whether the navigation rail (\c true) or the header (\c false) is shown.
    */
    readonly property bool wideLayout: control.width >= control.wideLayoutBreakpoint

    /*!
      \qmlproperty real NavigationView::railWidth

      The width of the navigation rail in the wide layout.
    */
    property real railWidth: 200

    background: null

    // A model entry's URL relative to the file declaring the model, not to this file
    function resolvedSource(source) {
        // A QObject model (e.g. a ListModel) carries the context of the file declaring it
        const isQObject = control.model && control.model.objectName !== undefined
        return isQObject ? Qt.resolvedUrl(source, control.model) : source
    }

    header: Rally.ToolBar {

        // Explicit: until the Page lays out its header, the ToolBar would fall back to its
        // implicitWidth, which depends on the TabBarFolding's spacing, which depends on this width
        width: control.width
        visible: !control.wideLayout

        Rally.TabBarFolding {

            anchors.centerIn: parent
            width: Math.min(parent.width, 500)

            onIndexSelected: index => view.currentIndex = index
            currentIndex: view.currentIndex

            Repeater {
                model: control.model
                Rally.TabButtonFolding {
                    required property int index
                    // Not separate role properties: iconName and iconSource are optional roles
                    required property var model

                    checked: index === view.currentIndex
                    icon.name: model.iconName ?? ""
                    icon.source: model.iconSource ? control.resolvedSource(model.iconSource) : ""
                    text: model.title
                }
            }
        }
    }

    Item {

        id: rail

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: control.wideLayout ? control.railWidth : 0
        visible: control.wideLayout

        ColumnLayout {

            anchors.top: parent.top
            anchors.topMargin: 48
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 72

            Image {
                Layout.alignment: Qt.AlignHCenter
                visible: control.logo.toString() !== ""
                source: control.logo
                sourceSize.width: 64
                sourceSize.height: 64
            }

            Rally.TabBarFolding {

                Layout.alignment: Qt.AlignHCenter
                orientation: Qt.Vertical

                onIndexSelected: index => view.currentIndex = index
                currentIndex: view.currentIndex

                Repeater {
                    model: control.model
                    Rally.TabButtonFolding {
                        required property int index
                        // Not separate role properties: iconName and iconSource are optional roles
                        required property var model

                        checked: index === view.currentIndex
                        icon.name: model.iconName ?? ""
                        icon.source: model.iconSource ? control.resolvedSource(model.iconSource) : ""
                        text: model.title
                    }
                }
            }
        }
    }

    Rally.ScrollView {

        id: scrollView

        anchors.left: rail.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        reloadable: false
        clip: true

        // Rally.SwipeView rather than the stock one: a stock (Flickable-based) horizontal
        // SwipeView hijacks vertical drags meant for the ScrollView around it, because
        // QQuickFlickable decides to steal from |dx| alone without ever comparing it to |dy|,
        // and once it has the grab an ancestor cannot take it back. Rally.SwipeView is
        // DragHandler-based, and a DragHandler refuses to activate when the drag is mostly
        // along its disabled axis.
        Rally.SwipeView {

            id: view
            width: parent.width
            // At least the viewport height: a page that only fills its parent has no implicit height
            height: Math.max(implicitHeight, scrollView.availableHeight)

            Repeater {

                model: control.model

                Loader {
                    id: loader
                    required property int index
                    // Not a "source" role property: that would shadow Loader.source
                    required property var model
                    // Rally.SwipeView has no attached isCurrentItem/isNextItem/isPreviousItem -
                    // compare against currentIndex directly, which is the same "current plus its
                    // two neighbours" window.
                    active: Math.abs(loader.index - view.currentIndex) <= 1
                    asynchronous: true
                    source: control.resolvedSource(loader.model.source)
                    visible: status == Loader.Ready
                }
            }
        }
    }
}
