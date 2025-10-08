/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Button for switching between the RGB colour wheel and Temperature colour wheel.
*/
Rectangle {
	id: root

	property int outputType

	signal rgbClicked()
	signal cctClicked()

	implicitWidth: Theme.geometry_colorWheelDialog_mode_button_width
	implicitHeight: Theme.geometry_colorWheelDialog_mode_button_height
	radius: Theme.geometry_colorWheelDialog_mode_button_radius
	color: Theme.color_colorWheelDialog_mode_button_background

	// Circular border around the selected icon.
	Rectangle {
		anchors.centerIn: tempColorIcon.containsPress
				|| (root.outputType === VenusOS.SwitchableOutput_Type_ColorDimmerCct && !rgbColorIcon.containsPress)
			? tempColorIcon : rgbColorIcon
		width: height
		height: rgbColorIcon.width + ((parent.height - rgbColorIcon.height) / 2)
		color: "transparent"
		radius: width / 2
		border.color: Theme.color_ok
		border.width: Theme.geometry_button_border_width
	}

	IconButton {
		id: rgbColorIcon
		anchors.verticalCenter: parent.verticalCenter
		x: y
		radius: Theme.geometry_colorWheelDialog_mode_button_radius
		icon.source: "qrc:/images/color_wheel_rgb.png"
		onClicked: root.rgbClicked()
	}

	IconButton {
		id: tempColorIcon
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: 8
		}
		icon.source: "qrc:/images/color_wheel_temperature.png"
		onClicked: root.cctClicked()
	}

	// Vertical separator in the middle of the button.
	Rectangle {
		anchors.centerIn: parent
		width: Theme.geometry_button_border_width
		height: tempColorIcon.height
		color: Theme.color_colorWheelDialog_mode_button_separator
	}
}
