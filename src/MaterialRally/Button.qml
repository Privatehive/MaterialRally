import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import QtQuick.Controls.Material.impl as T

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
		color: control.T.Material.buttonColor(control.T.Material.theme, control.T.Material.background, control.T.Material.accent, control.enabled, control.flat, control.highlighted, control.checked)

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
