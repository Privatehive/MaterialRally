import QtQuick as T
import QtQuick.Controls as T
import QtQuick.Layouts as T


/*!
    \qmltype CollapsibleControl
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits T.Control

    \brief A control that can be collapsed and expanded.

    This control can programmatically hide/show a child item without using the \a visible property. Instead the control will shrink to 0 height if collapsed and expand to the \a implicitHeight if the child item again if expanded.
*/
T.Control {

    id: control


    /*!
      \qmlproperty Item CollapsibleControl::mainItem

      The child item that will be hidden/shown depending on \a collapsed property. This is a default property.
    */
    default property T.Item mainItem: T.Item {}


    /*!
      \qmlproperty int CollapsibleControl::animationDuration
      \default 200

      Animates the height change of the CollapsibleControl if \a collapsed was toggled. Set this to 0 to disable animations.
    */
    property int animationDuration: 200


    /*!
      \qmlproperty bool CollapsibleControl::collapsed
      \default false

      If \a collapsed equals true, the \a mainItem will be hidden. If \a collapsed equals false, the \a mainItem will be show.
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
