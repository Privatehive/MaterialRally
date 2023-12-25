import QtQuick
import QtQuick.Controls
import "./private"

ScrollablePageBase {

    padding: 10
    leftPadding: 14
    rightPadding: 14

    property bool isCurrentPage: parent.SwipeView.isCurrentItem
    property bool isNextPage: parent.SwipeView.isNextItem
    property bool isPreviousPage: parent.SwipeView.isPreviousItem

    background: Item {}
}
