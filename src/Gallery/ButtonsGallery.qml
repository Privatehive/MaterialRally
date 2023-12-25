import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Controls.Material
import MaterialRally as Controls

Controls.ScrollablePage {

	Button {
		text: "dialog"
		onClicked: Controls.Helper.createDialog(Qt.resolvedUrl("TestDialog.qml"))
	}

	Dialog {

		id: dialog
		parent: Overlay.overlay

		title: "asdfasdf"
		width: parent.width / 2
		x: 100
		y: 100
		height: Window.height

		Label {
			text: "asdfasdfasd fasdas sd"
		}
	}
}
