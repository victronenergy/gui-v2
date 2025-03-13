/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	id: root

	property int count: 0

	height: Theme.geometry_navigationBar_notification_counter_height
	width: count > 9 ? Theme.geometry_navigationBar_notification_counter_width_two_digits
					 : Theme.geometry_navigationBar_notification_counter_width_one_digit
	color: Theme.color_white
	text: count
	topPadding: 1 // fix for font baseline
	verticalAlignment: Text.AlignVCenter
	horizontalAlignment: Text.AlignHCenter
	font.pixelSize: Theme.font_size_body1

	background: Rectangle {
		color: Theme.color_critical
		radius: Math.min(width, height) / 2
	}
}
