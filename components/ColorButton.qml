/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	property color centerColor

	defaultBackgroundWidth: Theme.geometry_switchableoutput_control_height
	defaultBackgroundHeight: Theme.geometry_switchableoutput_control_height
	backgroundColor: "transparent"
	radius: Theme.geometry_colorWheelDialog_preset_button_radius
	flat: false

	Rectangle {
		anchors {
			fill: parent
			leftMargin: (2 * Theme.geometry_button_border_width) + root.leftInset
			rightMargin: (2 * Theme.geometry_button_border_width) + root.rightInset
			topMargin: (2 * Theme.geometry_button_border_width) + root.topInset
			bottomMargin: (2 * Theme.geometry_button_border_width) + root.bottomInset
		}
		radius: root.radius - (2 * Theme.geometry_button_border_width)
		visible: root.centerColor.valid
		color: root.centerColor
	}
}
