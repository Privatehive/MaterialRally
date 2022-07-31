import QtQuick 2.12
import QtQuick.Controls 2.12
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
