/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Effects as Effects
import Victron.VenusOS
import Victron.Gauges

Rectangle {
	id: bgRect

	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	readonly property int valueStatus: Gauges.getValueStatus(_value * 100, valueType)
	property color foregroundColor: Theme.statusColorValue(valueStatus)
	property color backgroundColor: Theme.statusColorValue(valueStatus, true)
	property real value: 0.0
	property int orientation: Qt.Vertical
	property bool animationEnabled

	readonly property real _value: isNaN(value) ? 0 : Math.min(1.0, Math.max(0, value))

	color: backgroundColor
	width: orientation === Qt.Vertical ? Theme.geometry_barGauge_vertical_width_large : parent.width
	height: orientation === Qt.Vertical ? parent.height : Theme.geometry_barGauge_horizontal_height
	radius: orientation === Qt.Vertical ? width / 2 : height / 2

	// Only update the nextPos when visible and width/height have been initialized.
	readonly property real _nextPos: visible && width !== Infinity && height !== Infinity
			? orientation === Qt.Vertical
				? height - (height * _value)    // slide in from bottom to top
				: -width + (width * _value)     // slide in from left to right
			: 0

	on_NextPosChanged: {
		if (animationEnabled) {
			const animator = orientation === Qt.Vertical ? yAnimator : xAnimator
			animator.to = _nextPos
			animator.start()
		} else if (visible) {
			if (orientation === Qt.Vertical) {
				fgRect.y = _nextPos
			} else {
				fgRect.x = _nextPos
			}
		}
	}

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
			color: foregroundColor

			// Use animators instead of a behavior on x/y. Otherwise, there can be a "jump" when
			// receiving two value updates in close succession.
			XAnimator {
				id: xAnimator
				target: fgRect
				easing.type: Easing.InOutQuad
				duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
			}
			YAnimator {
				id: yAnimator
				target: fgRect
				easing.type: Easing.InOutQuad
				duration: Theme.animation_briefPage_sidePanel_sliderValueChange_duration
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
