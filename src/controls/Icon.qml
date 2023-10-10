import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T

Item {

    id: control

    implicitHeight: iconLabel.implicitHeight
    implicitWidth: iconLabel.implicitWidth

    property alias icon: iconLabel.icon
    property bool flat: true
    property bool highlighted: false

    icon.width: 20
    icon.height: 20
    icon.color: !control.enabled ? T.Material.hintTextColor : control.flat
                                   && control.highlighted ? T.Material.accentColor : control.highlighted ? T.Material.primaryHighlightedTextColor : T.Material.foreground

    IconLabel {
        id: iconLabel
        display: T.AbstractButton.IconOnly
    }
}
