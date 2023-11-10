/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: control

	property real arcX
	property real arcY
	property real arcWidth
	property real arcHeight

	property real value // 0 - 100
	property real radius
	property real strokeWidth: Theme.geometry.progressArc.strokeWidth
	property alias useLargeArc: progress.useLargeArc
	property alias animationEnabled: progress.animationEnabled
	property alias progressColor: progress.strokeColor
	property alias remainderColor: remainder.strokeColor
	property alias startAngle: remainder.startAngle
	property alias endAngle: remainder.endAngle
	property int direction: PathArc.Clockwise
	property color fillColor: "transparent"

	property real transitionAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max((isNaN(control.value) ? 0 : control.value), 0.0), 100.0) / 100.0)

	Shape {
		// The arc shape bounds are defined by the radius of the curve, not the parent bounds.
		// Thus, it will likely be very large.  Don't enable a layer on it.
		width: control.arcWidth
		height: control.arcHeight
		x: control.arcX
		y: control.arcY

		Arc {
			id: remainder

			radius: control.radius
			direction: control.direction
			strokeWidth: control.strokeWidth
			strokeColor: Theme.color.darkOk
			fillColor: control.fillColor
		}

		Arc {
			id: progress

			radius: control.radius
			startAngle: remainder.startAngle
			endAngle: control.transitionAngle
			direction: control.direction
			strokeWidth: control.strokeWidth
			strokeColor: Theme.color.ok
			fillColor: control.fillColor
		}
	}
}
