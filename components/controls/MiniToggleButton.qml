/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	property color separatorColor: enabled ? Theme.color_slider_separator : Theme.color_font_disabled
	property bool separatorVisible: true

	defaultBackgroundWidth: Math.ceil(labelTextMetrics.tightBoundingRect.x + labelTextMetrics.tightBoundingRect.width)
			+ (2 * Theme.geometry_miniSlider_text_padding)
	text: root.checked ? CommonWords.on : CommonWords.off
	color: enabled
		? Theme.color_button_down_text
		: (checked ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)

	TextMetrics {
		id: labelTextMetrics
		font.pixelSize: Theme.font_size_body1
		text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
	}

	Rectangle {
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		width: Theme.geometry_miniSlider_separator_width
		height: parent.defaultBackgroundHeight - (Theme.geometry_miniSlider_decorator_vertical_padding * 2)
		radius: Theme.geometry_miniSlider_separator_width / 2
		color: root.separatorColor
		visible: root.separatorVisible
	}
}
