import QtQuick
import QtQuick.Layouts

/*!
    \qmltype TilesLayout
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits Item

    \brief A responsive layout that packs differently sized tiles like the Windows start menu.

    TilesLayout arranges its visible children ("tiles") on a grid of square cells. A tile covers
    \c Layout.columnSpan by \c Layout.rowSpan cells (both default to 1). Tiles are placed in the
    order of the children, each at the first free position in reading order (left to right, top to
    bottom) where it fits. With \l dense enabled, a smaller tile fills a gap that a larger tile
    before it left open, just like the Windows start menu.

    The layout is responsive: the number of \l columns follows the width, so that each cell is at
    least \l cellSize wide, and the cells stretch to fill the whole width. When the width changes,
    the tiles reflow. A tile spanning more columns than there are is narrowed to all columns.

    TilesLayout sets the position and size of its tiles, overriding whatever they declare. Its
    \c implicitHeight is the height of all rows, so give it a width and let it size its own height,
    e.g. inside a \l ScrollView. A \l Repeater can create the tiles.

    The layout is not interactive: tiles can't be dragged. Rearrange them by changing the children,
    their order, their spans or their visibility. Tiles that move to another cell or change their
    span are animated there (see \l animationDuration). Tiles that only grow or shrink with the
    width, and tiles that appear, snap into place.

    \section1 Example

    \qml
    Rally.TilesLayout {
        width: parent.width
        cellSize: 80

        Rectangle { color: "teal"; Layout.columnSpan: 2; Layout.rowSpan: 2 }  // medium
        Rectangle { color: "orange" }                                         // small
        Rectangle { color: "purple"; Layout.columnSpan: 4; Layout.rowSpan: 2 } // wide
    }
    \endqml

    \sa GridLayout
*/
Item {

    id: control

    /*!
      \qmlproperty real TilesLayout::cellSize

      The minimum width and height of a cell. The cells stretch to fill the width.
    */
    property real cellSize: 80

    /*!
      \qmlproperty real TilesLayout::spacing

      The space between two cells.
    */
    property real spacing: 8

    /*!
      \qmlproperty int TilesLayout::maximumColumns

      The maximum number of columns, or 0 for no limit.
    */
    property int maximumColumns: 0

    /*!
      \qmlproperty bool TilesLayout::dense

      Whether each tile is placed at the first free position from the very beginning (\c true), so
      that smaller tiles fill gaps left open before them, or only after the tile before it
      (\c false), which keeps the order of the tiles at the cost of gaps.
    */
    property bool dense: true

    /*!
      \qmlproperty int TilesLayout::animationDuration

      The duration in milliseconds of a tile moving to another cell, or 0 to move it without an
      animation.
    */
    property int animationDuration: 250

    /*!
      \qmlproperty int TilesLayout::columns
      \readonly

      The number of columns that fit into the width.
    */
    readonly property int columns: {
        const fitting = Math.max(1, Math.floor((control.width + control.spacing)
                                               / (control.cellSize + control.spacing)))
        return control.maximumColumns > 0 ? Math.min(fitting, control.maximumColumns) : fitting
    }

    /*!
      \qmlproperty int TilesLayout::rows
      \readonly

      The number of rows the tiles occupy.
    */
    readonly property int rows: control._rows

    /*!
      \qmlproperty real TilesLayout::cellWidth
      \readonly

      The actual width (and height) of a cell after stretching it to the width of the layout.
    */
    readonly property real cellWidth: Math.max(0, (control.width - (control.columns - 1) * control.spacing)
                                                  / control.columns)

    property int _rows: 0
    // The children whose span and visibility changes are already connected to a relayout
    property var _watched: []
    // Per tile: the cell and spans it was last placed at ("column,row,columnSpan,rowSpan"), to
    // tell a tile moving to another cell from one that only follows the cell size
    property var _cells: new Map()
    // Per tile: its animation, created when it moves for the first time
    property var _animations: new Map()

    implicitWidth: control.cellSize
    implicitHeight: control._rows > 0 ? control._rows * control.cellWidth + (control._rows - 1) * control.spacing : 0

    onColumnsChanged: control._scheduleLayout()
    onCellWidthChanged: control._scheduleLayout()
    onDenseChanged: control._scheduleLayout()
    onChildrenChanged: {
        for (let i = 0; i < control.children.length; i++) {
            const child = control.children[i]
            if (control._watched.indexOf(child) < 0) {
                control._watched.push(child)
                child.visibleChanged.connect(control._scheduleLayout)
                child.Layout.columnSpanChanged.connect(control._scheduleLayout)
                child.Layout.rowSpanChanged.connect(control._scheduleLayout)
            }
        }
        // Forget removed children; a lingering connection only causes a harmless extra relayout
        control._watched = control._watched.filter(child => {
            for (let i = 0; i < control.children.length; i++) {
                if (control.children[i] === child)
                    return true
            }
            control._cells.delete(child)
            const animation = control._animations.get(child)
            if (animation) {
                animation.stop()
                animation.destroy()
                control._animations.delete(child)
            }
            return false
        })
        control._scheduleLayout()
    }

    // Coalesces all changes of one event loop iteration (e.g. a Repeater creating its tiles) into a
    // single relayout
    function _scheduleLayout() {
        // A tile can still change (e.g. its visibility) while the layout is being destroyed
        if (control)
            Qt.callLater(control._layout)
    }

    function _layout() {
        const columns = control.columns
        const step = control.cellWidth + control.spacing
        // occupied[row][column], grown row by row as tiles need them
        const occupied = []
        // Where the search for a free position starts when not dense: right after the last tile
        let startRow = 0
        let startColumn = 0

        const fits = (row, column, rowSpan, columnSpan) => {
            for (let r = row; r < row + rowSpan; r++) {
                for (let c = column; c < column + columnSpan; c++) {
                    if (occupied[r] && occupied[r][c])
                        return false
                }
            }
            return true
        }

        for (let i = 0; i < control.children.length; i++) {
            const tile = control.children[i]
            if (tile instanceof Repeater)
                continue
            if (!tile.visible) {
                // Shown again, it snaps into its new cell instead of flying in from its old one
                control._cells.delete(tile)
                continue
            }

            const columnSpan = Math.min(Math.max(1, tile.Layout.columnSpan), columns)
            const rowSpan = Math.max(1, tile.Layout.rowSpan)

            let row = control.dense ? 0 : startRow
            let column = control.dense ? 0 : startColumn
            while (column + columnSpan > columns || !fits(row, column, rowSpan, columnSpan)) {
                column++
                if (column + columnSpan > columns) {
                    column = 0
                    row++
                }
            }

            for (let r = row; r < row + rowSpan; r++) {
                if (!occupied[r])
                    occupied[r] = []
                for (let c = column; c < column + columnSpan; c++)
                    occupied[r][c] = true
            }
            startRow = row
            startColumn = column + columnSpan

            control._place(tile, [column, row, columnSpan, rowSpan].join(), column * step, row * step,
                           columnSpan * step - control.spacing, rowSpan * step - control.spacing)
        }

        control._rows = occupied.length
    }

    function _place(tile, cell, x, y, width, height) {
        const moved = control._cells.has(tile) && control._cells.get(tile) !== cell
        control._cells.set(tile, cell)
        let animation = control._animations.get(tile)

        // A running animation is retargeted, so a tile that still moves follows the cell size too
        if (control.animationDuration > 0 && (moved || (animation && animation.running))) {
            if (!animation) {
                animation = tileAnimation.createObject(control, { tile: tile })
                control._animations.set(tile, animation)
            }
            animation.stop()
            animation.toX = x
            animation.toY = y
            animation.toWidth = width
            animation.toHeight = height
            animation.start()
        } else {
            if (animation)
                animation.stop()
            tile.x = x
            tile.y = y
            tile.width = width
            tile.height = height
        }
    }

    Component {

        id: tileAnimation

        ParallelAnimation {

            id: animation

            property Item tile
            property real toX
            property real toY
            property real toWidth
            property real toHeight

            NumberAnimation {
                target: animation.tile
                property: "x"
                to: animation.toX
                duration: control.animationDuration
                easing.type: Easing.OutQuart
            }

            NumberAnimation {
                target: animation.tile
                property: "y"
                to: animation.toY
                duration: control.animationDuration
                easing.type: Easing.OutQuart
            }

            NumberAnimation {
                target: animation.tile
                property: "width"
                to: animation.toWidth
                duration: control.animationDuration
                easing.type: Easing.OutQuart
            }

            NumberAnimation {
                target: animation.tile
                property: "height"
                to: animation.toHeight
                duration: control.animationDuratio
                easing.type: Easing.OutQuart
            }
        }
    }
}
