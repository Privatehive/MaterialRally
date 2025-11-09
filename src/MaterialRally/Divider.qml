import QtQuick
import QtQuick.Controls.Material


/*!
    \qmltype Divider
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief Draws a horizontal line.

    Mainly used to visually separate content from each other.
*/
Item {

    id: control


    /*!
      \qmlproperty color Divider::color
      \default Material.backgroundColor

      The color of the divider.
    */
    property color color: Material.backgroundColor

    implicitWidth: 120
    implicitHeight: 16

    Rectangle {
        color: control.color
        width: parent.width
        implicitHeight: 2
        y: parent.height / 2 - height / 2
    }
}
