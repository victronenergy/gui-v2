/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

 T.Slider {
	id: root

	property color highlightColor: root.enabled ? Theme.color_ok : Theme.color_switch_groove_disabled
	property bool animationEnabled: Global.animationEnabled
	property int state
	property alias leftPaddingComponent: leftPaddingItemLoader.sourceComponent
	property alias rightPaddingComponent: rightPaddingItemLoader.sourceComponent

	property int sliderX
	property int nextSliderX: root.leftPadding + root.visualPosition * (root.availableWidth - Theme.geometry_dimmingSlider_handle_width)

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

	implicitHeight: Theme.geometry_dimmingSlider_height
	leftPadding: Theme.geometry_dimmingSlider_handle_width/2

	background: Rectangle {
		width: parent.width
		height: parent.height
		radius: Theme.geometry_slider_groove_radius
		color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled

		Rectangle {
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			topRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0
			bottomRightRadius: width > root.width - Theme.geometry_slider_groove_radius ? Theme.geometry_slider_groove_radius - (root.width - width) : 0

			height: root.background.height
			width: root.sliderX + (Theme.geometry_dimmingSlider_handle_width)

			color: root.highlightColor
		}
		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.width: Theme.geometry_button_border_width
			border.color: root.enabled ? Theme.color_ok : Theme.color_gray4
			radius: Theme.geometry_button_radius
		}

		Loader {
			id: leftPaddingItemLoader
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: root.leftPadding - (Theme.geometry_dimmingSlider_handle_width / 2)
		}
		Loader {
			id: rightPaddingItemLoader
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: root.rightPadding
		}
	}

	handle: SliderIndicator {
		x: root.sliderX + (Theme.geometry_dimmingSlider_handle_width / 2 - Theme.geometry_dimmingSlider_indicator_width)
		anchors.verticalCenter: parent.verticalCenter
		highlightVisible: Global.keyNavigationEnabled && parent.parent.activeFocus
	}

	NumberAnimation {
		id: anim
		target: root
		property: "sliderX"
		duration: 0
		easing.type: Easing.InOutQuad
	}
 }

