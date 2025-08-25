import QtQuick
import QtQuick.Controls

Canvas {

    id: canvas

    implicitHeight: 40
    implicitWidth: 40

    property real lineWidth: 3
    // 1 = full circle
    property real startAngle: 0
    // 1 = full circle
    property real endAngle: 1
    readonly property real remainingAngle: 1 - endAngle + startAngle

    property color color: "white"

    onStartAngleChanged: {
        requestPaint()
    }

    onEndAngleChanged: {
        requestPaint()
    }

    onColorChanged: {
        requestPaint()
    }

    onLineWidthChanged: {
        requestPaint()
    }

    onWidthChanged: {
        requestPaint()
    }

    onHeightChanged: {
        requestPaint()
    }

    onPaint: {

        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.strokeStyle = canvas.color
        ctx.fillStyle = "black"
        ctx.lineWidth = lineWidth
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth / 2 - width * 0.22,
                startAngle * 2 * Math.PI, endAngle * 2 * Math.PI)
        ctx.stroke()
    }

    Rectangle {
        color: "black"
        width: parent.width
        height: parent.height
        radius: width / 2
        z: -1
    }
}
