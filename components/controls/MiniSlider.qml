/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Slider {
	id: root

	property color highlightColor: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property color backgroundColor: enabled ? Theme.color_darkOk : Theme.color_background_disabled
	property bool animationEnabled: visible && Global.animationEnabled

	// This is the standard indicator width, plus left/right padding on either side.
	property real indicatorBackgroundWidth: (Theme.geometry_slider_indicator_width * 3)

	property real sliderX
	property real nextSliderX: leftPadding
		+ borderWidth
		+ (root.visualPosition * (root.availableWidth - indicatorBackgroundWidth - 2*borderWidth))

	Component.onCompleted: {
		anim.duration = Theme.animation_slider_valueChange_duration
	}

	onNextSliderXChanged: {
		if (!root.animationEnabled) {
			sliderX = nextSliderX
		} else {
			anim.stop()
			anim.from = sliderX
			anim.to = nextSliderX
			anim.start()
		}
	}

	property color borderColor: enabled ? Theme.color_ok : Theme.color_font_disabled
	property int borderWidth: Theme.geometry_button_border_width

	implicitHeight: Theme.geometry_dimmingSlider_height
	background: Rectangle {
		// Provide the background border using this solid Rectangle, instead of setting a border
		// property that results in transparent pixels at the corners of the inner rectangles.
		radius: Theme.geometry_slider_groove_radius
		color: root.borderColor

		// Inner rectangle that fills the slider area to the right of the handle.
		Rectangle {
			anchors {
				fill: parent
				margins: root.borderWidth
			}
			radius: Theme.geometry_slider_groove_radius - root.borderWidth
			color: root.backgroundColor
		}

		// Inner rectangle that fills the slider area up to the handle position.
		Rectangle {
			x: root.borderWidth
			y: root.borderWidth
			topLeftRadius: Theme.geometry_slider_groove_radius - root.borderWidth
			bottomLeftRadius: Theme.geometry_slider_groove_radius - root.borderWidth
			topRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			bottomRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			width: root.sliderX + root.indicatorBackgroundWidth - root.borderWidth
			height: parent.height - (2 * root.borderWidth)
			color: root.highlightColor
		}
	}

	handle: SliderIndicator {
		x: root.sliderX - (width / 2) + (root.indicatorBackgroundWidth / 2)
		y: (root.height - height) / 2
		highlightVisible: Global.keyNavigationEnabled && root.activeFocus
		handle: root.handle
	}

	NumberAnimation {
		id: anim
		target: root
		property: "sliderX"
		duration: 0
		easing.type: Easing.InOutQuad
	}
 }
