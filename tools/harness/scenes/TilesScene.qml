import QtQuick
import QtQuick.Layouts
import MaterialRally as Rally

// Tiles of the Windows start menu sizes: small (1x1), medium (2x2) and wide (4x2). With a cellSize
// of 92 and a spacing of 8, every 100px of width (plus 8) make one column. The two tiles created by
// the Repeater come last.
Window {
    width: 400
    height: 800
    visible: true
    color: "#202020"

    // A tile's [column, row] in the grid
    function cell(tile) {
        const step = tiles.cellWidth + tiles.spacing
        return [Math.round(tile.x / step), Math.round(tile.y / step)]
    }

    Rally.TilesLayout {
        id: tiles
        width: parent.width
        cellSize: 92
        spacing: 8

        Rectangle { id: a; color: "#1eb980"; Layout.columnSpan: 2; Layout.rowSpan: 2 }
        Rectangle { id: b; color: "#ffcf44" }
        Rectangle { id: c; color: "#ff6859" }
        Rectangle { id: d; color: "#72deff"; Layout.columnSpan: 4; Layout.rowSpan: 2 }
        Rectangle { id: e; color: "#b15dff" }
        Rectangle { id: f; color: "#045d56" }

        Repeater {
            model: 2
            Rectangle {
                required property int index
                objectName: "r" + index
                color: "white"
            }
        }
    }
}
