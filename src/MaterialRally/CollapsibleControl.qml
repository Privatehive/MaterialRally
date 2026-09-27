import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Layouts as T


/*!
    \qmltype CollapsibleControl
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Control

    \brief A control that can be collapsed and expanded with an animation.

    CollapsibleControl hides and shows its child item without toggling the item's \c visible
    property. When \l collapsed is set, the control animates its implicit height down to 0 and
    fades the content out; when it is expanded again, it grows back to the implicit height of the
    child item (plus the padding) and fades the content in.

    Because only the implicit height changes, the control works well in layouts and in a
    \l ScrollView: the surrounding items move smoothly instead of jumping.

    \section1 Example

    A checkable button that shows and hides additional input fields:

    \qml
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import MaterialRally as Rally

    ColumnLayout {

        Rally.Button {
            id: moreButton
            text: checked ? qsTr("Less options") : qsTr("More options")
            checkable: true
        }

        Rally.CollapsibleControl {
            Layout.fillWidth: true
            collapsed: !moreButton.checked

            ColumnLayout {
                Rally.TextField {
                    placeholderText: qsTr("Street")
                }
                Rally.TextField {
                    placeholderText: qsTr("City")
                }
            }
        }
    }
    \endqml

    \sa GroupBox
*/
T.Control {

    id: control


    /*!
      \qmlproperty Item CollapsibleControl::mainItem

      The child item that is shown or hidden depending on the \l collapsed property. This is the
      default property, so the child item can simply be declared inside the CollapsibleControl.
    */
    default property T.Item mainItem: T.Item {}


    /*!
      \qmlproperty int CollapsibleControl::animationDuration
      \default 200

      The duration, in milliseconds, of the height and opacity animation that runs when
      \l collapsed is toggled. Set this to 0 to disable the animation.
    */
    property int animationDuration: 200


    /*!
      \qmlproperty bool CollapsibleControl::collapsed
      \default false

      If \c true, the control shrinks to a height of 0 and the \l mainItem is hidden. If
      \c false, the control expands to the implicit height of the \l mainItem and shows it.
    */
    property bool collapsed: false

    implicitHeight: collapsed ? 0 : contentItem.implicitHeight + control.topPadding + control.bottomPadding
    implicitWidth: contentItem.implicitWidth + control.leftPadding + control.rightPadding
    clip: collapsed
    opacity: collapsed ? 0 : 1

    T.Behavior on implicitHeight {
        T.NumberAnimation {
            duration: control.animationDuration
            easing.type: T.Easing.OutQuad
        }
    }

    T.Behavior on opacity {
        T.NumberAnimation {
            duration: control.animationDuration
            easing.type: T.Easing.OutQuad
        }
    }

    contentItem: control.mainItem
}
