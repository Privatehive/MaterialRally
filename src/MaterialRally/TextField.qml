import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl


/*!
    \qmltype TextField
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::TextField

    \brief A single-line text input field in the Material Rally style.

    Rally.TextField is a \l [QML] {QtQuick.Controls::TextField}{TextField} that uses the filled
    Material container style (\c {Material.containerStyle: Material.Filled}) and can be reached
    with the tab key. All properties of the stock TextField are available.

    \section1 Example

    \qml
    import QtQuick
    import MaterialRally as Rally

    Rally.TextField {
        width: 300
        placeholderText: qsTr("Account name")
        maximumLength: 32
        onEditingFinished: account.name = text
    }
    \endqml

    \sa PasswordTextField, TextArea
*/
T.TextField {

    id: control

    Material.containerStyle: Material.Filled
    activeFocusOnTab: true
}
