/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Button for switching between the RGB colour wheel and Temperature colour wheel.
*/
PressArea {
	implicitWidth: Theme.color_colorWheelDialog_colorWheelToggle_width
	implicitHeight: Theme.color_colorWheelDialog_colorWheelToggle_height
	radius: Theme.color_colorWheelDialog_colorWheelToggle_radius

	Rectangle {
		anchors.fill: parent
		radius: Theme.color_colorWheelDialog_colorWheelToggle_radius
		color: "transparent"
		border.width: Theme.geometry_button_border_width
		border.color: Theme.color_colorWheelDialog_button_border
	}

	// Circular border around the RGB color icon.
	Rectangle {
		anchors.centerIn: rgbColorIcon
		width: height
		height: rgbColorIcon.width + ((parent.height - rgbColorIcon.height) / 2)
		color: "transparent"
		radius: width / 2
		border.color: Theme.color_colorWheelDialog_button_rgb_border
		border.width: Theme.geometry_button_border_width
	}

	Image {
		id: rgbColorIcon
		anchors.verticalCenter: parent.verticalCenter
		x: y
		source: "qrc:/images/color_wheel_rgb.png"
	}

	Image {
		id: tempColorIcon
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: 8
		}
		source: "qrc:/images/color_wheel_temp.png"
	}

	// Vertical separator in the middle of the button.
	Rectangle {
		anchors.centerIn: parent
		width: Theme.geometry_button_border_width
		height: tempColorIcon.height
		color: Theme.color_button_icon
	}
}
