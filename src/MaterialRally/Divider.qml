import QtQuick
import QtQuick.Controls.Material

/*!
    \qmltype Divider
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief Draws a horizontal line. Mainly used to visually separate content from each other.

    Draw a line
*/
Item {

    id: control
    /*! Sets the key weight value which determines the relative size of the key.

    Use this property to change the key size in the layout.

    The default value is inherited from the parent element
    of the key in the layout hierarchy.
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