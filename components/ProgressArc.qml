/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Shape {
	id: control

	property real value
	property real w
	property bool animationEnabled: true
	property real strokeWidth: 10
	property alias progressColor: progress.strokeColor
	property alias remainderColor: remainder.strokeColor

	property real transitionAngle: 270 * Math.min(Math.max(control.value, 0.0), 100.0) / 100.0
	Behavior on transitionAngle {
		enabled: control.animationEnabled
		NumberAnimation {
			duration: 600
			easing.type: Easing.InOutQuad
		}
	}

	Arc {
		id:remainder
		w: control.w
		startAngle: control.transitionAngle
		endAngle: 270
		strokeWidth: control.strokeWidth
		strokeColor: Theme.dimColor
	}

	Arc {
		id: progress
		w: control.w
		startAngle: 0
		endAngle: control.transitionAngle
		strokeWidth: control.strokeWidth
		strokeColor: Theme.highlightColor
	}
}
