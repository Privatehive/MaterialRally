pragma Singleton
import QtQuick
import QtQuick.Controls as T
import "helper.js" as Helper
import MaterialRally as Controls

QtObject {

	function createDialog(url, options, offset) {

		return Helper.createDialog(url, Controls.RootItem.contentItem, options, offset)
	}

	function createItem(url, parent, options) {

        return Helper.createItem(url, parent, options)
	}
}