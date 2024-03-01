import QtQuick
import QtQuick.Controls
import MaterialRally as Controls

Controls.Dialog {

    title: "test"
    onBackButtonClicked: {
        close()
    }
}
