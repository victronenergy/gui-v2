/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Item {
	id: root

	property real startX: NaN
	property real startY: NaN
	property real endX: NaN
	property real endY: NaN
	property real turnX: NaN
	property real turnY: NaN
	property bool horizontalFirst: true
	property color strokeColor: "#2F70D8"
	property real strokeWidth: 2
	property real headLength: 8
	property real headWidth: 6
	property real cornerRadius: 12

	function _isFiniteNumber(value) {
		return typeof value === "number" && isFinite(value)
	}

	function _pathPoints() {
		const points = [{ x: root.startX, y: root.startY }]
		if (_isFiniteNumber(root.turnX)) {
			points.push({ x: root.turnX, y: root.startY })
			points.push({ x: root.turnX, y: root.endY })
		} else if (_isFiniteNumber(root.turnY)) {
			points.push({ x: root.startX, y: root.turnY })
			points.push({ x: root.endX, y: root.turnY })
		} else if (root.horizontalFirst) {
			points.push({ x: root.endX, y: root.startY })
		} else {
			points.push({ x: root.startX, y: root.endY })
		}
		points.push({ x: root.endX, y: root.endY })

		const compact = []
		for (let i = 0; i < points.length; ++i) {
			if (compact.length === 0) {
				compact.push(points[i])
				continue
			}
			const previous = compact[compact.length - 1]
			if (Math.abs(points[i].x - previous.x) > 0.5 || Math.abs(points[i].y - previous.y) > 0.5) {
				compact.push(points[i])
			}
		}
		return compact
	}

	readonly property bool _validGeometry: _isFiniteNumber(startX)
			&& _isFiniteNumber(startY)
			&& _isFiniteNumber(endX)
			&& _isFiniteNumber(endY)

	onStartXChanged: canvas.requestPaint()
	onStartYChanged: canvas.requestPaint()
	onEndXChanged: canvas.requestPaint()
	onEndYChanged: canvas.requestPaint()
	onTurnXChanged: canvas.requestPaint()
	onTurnYChanged: canvas.requestPaint()
	onHorizontalFirstChanged: canvas.requestPaint()
	onStrokeColorChanged: canvas.requestPaint()
	onStrokeWidthChanged: canvas.requestPaint()
	onHeadLengthChanged: canvas.requestPaint()
	onHeadWidthChanged: canvas.requestPaint()
	onVisibleChanged: canvas.requestPaint()

	Canvas {
		id: canvas

		anchors.fill: parent
		antialiasing: true

		onPaint: {
			const context = getContext("2d")
			context.clearRect(0, 0, width, height)
			if (!root.visible || !root._validGeometry) {
				return
			}

			const points = root._pathPoints()
			if (points.length < 2) {
				return
			}

			context.beginPath()
			context.lineWidth = root.strokeWidth
			context.strokeStyle = root.strokeColor
			context.lineCap = "round"
			context.lineJoin = "round"
			context.moveTo(points[0].x, points[0].y)

			for (let i = 1; i < points.length - 1; ++i) {
				const previous = points[i - 1]
				const current = points[i]
				const next = points[i + 1]
				const dx1 = current.x - previous.x
				const dy1 = current.y - previous.y
				const dx2 = next.x - current.x
				const dy2 = next.y - current.y
				const len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1)
				const len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)

				if (len1 < 0.001 || len2 < 0.001) {
					context.lineTo(current.x, current.y)
					continue
				}

				const radius = Math.min(root.cornerRadius, len1 * 0.45, len2 * 0.45)
				const beforeX = current.x - (dx1 / len1) * radius
				const beforeY = current.y - (dy1 / len1) * radius
				const afterX = current.x + (dx2 / len2) * radius
				const afterY = current.y + (dy2 / len2) * radius

				context.lineTo(beforeX, beforeY)
				context.quadraticCurveTo(current.x, current.y, afterX, afterY)
			}
			context.lineTo(points[points.length - 1].x, points[points.length - 1].y)
			context.stroke()

			const tip = points[points.length - 1]
			const tail = points[points.length - 2]
			const angle = Math.atan2(tip.y - tail.y, tip.x - tail.x)
			const halfWidth = root.headWidth * 0.5
			const leftX = tip.x - root.headLength * Math.cos(angle) - halfWidth * Math.sin(angle)
			const leftY = tip.y - root.headLength * Math.sin(angle) + halfWidth * Math.cos(angle)
			const rightX = tip.x - root.headLength * Math.cos(angle) + halfWidth * Math.sin(angle)
			const rightY = tip.y - root.headLength * Math.sin(angle) - halfWidth * Math.cos(angle)

			context.beginPath()
			context.fillStyle = root.strokeColor
			context.moveTo(tip.x, tip.y)
			context.lineTo(leftX, leftY)
			context.lineTo(rightX, rightY)
			context.closePath()
			context.fill()
			context.stroke()
		}

		onWidthChanged: requestPaint()
		onHeightChanged: requestPaint()
		Component.onCompleted: requestPaint()
	}
}
