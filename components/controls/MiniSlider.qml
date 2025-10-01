/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

T.Slider {
	id: root

	property color highlightColor: enabled ? Theme.color_ok : Theme.color_button_on_background_disabled
	property color backgroundColor: enabled ? Theme.color_darkOk : Theme.color_background_disabled
	property color borderColor: enabled ? Theme.color_ok : Theme.color_font_disabled
	property int borderWidth: Theme.geometry_button_border_width
	property bool animationEnabled: visible && Global.animationEnabled

	// This is the standard indicator width, plus left/right padding on either side.
	property real indicatorBackgroundWidth: (Theme.geometry_slider_indicator_width * 3)

	property real sliderX
	property real nextSliderX: leftPadding
		+ borderWidth
		+ (root.visualPosition * (root.availableWidth - indicatorBackgroundWidth - 2*borderWidth))

	property bool _completed

	Component.onCompleted: {
		_completed = true
	}

	onNextSliderXChanged: {
		// Don't animate the value change if it was changed by the user (i.e. pressed=true), else it
		// looks laggy. Also don't animate when setting the initial binding (before completed=true).
		if (!root.animationEnabled || pressed || !_completed) {
			sliderX = nextSliderX
		} else {
			anim.stop()
			anim.from = sliderX
			anim.to = nextSliderX
			anim.duration = Theme.animation_slider_valueChange_duration
			anim.start()
		}
	}

	implicitHeight: Theme.geometry_switchableoutput_control_height
	background: Rectangle {
		radius: Theme.geometry_slider_groove_radius
		color: root.backgroundColor

		// Inner rectangle that fills the slider area up until the handle position, to display the
		// progress value.
		Rectangle {
			anchors {
				top: parent.top
				bottom: parent.bottom
			}
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			topRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			bottomRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			width: Math.round(root.sliderX + root.indicatorBackgroundWidth) // round to avoid sub-pixel artifacts
			color: root.highlightColor
		}

		// Border around the whole control
		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.color: root.borderColor
			border.width: root.borderWidth
			radius: Theme.geometry_slider_groove_radius
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
