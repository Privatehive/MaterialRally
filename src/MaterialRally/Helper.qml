pragma Singleton
import QtQuick
import QtQuick.Controls as T
import "helper.js" as Helper
import MaterialRally as Controls

QtObject {

	function createDialog(url, options) {

		Helper.createDialog(url, Controls.RootItem.contentItem, options)
	}
}