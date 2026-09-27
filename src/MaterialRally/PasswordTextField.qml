import QtQuick
import QtQuick.Controls
import MaterialRally as Rally


/*!
    \qmltype PasswordTextField
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits MaterialRally::TextField

    \brief A text field for passwords with a button to reveal the input.

    PasswordTextField is a Rally \l TextField that hides its input behind \c {●} characters.
    The last typed character stays visible for a short moment (500 ms). A toggle button with an eye
    icon on the right side of the field reveals the password in plain text and hides it again.

    The input method is told that the input is sensitive: no predictive text, no auto
    capitalization and no storing of the input in the keyboard's dictionary.

    \section1 Example

    \qml
    import QtQuick
    import QtQuick.Layouts
    import MaterialRally as Rally

    ColumnLayout {

        Rally.TextField {
            id: userField
            Layout.fillWidth: true
            placeholderText: qsTr("User name")
        }

        Rally.PasswordTextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: qsTr("Password")
            onAccepted: backend.login(userField.text, passwordField.text)
        }
    }
    \endqml
*/
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
