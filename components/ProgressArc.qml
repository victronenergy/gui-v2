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
	property real strokeWidth: Theme.geometry.progressArc.strokeWidth
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
			onRunningChanged: console.log("ProgressArc animation: running:", running)
			duration: Theme.animation.progressArc.duration
			easing.type: Easing.InOutQuad
		}
	}

	Arc {
		id: remainder

		radius: control.radius
		startAngle: control.transitionAngle
		direction: control.direction
		strokeWidth: control.strokeWidth
		strokeColor: Theme.color.darkOk
		fillColor: control.fillColor
	}

	Arc {
		id: progress

		radius: control.radius
		endAngle: control.transitionAngle
		direction: control.direction
		strokeWidth: control.strokeWidth
		strokeColor: Theme.color.ok
		fillColor: control.fillColor
	}
}
