import QtQml
import QtQuick.Controls as T

T.Action {

    property bool busy: false
    property alias minBusyDelay: timer.interval
    // This property equals true for at least 'minBusyDelay' ms
    // Bind this property to a progress bar so it does not flash up
    readonly property bool delayedBusy: busy || timer.running

    onBusyChanged: {
        if (busy) {
            timer.restart()
        }
    }

    readonly property var delayTimer: Timer {
        id: timer
        interval: 900
    }
}
