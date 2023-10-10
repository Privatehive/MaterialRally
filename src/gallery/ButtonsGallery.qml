import QtQuick
import QtQml
import QtQuick.Controls


Item {

	Button {
		text: "dialog " + Window.width
		onClicked: dialog.open()
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
