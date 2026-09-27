import QtQml
import QtQuick.Controls as T


/*!
    \qmltype BusyAction
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::Action

    \brief An Action that can indicate that it is still running.

    BusyAction is a regular \l [QML] {QtQuick.Controls::Action}{Action} - it has a text, an icon,
    can be checkable and can have shortcuts - with an additional \l busy state. Assign it to
    \l {GroupBox::mainAction}{GroupBox.mainAction} or add it to \l {Dialog::actions}{Dialog.actions}
    and the control shows a busy indicator and disables the action while it is running.

    To avoid a busy indicator that only flashes up for a few milliseconds, the busy state is kept
    for at least \l minBusyDelay milliseconds. Controls should therefore bind to \l delayedBusy
    rather than to \l busy.

    \section1 Example

    A group box whose header action reloads some data. The action is busy until the (asynchronous)
    reload has finished:

    \qml
    import QtQuick
    import MaterialRally as Rally

    Rally.GroupBox {
        title: qsTr("Accounts")

        mainAction: Rally.BusyAction {
            id: reloadAction
            text: qsTr("Reload")
            onTriggered: {
                reloadAction.busy = true
                backend.reloadAccounts() // emits reloadFinished() when done
            }
        }

        Connections {
            target: backend
            function onReloadFinished() {
                reloadAction.busy = false
            }
        }
    }
    \endqml

    A checkable BusyAction is shown as a switch in the GroupBox header. Switching it off folds
    the content of the group box:

    \qml
    Rally.GroupBox {
        title: qsTr("Advanced")
        mainAction: Rally.BusyAction {
            checkable: true
            checked: false
        }
        // ...
    }
    \endqml

    \sa GroupBox, Dialog
*/
T.Action {


    /*!
      \qmlproperty bool BusyAction::busy
      \default false

      Set \c busy to \c true while the action is running and back to \c false once it has
      finished. Controls the action is assigned to show a busy indicator and disable the action
      while it is running.

      \sa delayedBusy, minBusyDelay
    */
    property bool busy: false


    /*!
      \qmlproperty int BusyAction::minBusyDelay
      \default 900

      The minimum time, in milliseconds, that \l delayedBusy stays \c true after \l busy became
      \c true. This prevents a busy indicator from flashing up for very short busy durations.

      \sa delayedBusy
    */
    property alias minBusyDelay: timer.interval


    /*!
      \qmlproperty bool BusyAction::delayedBusy
      \readonly

      This property is \c true while \l busy is \c true, but for at least \l minBusyDelay
      milliseconds after \l busy became \c true. Bind a busy indicator to this property rather
      than to \l busy so it does not flash up.

      \qml
      BusyIndicator {
          running: myBusyAction.delayedBusy
      }
      \endqml

      \sa busy, minBusyDelay
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
