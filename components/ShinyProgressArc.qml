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
	property bool animationEnabled
	property bool shineAnimationEnabled
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

	Item {
		id: shineItem
		anchors.fill: progressShape
		visible: false

		Rectangle {
			id: shineRect

			y: parent.height/2 - height*Theme.geometry.briefPage.centerGauge.shine.highlightPosition
			x: parent.width/2
			width: parent.width/2 + 3*control.strokeWidth
			height: Theme.geometry.briefPage.centerGauge.shine.widthRatio * shineItem.height

			gradient: Gradient {
				GradientStop { position: 0; color: "transparent" }
				GradientStop { position: Theme.geometry.briefPage.centerGauge.shine.highlightPosition; color: Theme.color.briefPage.circularGauge.shine }
				GradientStop { position: 1.0; color: "transparent" }
			}

			opacity: 0.0
			Behavior on opacity { OpacityAnimator { duration: Theme.animation.page.fade.duration } }

			transform: Rotation {
				id: rot
				origin.x: 0
				origin.y: shineRect.height*Theme.geometry.briefPage.centerGauge.shine.highlightPosition
				angle: -60
			}

			SequentialAnimation {
				running: control.animationEnabled && control.shineAnimationEnabled
				loops: Animation.Infinite
				ScriptAction {
					script: { shineRect.opacity = 1.0; opacityTimer.start() }
				}
				NumberAnimation {
					target: rot
					property: "angle"
					easing { type: Easing.InOutQuad }
					from: -80 // not -90, as we want to avoid overspill from the trailing edge.
					to:   260 // not 270, as we want to avoid overspill from the leading edge.
					duration: Theme.animation.briefPage.centerGauge.shine.duration
				}
				PauseAnimation {
					duration: Theme.animation.briefPage.centerGauge.shine.duration * Theme.animation.briefPage.centerGauge.shine.pauseRatio
				}
			}
		}

		Timer {
			id: opacityTimer
			interval: Theme.animation.briefPage.centerGauge.shine.duration - Theme.animation.page.fade.duration
			onTriggered: shineRect.opacity = 0.0
		}
	}

	Effects.OpacityMask {
		visible: control.animationEnabled && control.shineAnimationEnabled
		anchors.fill: control
		maskSource: progressShape
		source: shineItem
	}
}
