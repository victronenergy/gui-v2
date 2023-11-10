/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import QtQuick.Effects as Effects

Item {
	id: control

	property real arcX
	property real arcY
	property real arcWidth
	property real arcHeight

	property real value // 0 - 100
	property real radius
	property real strokeWidth: Theme.geometry.progressArc.strokeWidth
	property bool animationEnabled
	property alias progressColor: progress.color
	property alias remainderColor: remainder.strokeColor
	property alias startAngle: remainder.startAngle
	property alias endAngle: remainder.endAngle
	property alias useLargeArc: remainder.useLargeArc
	property int direction: PathArc.Clockwise
	property color fillColor: "transparent"

	property real transitionAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max((isNaN(control.value) ? 0 : control.value), 0.0), 100.0) / 100.0)

	Item {
		id: remainderContainer
		anchors.fill: parent
		layer.enabled: true

		Shape {
			id: remainderShape

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
		}
	}

	Item {
		id: progressContainer
		visible: false
		anchors.fill: parent
		layer.enabled: true

		Rectangle {
			id: progress
			color: Theme.color.ok
			width: parent.width
			height: parent.height

			y: {
				if (control.startAngle >= 270 && control.startAngle <= 360
						&& control.endAngle >= 270 && control.endAngle <= 360) {
					// quarter gauge in the upper left.
					// grow from bottom to top.
					return (height - (height * (control.value/100.0)))
				} else if (control.startAngle >= 180 && control.startAngle <= 270
						&& control.endAngle >= 180 && control.endAngle <= 270) {
					// quarter gauge in lower left
					// grow from top to bottom.
					return (-height + (height * (control.value/100.0)))
				} else if (control.startAngle >= 90 && control.startAngle <= 180
						&& control.endAngle >= 90 && control.endAngle <= 180) {
					// quarter gauge in lower right.
					// grow from top to bottom.
					return (-height + (height * (control.value/100.0)))
				} else {
					// either quarter gauge in upper right, or half-spanning gauge.
					// grow from bottom to top.
					return (height - (height * (control.value/100.0)))
				}
			}

			Behavior on y {
				enabled: control.animationEnabled
				YAnimator {
					duration: Theme.animation.progressArc.duration
					easing.type: Easing.InOutQuad
				}
			}
		}
	}

	Effects.MultiEffect {
		anchors.fill: parent
		visible: true
		maskEnabled: true
		maskThresholdMin: 0.05
		maskSource: remainderContainer
		source: progressContainer
	}
}
