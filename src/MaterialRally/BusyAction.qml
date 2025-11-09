import QtQml
import QtQuick.Controls as T


/*!
    \qmltype BusyAction
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits T.Action

    \brief Abstract user interface action.

    BusyAction represents an user interface action that can have shortcuts and can be assigned to \a GroupBox. It can indicate that an action is running.
*/
T.Action {


    /*!
      \qmlproperty bool BusyAction::busy
      \default false

      If \a busy equals true, this action is considered running. The assigned \a GroupBox shows a busy indicator.
    */
    property bool busy: false


    /*!
      \qmlproperty int BusyAction::minBusyDelay
      \default 900

      This is the minimum amount of milliseconds that the busy state will be maintained. This is useful to prevent the busy indicator from flashing for very short busy durations.
    */
    property alias minBusyDelay: timer.interval


    /*!
      \qmlproperty bool BusyAction::delayedBusy
      \readonly

      This property equals true for at least \a minBusyDelay as soon as \a busy gets toggled. Bind this property to a busy indicator so it does not flash up.
    */
    readonly property bool delayedBusy: busy || timer.running

    readonly property var delayTimer: Timer {
        id: timer
        interval: 900
    }

    onBusyChanged: {
        if (busy) {
            timer.restart()
        }
    }
}
