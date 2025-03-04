/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

ShapePath {
	id: path

	property bool animationEnabled: true
	property real radius
	property real startAngle
	property real endAngle
	property alias direction: arc.direction
	property alias useLargeArc: arc.useLargeArc

	readonly property real _reducedRadius: radius - strokeWidth/2

	readonly property var _startOffsets: [Math.cos(_startAngleRadians), Math.sin(_startAngleRadians)]
	readonly property var _endOffsets: [Math.cos(_endAngleRadians), Math.sin(_endAngleRadians)]

	readonly property real _startAngleRadians: FastUtils.degreesToRadians(startAngle)
	readonly property real _endAngleRadians: FastUtils.degreesToRadians(animatedEndAngle)
	property real animatedEndAngle: endAngle

	strokeColor: "black"
	strokeWidth: Theme.geometry_arc_strokeWidth
	fillColor: "transparent"
	capStyle: ShapePath.RoundCap
	joinStyle: ShapePath.RoundJoin

	startX: radius + _startOffsets[1] * _reducedRadius
	startY: radius - _startOffsets[0] * _reducedRadius

	Behavior on animatedEndAngle {
		enabled: path.animationEnabled
		NumberAnimation {
			duration: Theme.animation_progressArc_duration
			easing.type: Easing.InOutQuad
		}
	}

	PathArc {
		id: arc

		radiusX: path._reducedRadius
		radiusY: path._reducedRadius

		// has to use animatedEndAngle rather than endAngle,
		// or when values flip from large->small or small->large,
		// the arc is drawn wrongly for a few frames.
		useLargeArc: (animatedEndAngle - startAngle) > 180

		x: path.radius + path._endOffsets[1] * path._reducedRadius
		y: path.radius - path._endOffsets[0] * path._reducedRadius
	}
}
