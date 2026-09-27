import QtQuick
import QtQuick.Controls.Material


/*!
    \qmltype Divider
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief Draws a horizontal line to separate content.

    Divider draws a 2 px high horizontal line, vertically centered in its (implicitly 16 px high)
    area, so it brings its own spacing to the items above and below. Set the width (or
    \c {Layout.fillWidth}) to control how long the line is.

    \section1 Example

    \qml
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import MaterialRally as Rally

    ColumnLayout {

        Label {
            text: qsTr("Personal data")
        }

        Rally.Divider {
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Account")
        }

        Rally.Divider {
            Layout.fillWidth: true
            color: "black"
        }
    }
    \endqml
*/
Item {

    id: control


    /*!
      \qmlproperty color Divider::color
      \default Material.backgroundColor

      The color of the line.
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
