/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import QtQuick.Effects as Effects

Item {
	id: control

	property real value
	property real radius
	property bool animationEnabled
	property bool shineAnimationEnabled
	property real strokeWidth: Theme.geometry_progressArc_strokeWidth
	property alias progressColor: progress.strokeColor
	property alias remainderColor: remainder.strokeColor
	property alias startAngle: remainder.startAngle
	property alias endAngle: remainder.endAngle
	property int direction: PathArc.Clockwise
	property color fillColor: "transparent"

	property real transitionAngle: startAngle + ((endAngle - startAngle) * Math.min(Math.max(control.value, 0.0), 100.0) / 100.0)

	Shape {
		anchors.fill: parent

		Arc {
			id: remainder

			radius: control.radius
			startAngle: control.transitionAngle
			direction: control.direction
			strokeWidth: control.strokeWidth
			strokeColor: Theme.color_darkOk
			fillColor: control.fillColor
		}
	}

	// Unfortunately, we need two separate Shape items in the shine animation case,
	// as we need to use a layer-enabled Item-derived type as the maskSource of the MultiEffect,
	// and thus a ShapePath cannot be used as the maskSource
	// (and we only want the shine over the "progress" area, not "remainder").
	Shape {
		id: progressShape
		anchors.fill: parent
		layer.enabled: true

		Arc {
			id: progress

			animationEnabled: control.animationEnabled
			radius: control.radius
			startAngle: remainder.startAngle
			endAngle: control.transitionAngle
			direction: control.direction
			strokeWidth: control.strokeWidth
			strokeColor: Theme.color_ok
			fillColor: control.fillColor
		}
	}

	Item {
		id: shineItem
		anchors.fill: progressShape
		visible: false // set this to true, and disable the maskEffect, to see the basic shine in action.

		Item {
			id: shineBar

			height: parent.height
			width: 10 * control.strokeWidth // this defines the length of the shine effect, basically, as it will be half this width.
			x: (parent.width - width) / 2

			Rectangle {
				id: shineRect

				// the length of the shine.
				width: parent.width / 2

				// raise up and allow enough overlap to ensure that there are no pixels "missed" during the rotation.
				height: width
				y: -height / 3

				// the highlight position of the shine must line up with the horizontal centre of the parent to ensure that it is always perpendicular to the arc direction as it rotates.
				x: (parent.width - width) / 2 - (width * Theme.geometry_briefPage_centerGauge_shine_highlightPosition) / 2

				opacity: 1.0

				gradient: Gradient {
					orientation: Gradient.Horizontal
					GradientStop {
						position: 0
						color: "transparent"
					}
					GradientStop {
						position: Theme.geometry_briefPage_centerGauge_shine_highlightPosition
						color: Theme.color_briefPage_circularGauge_shine
					}
					GradientStop {
						position: 1.0
						color: "transparent"
					}
				}
			}

			ParallelAnimation {
				running: maskEffect.visible
				loops: Animation.Infinite
				SequentialAnimation {
					OpacityAnimator {
						id: fadeInAnimator
						target: shineBar
						from: 0.0
						to: 0.998
						duration: 2 * Theme.animation_page_fade_duration
					}
					OpacityAnimator {
						id: brightPauseAnimator // effectively a pause animation, but need it to be an animator...
						target: shineBar
						from: 0.998
						to: 1.0
						duration: rotationAnimator.duration - fadeInAnimator.duration - fadeOutAnimator.duration
					}
					OpacityAnimator {
						id: fadeOutAnimator
						target: shineBar
						from: 1.0
						to: 0.002
						duration: Theme.animation_page_fade_duration
					}
					OpacityAnimator {
						id: waitPauseAnimator // effectively a pause animation, but need it to be an animator...
						target: shineBar
						from: 0.002
						to: 0.0
						duration: pauseAnimator.duration
					}
				}
				SequentialAnimation {
					RotationAnimator {
						id: rotationAnimator
						target: shineBar
						easing {
							type: Easing.InOutCubic
						}
						from: -2 // avoid overspill from the trailing edge.
						to: 349 // avoid overspill from the leading edge.
						duration: Theme.animation_briefPage_centerGauge_shine_duration
					}
					RotationAnimator {
						id: pauseAnimator // effectively a pause animation, but need it to be an animator...
						target: shineBar
						from: 349
						to: 350
						duration: Theme.animation_briefPage_centerGauge_shine_duration * Theme.animation_briefPage_centerGauge_shine_pauseRatio
					}
				}
			}
		}
	}

	Effects.MultiEffect {
		id: maskEffect
		visible: control.animationEnabled && control.shineAnimationEnabled
		anchors.fill: progressShape
		maskEnabled: true
		maskSource: progressShape
		source: shineItem
	}
}
