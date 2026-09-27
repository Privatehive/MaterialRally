import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl


/*!
    \qmltype TextArea
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::TextArea

    \brief A multi-line text input area in the Material Rally style.

    Rally.TextArea is a \l [QML] {QtQuick.Controls::TextArea}{TextArea} with a dark, flat
    background and a thin accent colored border that fades in while the text area has active
    focus (and is not read-only). Text can be selected with the mouse and a tab stop is 20 px wide.

    Like the stock TextArea, it does not scroll on its own. Put it into a \l ScrollView if the
    text can get longer than the available space.

    \section1 Example

    \qml
    import QtQuick
    import MaterialRally as Rally

    Rally.TextArea {
        width: 400
        placeholderText: qsTr("Notes")
        wrapMode: TextEdit.Wrap
    }
    \endqml

    A read-only text area showing a log:

    \qml
    Rally.ScrollView {
        width: 400
        height: 200

        Rally.TextArea {
            width: parent.width
            readOnly: true
            font.family: "Roboto Mono"
            text: logger.text
        }
    }
    \endqml

    \sa TextField
*/
T.TextArea {

    id: control
    selectByMouse: true

    topPadding: 12
    bottomPadding: 12
    leftPadding: 12
    rightPadding: 12
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0
    tabStopDistance: 20

    background: Rectangle {
        property real borderOpacity: control.activeFocus && !control.readOnly ? 1 : 0
        implicitWidth: 250
        implicitHeight: control.Material.buttonHeight
        color: "#26282f"
        border.color: Qt.rgba(control.Material.accentColor.r, control.Material.accentColor.g,
                              control.Material.accentColor.b, control.Material.accentColor.a * borderOpacity)
        border.width: 1 //control.activeFocus && !control.readOnly ? 1 : 0

        Behavior on borderOpacity {
            SmoothedAnimation {
                duration: 250
                velocity: -1
            }
        }
    }
}
