/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
//import QtQuick.Templates as T
import Victron.VenusOS
import QtQuick.Effects as Effects

BaseSlider {
	id: root

	signal clicked

	// The Slider padding area is used to display the dimming slider state and provide
	// click handling for the control as well as the inherited slider behaviour.
	leftPadding: Math.ceil(textMetrics.tightBoundingRect.x + textMetrics.tightBoundingRect.width)
			+ (Theme.geometry_dimmingSlider_text_padding * 2) + Theme.geometry_dimmingSlider_handle_width

	leftPaddingComponent: Label {
		id: stateLabel
		anchors.fill: parent

		text: root.state === 1 ? CommonWords.on : CommonWords.off
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_body1
		color: root.enabled ? Theme.color_button_down_text : Theme.color_gray6

		Rectangle {
			anchors.right: stateLabel.right
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_dimmingSlider_separator_width
			height: parent.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
			radius: Theme.geometry_dimmingSlider_separator_width / 2
			color: root.enabled ? Theme.color_slider_separator : Theme.color_background_disabled
		}
	}

	TextMetrics {
		id: textMetrics
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_body1
		text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
	}

	MouseArea {
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: root.leftPadding - (Theme.geometry_dimmingSlider_handle_width / 2)
		onClicked: root.clicked()
	}
}
