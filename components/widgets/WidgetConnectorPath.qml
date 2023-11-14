/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int direction: Qt.Horizontal
	property bool expanded

	// start/end anchor points
	property real startAnchorX
	property real startAnchorY
	property real startAnchorCompactY
	property real startAnchorExpandedY
	property real endAnchorX
	property real endAnchorY
	property real endAnchorCompactY
	property real endAnchorExpandedY

	// y pos for this item
	property real compactY
	property real expandedY

	// distance between anchor points on the x and y axes
	property real xDistance
	property real yDistance: compactYDistance
	property real compactYDistance
	property real expandedYDistance
	property real _midpointX
	readonly property real _midpointY: yDistance / 2

	// Initialize y values to their compact variants. The height does not need to change when
	// switching between compact/expanded mode as the Item height does not affect the path.
	y: compactY
	startAnchorY: startAnchorCompactY
	endAnchorY: endAnchorCompactY

	function reloadPathLayout() {
		xDistance = endAnchorX - startAnchorX
		_midpointX = xDistance / 2

		compactYDistance = endAnchorCompactY - startAnchorCompactY
		expandedYDistance = endAnchorExpandedY - startAnchorExpandedY
	}

	property list<QtObject> pathElements: [
		PathArc {
			id: startArc

			x: _midpointX
			y: startAnchorY < endAnchorY
			   ? Math.min(Math.abs(_midpointX), Math.abs(_midpointY))  // the smallest available radius
			   : -Math.min(Math.abs(_midpointX), Math.abs(_midpointY))
			radiusX: x
			radiusY: y
			direction: (_midpointX < 0 && _midpointY < 0) || (_midpointX > 0 && _midpointY > 0)
					   ? PathArc.Clockwise : PathArc.Counterclockwise
		},

		PathLine {
			id: line

			relativeX: startAnchorY == endAnchorY ? xDistance : 0
			relativeY: yDistance - startArc.radiusY - endArc.radiusY
		},

		PathArc {
			id: endArc

			relativeX: startArc.x
			relativeY: startArc.y
			radiusX: startArc.radiusX
			radiusY: startArc.radiusY
			direction: startArc.direction == PathArc.Counterclockwise
					   ? PathArc.Clockwise
					   : PathArc.Counterclockwise
		}
	]
}
