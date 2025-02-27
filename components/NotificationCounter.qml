/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property int count: 0
	property color borderColor: "transparent"

	// fixed height, minimum width (height as circle)
	// but can extend its width to accomodate the text
	height: Theme.geometry_navigationBar_notification_counter_height
	width: Math.max(height, countText.width + 12)
	radius: Math.min(width, height) / 2
	color: Theme.color_critical
	border {
		color: root.borderColor
		width: 2
	}

	Text {
		id: countText
		anchors {
			centerIn: parent
			// just to apply a tiny fix for the font's baseline
			// without having to use TextMetrics
			verticalCenterOffset: 0.5
		}
		// always white over a red background
		color: Theme.color_white
		text: root.count
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_notification_counter
	}
}
