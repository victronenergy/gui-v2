/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS.Shaders

import Victron.VenusOS

CT.Button {
	id: root

	property bool pressEffectRunning

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
							implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
							 implicitContentHeight + topPadding + bottomPadding)
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0
	text: down ? CommonWords.on : CommonWords.press
	down: pressed || checked

	onPressEffectRunningChanged: {
		// When triggered by a key press, start the press animation from the center of the button;
		// otherwise, start it from the mouse click position.
		if (pressEffectRunning) {
			const clickX = pressed ? pressX : (width / 2)
			const clickY = pressed ? pressY : (height / 2)
			shaderEffect.touchPos = Qt.point(clickX / width, clickY / height)
			shaderAnimation.start()
		} else {
			shaderAnimation.stop()
		}
	}

	background: Rectangle {
		id: backgroundRect

		color: root.enabled ? (root.down ? Theme.color_ok : Theme.color_darkOk) : Theme.color_background_disabled
		border.width: Theme.geometry_button_border_width
		border.color: root.enabled ? Theme.color_ok : Theme.color_font_disabled
		radius: Theme.geometry_button_radius

		BasePressEffect {
			id: shaderEffect

			anchors.fill: parent
			radius: backgroundRect.radius
			color: Theme.color_dimWhite2

			ParallelAnimation {
				id: shaderAnimation
				loops: Animation.Infinite
				alwaysRunToEnd: true

				// Use NumberAnimation instead of OpacityAnimator, as the latter does not run at
				// precise intervals when the animation is looped continuously, which makes the
				// animation look slightly jerky.
				NumberAnimation {
					target: shaderEffect
					property: "opacity"
					from: 1.0
					to: 0.0
					duration: Theme.animation_momentary_button_effect_duration
					easing.type: Easing.OutSine
				}

				// TODO: Migrate to non-blocking UniformAnimator once QTBUG-124152 has been fixed
				NumberAnimation {
					target: shaderEffect
					property: "progress"
					from: 0.0
					to: 1.0
					duration: Theme.animation_momentary_button_effect_duration
					easing.type: Easing.OutSine
				}
			}
		}
	}

	contentItem: Label {
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		text: root.text
		color: enabled ? (root.down ? Theme.color_button_down_text : Theme.color_font_primary) : Theme.color_font_disabled
	}

	KeyNavigationHighlight.active: root.activeFocus
}
