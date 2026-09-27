import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Controls.Material.impl as T
import MaterialRally


/*!
    \qmltype ItemDelegate
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::ItemDelegate

    \brief A list item in the Material Rally style.

    Rally.ItemDelegate is an \l [QML] {QtQuick.Controls::ItemDelegate}{ItemDelegate} meant to be
    used as the delegate of a \l [QML] {QtQuick::ListView}{ListView}. It spans the full width of the view, draws a thin
    separator line below itself and can show a chevron on its right side to indicate that clicking
    it navigates somewhere.

    When clicked, the delegate calls the function \c clicked(index) of the ListView it belongs
    to, if the view declares such a function. This way the click handling can be implemented once
    on the view instead of in every delegate.

    \section1 Example

    \qml
    import QtQuick
    import MaterialRally as Rally

    ListView {
        id: accountList

        model: ["Checking", "Home Savings", "Car Savings"]

        // called by Rally.ItemDelegate
        function clicked(index) {
            console.log("Opening account", model[index])
        }

        delegate: Rally.ItemDelegate {
            required property string modelData
            text: modelData
            showChevron: true
        }
    }
    \endqml

    Of course the stock \c onClicked handler can be used as well:

    \code
    delegate: Rally.ItemDelegate {
        required property int index
        text: qsTr("Item %1").arg(index)
        highlighted: ListView.isCurrentItem
        onClicked: ListView.view.currentIndex = index
    }
    \endcode
*/
T.ItemDelegate {

    id: control


    /*!
      \qmlproperty bool ItemDelegate::showChevron
      \default false

      If \c true, a chevron (right arrow) icon is shown on the right side of the delegate, e.g. to
      indicate that clicking the item opens a detail page.
    */
    property bool showChevron: false

    rightPadding: showChevron ? 10 + chevronIcon.width : padding
    width: T.ListView.view.width
    height: Math.max(contentItem.implicitHeight,
                     background.implicitHeight) + topPadding + bottomPadding

    bottomInset: 1

    onClicked: {

        if(typeof T.ListView.view.clicked === 'function') {
            T.ListView.view.clicked(index)
        }
    }

    background: T.Rectangle {

        implicitHeight: control.T.Material.delegateHeight
        color: control.highlighted ? control.T.Material.listHighlightColor : "transparent"

        T.Ripple {
            width: parent.width
            height: parent.height

            clip: visible
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus
                                || control.hovered)
            color: control.T.Material.rippleColor
        }

        Icon {
            id: chevronIcon
            visible: control.showChevron
            icon.source: "qrc:/icons/material_private/48x48/chevron-right.svg"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        T.Rectangle {
            height: 1
            color: T.Material.backgroundColor
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: control.leftPadding
            anchors.rightMargin: control.rightPadding
        }
    }
}
