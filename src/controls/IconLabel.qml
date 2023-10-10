import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.impl as T
import QtQuick.Controls.Material as T

T.AbstractButton {

    id: control

    contentItem: T.IconLabel {

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? control.T.Material.hintTextColor : control.flat
                                  && control.highlighted ? control.T.Material.accentColor : control.highlighted ? control.T.Material.primaryHighlightedTextColor : control.T.Material.foreground
    }
}
