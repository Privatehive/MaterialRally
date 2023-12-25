import QtQuick
import QtQuick.Controls as T
import QtQuick.Layouts as T

T.GridLayout {

    id: control

    readonly property real minWidth: 200

    columns: Math.max(1, width / 300)

    columnSpacing: 20
    rowSpacing: 20

    onChildrenChanged: {

        for (var i = 0; i < control.children.length; i++) {

            control.children[i].T.Layout.fillWidth = true
            control.children[i].T.Layout.fillHeight = true
            control.children[i].T.Layout.alignment = Qt.AlignVCenter | Qt.AlignTop
            control.children[i].T.Layout.minimumWidth = control.minWidth
            control.children[i].T.Layout.preferredWidth = control.minWidth
        }
    }
}
