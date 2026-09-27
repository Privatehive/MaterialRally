import QtQuick
import QtQuick.Controls
import "./private" as RallyPrivate



/*!
    \qmltype ScrollablePage
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Page

    \brief A page whose content scrolls vertically.

    ScrollablePage is a \l [QML] {QtQuick.Controls::Page}{Page} whose content is placed in a
    vertically scrolling view, so the content can be higher than the page. It has a transparent
    background and a padding of 10 px (14 px left and right).

    When used as a page of a \l [QML] {QtQuick.Controls::SwipeView}{SwipeView}, the properties
    \l isCurrentPage, \l isNextPage and \l isPreviousPage tell whether the page is the current
    page or one of its neighbours - e.g. to load the page content lazily.

    \section1 Example

    \qml
    import QtQuick
    import QtQuick.Controls
    import MaterialRally as Rally

    SwipeView {
        anchors.fill: parent

        Rally.ScrollablePage {
            id: overviewPage
            title: qsTr("Overview")

            Loader {
                width: parent.width
                active: overviewPage.isCurrentPage || overviewPage.isNextPage
                        || overviewPage.isPreviousPage
                source: "Overview.qml"
            }
        }

        Rally.ScrollablePage {
            title: qsTr("Accounts")
            // ...
        }
    }
    \endqml

    \sa ScrollView
*/
RallyPrivate.ScrollablePageBase {

    padding: 10
    leftPadding: 14
    rightPadding: 14


    /*!
      \qmlproperty bool ScrollablePage::isCurrentPage

      \c true if this page is the current page of the SwipeView it is placed in.
    */
    property bool isCurrentPage: parent.SwipeView.isCurrentItem


    /*!
      \qmlproperty bool ScrollablePage::isNextPage

      \c true if this page is the page right after the current page of the SwipeView it is
      placed in.
    */
    property bool isNextPage: parent.SwipeView.isNextItem


    /*!
      \qmlproperty bool ScrollablePage::isPreviousPage

      \c true if this page is the page right before the current page of the SwipeView it is
      placed in.
    */
    property bool isPreviousPage: parent.SwipeView.isPreviousItem

    background: Item {}
}
