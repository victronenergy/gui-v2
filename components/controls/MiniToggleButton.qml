/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

PressArea {
	id: root

	property bool checked

	implicitWidth: Math.ceil(labelTextMetrics.tightBoundingRect.x + labelTextMetrics.tightBoundingRect.width)
			+ (2 * Theme.geometry_dimmingSlider_text_padding)
	implicitHeight: Theme.geometry_switchableoutput_button_height
	radius: Theme.geometry_button_radius

	Label {
		anchors.centerIn: parent
		color: enabled ? Theme.color_button_down_text : Theme.color_font_disabled
		text: root.checked ? CommonWords.on : CommonWords.off
	}

	TextMetrics {
		id: labelTextMetrics
		font.pixelSize: Theme.font_size_body1
		text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
	}
}
