import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    id: control

    spacing: 10

    onChildrenChanged: {

        for (var i = 0; i < control.children.length; i++) {

            control.children[i].Layout.fillWidth = true
        }
    }
}
