import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Controls.Material.impl as T


/*!
    \qmltype Button
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::Button

    \brief A push-button in the Material Rally style.

    Rally.Button is a \l [QML] {QtQuick.Controls::Button}{Button} with the look of the Rally
    Material study: an upper case, wide-spaced label, a slightly smaller icon and a flat
    rectangular background with a ripple effect. All properties of the stock Button (\c text,
    \c icon, \c flat, \c highlighted, \c checkable, \c onClicked, ...) are available.

    \image button.png "Button"

    \section1 Examples

    A simple button with a text and an icon:

    \qml
    import QtQuick
    import MaterialRally as Rally

    Rally.Button {
        text: qsTr("Save")
        icon.source: "qrc:/icons/save.svg"
        onClicked: document.save()
    }
    \endqml

    A highlighted button uses the Material accent color, a flat button has no background until it
    is hovered or pressed:

    \qml
    Row {
        spacing: 10

        Rally.Button {
            text: qsTr("Accept")
            highlighted: true
        }

        Rally.Button {
            text: qsTr("Cancel")
            flat: true
        }
    }
    \endqml
*/
T.Button {

    id: control

    font.capitalization: Font.AllUppercase
    font.letterSpacing: 1.6
    font.pixelSize: 12

    padding: 18
    horizontalPadding: padding
    spacing: 6

    icon.width: 17
    icon.height: 17

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: T.Material.buttonHeight

        radius: 4
        color: control.T.Material.buttonColor(control.T.Material.theme, control.T.Material.background,
                                              control.T.Material.accent, control.enabled, control.flat,
                                              control.highlighted, control.checked)

        T.Ripple {
            clip: true
            clipRadius: 2
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.flat
                   && control.highlighted ? control.T.Material.highlightedRippleColor : control.T.Material.rippleColor
        }
    }
}
