pragma Singleton

import QtQuick
import QtQuick.Controls as T
import MaterialRally as Rally
import "helper.js" as Helper

QtObject {

    function createDialog(url, options, offset) {

        return Helper.createDialog(url, Rally.RootItem.contentItem, options, offset)
    }

    function createInfoDialog(text, offset) {

        return Helper.createDialog(Qt.resolvedUrl("InfoDialog.qml"), Rally.RootItem.contentItem, {"text": text}, offset)
    }

    function createItem(url, parent, options) {

        return Helper.createItem(url, parent, options)
    }

    function callDelayed(functor, msDelay) {

        return Helper.callDelayed(functor, msDelay)
    }
}
