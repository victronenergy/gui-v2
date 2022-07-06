/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes

ShapePath {
	id: path

	property real radius
	property real startAngle
	property real endAngle
	property alias direction: arc.direction
	property alias useLargeArc: arc.useLargeArc

	readonly property var startOffsets: angleToCoords(degreesToRadians(startAngle))
	readonly property var endOffsets: angleToCoords(degreesToRadians(endAngle))

	readonly property real _reducedRadius: radius - strokeWidth/2

	function angleToCoords(theta) {
		const x = Math.cos(theta)
		const y = Math.sin(theta)
		return [x, y]
	}

	function degreesToRadians(degrees) {
		return Math.PI/180 * degrees
	}

	strokeColor: "black"
	strokeWidth: Theme.geometry.arc.strokeWidth
	fillColor: "transparent"
	capStyle: ShapePath.RoundCap
	joinStyle: ShapePath.RoundJoin

	startX: path.radius + path.startOffsets[1] * path._reducedRadius
	startY: path.radius - path.startOffsets[0] * path._reducedRadius

	PathArc {
		id: arc

		radiusX: path._reducedRadius
		radiusY: path._reducedRadius
		useLargeArc: (endAngle - startAngle) > 180
		x: path.radius + path.endOffsets[1] * path._reducedRadius
		y: path.radius - path.endOffsets[0] * path._reducedRadius
	}
}
