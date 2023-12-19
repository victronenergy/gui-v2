/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Effects as Effects
import Victron.VenusOS

Rectangle {
	id: bgRect

	property alias backgroundColor: bgRect.color
	property alias foregroundColor: fgRect.color
	property real value: 0.0
	property real _value: isNaN(value) || value < 0 ? 0 : Math.min(1.0, value)
	property bool animationEnabled

	onAnimationEnabledChanged: fgRect.resetYBinding()

	Rectangle {
		id: maskRect
		layer.enabled: true
		visible: false
		width: bgRect.width
		height: bgRect.height
		radius: bgRect.radius
		color: "black" // opacity mask, not visible.
	}

	Item {
		id: sourceItem
		visible: false
		width: parent.width
		height: parent.height

		Rectangle {
			id: fgRect

			width: parent.width
			height: parent.height
			color: Theme.color_ok
			y: nextY

			// don't use a behavior on Y
			// otherwise there can be a "jump" we receive receive two value updates in close succession.
			readonly property real nextY: maskRect.height - (fgRect.height*bgRect._value)

			// when the animation isn't handling y changes, we need to reassign
			// the initial binding, to ensure the value is correct when not animating.
			function resetYBinding() {
				if (!bgRect.animationEnabled && !anim.running) {
					y = Qt.binding(function() { return fgRect.nextY })
				}
			}

			onNextYChanged: {
				if (!anim.running && bgRect.animationEnabled) {
					anim.from = fgRect.y
					// do a little dance to break the y binding...
					fgRect.y = 0
					fgRect.y = anim.from
					anim.to = fgRect.nextY
					anim.start()
				}
			}

			YAnimator {
				id: anim
				target: fgRect
				easing.type: Easing.InOutQuad
				duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
				onRunningChanged: fgRect.resetYBinding()
			}
		}
	}

	Effects.MultiEffect {
		visible: true
		anchors.fill: parent
		maskEnabled: true
		maskSource: maskRect
		source: sourceItem
	}
}
