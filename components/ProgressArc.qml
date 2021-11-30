/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Shape {
	id: control

	property real value
	property real radius
	property bool animationEnabled: true
	property real strokeWidth: 10
	property alias progressColor: progress.strokeColor
	property alias remainderColor: remainder.strokeColor
	property alias startAngle: progress.startAngle
	property alias endAngle: remainder.endAngle
	property int direction: PathArc.Clockwise
	property color fillColor: "transparent"

	property real transitionAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max(control.value, 0.0), 100.0) / 100.0)
	Behavior on transitionAngle {
		enabled: control.animationEnabled
		NumberAnimation {
			duration: 600
			easing.type: Easing.InOutQuad
		}
	}

	Arc {
		id: remainder

		radius: control.radius
		startAngle: control.transitionAngle
		direction: control.direction
		strokeWidth: control.strokeWidth
		strokeColor: Theme.dimColor
		fillColor: control.fillColor
	}

	Arc {
		id: progress

		radius: control.radius
		endAngle: control.transitionAngle
		direction: control.direction
		strokeWidth: control.strokeWidth
		strokeColor: Theme.highlightColor
		fillColor: control.fillColor
	}
}
