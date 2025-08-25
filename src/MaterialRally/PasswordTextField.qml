import QtQuick
import QtQuick.Controls
import MaterialRally as Rally

Rally.TextField {

    echoMode: revealButton.checked ? TextInput.Normal : TextInput.Password
    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhHiddenText | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
    passwordMaskDelay: 500
    passwordCharacter: "●"

    rightPadding: revealButton.width

    RoundButton {
        id: revealButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        flat: true
        checkable: true
        display: AbstractButton.IconOnly
        icon.source: checked ? "qrc:/icons/material_private/48x48/eye.svg" : "qrc:/icons/material_private/48x48/eye-off.svg"
    }
}
