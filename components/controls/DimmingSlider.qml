/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Slider {
	id: root

	signal clicked

	implicitHeight: Theme.geometry_dimmingSlider_height
	background.height: height

	handle: Rectangle {
		parent: root.maskSource
		width: Theme.geometry_switch_indicator_width
		height: root.background.height
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		color: root.highlightColor

		Column {
			anchors.centerIn: parent
			width: Theme.geometry_dimmingSlider_dot_size
			spacing: Theme.geometry_dimmingSlider_dot_size

			Dot { }
			Dot { }
			Dot { }
		}
	}

	component Dot: Rectangle {
		width: Theme.geometry_dimmingSlider_dot_size
		height: Theme.geometry_dimmingSlider_dot_size
		radius: Theme.geometry_dimmingSlider_dot_size / 2
		color: Theme.color_gray7
	}

	Rectangle {
		anchors.fill: parent
		color: "transparent"
		border.width: Theme.geometry_button_border_width
		border.color: Theme.color_ok
		radius: Theme.geometry_button_radius
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			root.clicked()
		}
		onPressed: (mouse) => {
			mouse.accepted = (mouseX < root.handle.x) || (mouseX > (root.handle.x + root.handle.width))
		}
	}
}
