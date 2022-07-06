/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import Qt5Compat.GraphicalEffects as Effects

Item {
	id: control

	property real value
	property real radius
	property bool shineAnimationEnabled: false
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
			duration: Theme.animation.progressArc.duration
			easing.type: Easing.InOutQuad
		}
	}

	Shape {
		anchors.fill: parent

		Arc {
			id: remainder

			radius: control.radius
			startAngle: control.transitionAngle
			direction: control.direction
			strokeWidth: control.strokeWidth
			strokeColor: Theme.color.darkOk
			fillColor: control.fillColor
		}
	}

	// Unfortunately, we need two separate Shape items in the shine animation case,
	// as we need to use an Item-derived type as the maskSource of the OpacityMask,
	// and thus a ShapePath cannot be used as the maskSource
	// (and we only want the shine over the "progress" area, not "remainder").
	Shape {
		id: progressShape
		anchors.fill: parent

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

	Effects.ConicalGradient {
		id: shineGradient
		anchors.fill: progressShape
		visible: false
		angle: control.endAngle

		SequentialAnimation {
			running: control.animationEnabled && control.shineAnimationEnabled
			loops: Animation.Infinite
			NumberAnimation {
				target: shineGradient
				property: "shineLocation"
				easing { type: Easing.InQuad }
				from: 0.0
				to: 1.0
				duration: Theme.animation.briefPage.centerGauge.shine.duration
			}
			PauseAnimation {
				duration: Theme.animation.briefPage.centerGauge.shine.duration * Theme.animation.briefPage.centerGauge.shine.pauseRatio
			}
		}

		property real shineLocation: 0.0
		property real shineWidth: Theme.animation.briefPage.centerGauge.shine.width
		property real shineHighlight: Theme.animation.briefPage.centerGauge.shine.highlight
		gradient: Gradient {
			GradientStop { position: Math.max(0.0, shineGradient.shineLocation - shineGradient.shineWidth); color: "transparent" }
			GradientStop { position: Math.max(0.0, shineGradient.shineLocation - shineGradient.shineHighlight); color: shineGradient.shineLocation < 1.0 ? Theme.color.briefPage.circularGauge.shine : "transparent" }
			GradientStop { position: Math.max(0.0, shineGradient.shineLocation); color: "transparent" }
		}
	}

	Effects.OpacityMask {
		visible: control.shineAnimationEnabled
		anchors.fill: control
		maskSource: progressShape
		source: shineGradient
	}
}
