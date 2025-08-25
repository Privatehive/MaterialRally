import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally

Item {

    id: control

    property alias icon: iconLabel.icon
    property alias name: iconLabel.icon.name
    property alias source: iconLabel.icon.source
    property bool flat: true
    property bool highlighted: false

    implicitHeight: iconLabel.implicitHeight
    implicitWidth: iconLabel.implicitWidth

    icon.color: !control.enabled ? T.Material.hintTextColor : control.flat
        && control.highlighted ? T.Material.accentColor : control.highlighted ? T.Material.primaryHighlightedTextColor : T.Material.foreground

    IconLabel {
        id: iconLabel
        display: T.AbstractButton.IconOnly
        icon.width: control.width
        icon.height: control.height
    }
}
