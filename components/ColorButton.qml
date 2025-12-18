/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property color centerColor

	signal clicked

	border {
		width: Theme.geometry_button_border_width
		color: Theme.color_ok
	}
	implicitWidth: Theme.geometry_switchableoutput_control_height
	implicitHeight: Theme.geometry_switchableoutput_control_height
	radius: Theme.geometry_colorWheelDialog_preset_button_radius
	color: "transparent"

	Rectangle {
		anchors {
			fill: parent
			margins: 2 * Theme.geometry_button_border_width
		}
		radius: root.radius - Theme.geometry_button_border_width
		visible: root.centerColor.valid
		color: root.centerColor
	}

	PressArea {
		id: presetPressArea
		anchors.fill: parent
		radius: Theme.geometry_button_radius
		onClicked: root.clicked()
	}
}
