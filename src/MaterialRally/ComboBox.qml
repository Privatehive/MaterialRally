import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

T.ComboBox {

    id: control

    T.Material.containerStyle: Material.Filled
    selectTextByMouse: true
    activeFocusOnTab: true

    property string placeholderText: ""
    property color placeholderTextColor: control.enabled
                                         && control.activeFocus ? T.Material.accentColor : T.Material.hintTextColor

    topPadding: control.T.Material.containerStyle
                === Material.Filled ? placeholderText.length > 0
                                      && (activeFocus
                                          || control.contentItem.length
                                          > 0) ? placeholder.largestHeight : 0 : 0

    Component.onCompleted: {

        control.indicator.y = Qt.binding(() => {
                                             return (control.height - control.indicator.height) / 2
                                         })

        control.indicator.color = Qt.binding(() => {
                                                 return control.enabled ? (control.down
                                                                           || control.activeFocus ? control.T.Material.accent : control.T.Material.foreground) : control.T.Material.hintTextColor
                                             })


        /*
        control.background.placeholderTextWidth = Qt.binding(() => {
                                                                 if (placeholder) {
                                                                     return Math.min(
                                                                         placeholder.width,
                                                                         placeholder.implicitWidth)
                                                                     * placeholder.scale
                                                                 }
                                                                 return 0
                                                             })

        control.background.placeholderHasText = Qt.binding(() => {
                                                               if (placeholder) {
                                                                   return placeholder.text.length > 0
                                                               }
                                                               return false
                                                           })

        control.background.controlHasText = Qt.binding(() => {
                                                           return control.contentItem.length > 0
                                                       })
*/
    }

    FloatingPlaceholderText {
        id: placeholder
        x: control.contentItem.leftPadding
        width: control.contentItem.width - (control.contentItem.leftPadding
                                            + control.contentItem.rightPadding)
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        elide: Text.ElideRight

        filled: control.T.Material.containerStyle === Material.Filled
        verticalPadding: control.T.Material.containerStyle
                         === Material.Filled ? 14 : 0 // control.Material.textFieldVerticalPadding
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.contentItem.length > 0
        controlImplicitBackgroundHeight: control.contentItem.implicitBackgroundHeight
        controlHeight: control.contentItem.height
    }

    background: MaterialTextContainer {
        implicitWidth: 120
        implicitHeight: control.T.Material.textFieldHeight

        filled: control.T.Material.containerStyle === Material.Filled
        fillColor: control.T.Material.textFieldFilledContainerColor
        outlineColor: (enabled
                       && control.hovered) ? control.T.Material.primaryTextColor : control.T.Material.hintTextColor
        focusedOutlineColor: control.T.Material.accentColor
        // When the control's size is set larger than its implicit size, use whatever size is smaller
        // so that the gap isn't too big.
        placeholderTextWidth: Math.min(
                                  placeholder.width,
                                  placeholder.implicitWidth) * placeholder.scale
        //placeholderTextHAlign: control.effectiveHorizontalAlignment
        controlHasActiveFocus: control.activeFocus
        controlHasText: control.contentItem.length > 0
        placeholderHasText: placeholder.text.length > 0
        horizontalPadding: control.T.Material.textFieldHorizontalPadding
    }
}
