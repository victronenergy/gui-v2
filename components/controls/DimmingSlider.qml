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
		id: handleItem
		parent: root.maskSource
		width: Theme.geometry_switch_indicator_width
		height: root.background.height
		x: root.visible ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : 0
		color: root.highlightColor

		Column {
			anchors.centerIn: parent
			width: Theme.geometry_dimmingSlider_dot_size
			spacing: Theme.geometry_dimmingSlider_dot_size
			opacity: handleHighlight.visible ? 0.3 : 1

			Dot { }
			Dot { }
			Dot { }
		}
	}

	// Declare this highlight outside the handle, else it is not shown due to the handle's mask source.
	SliderHandleHighlight {
		id: handleHighlight
		x: root.handle.x + root.handle.width - (width / 2)
		y: (parent.height / 2) - (height / 2)
		width: root.handle.height - (2 * Theme.geometry_switch_groove_border_width)
		height: Theme.geometry_switch_groove_border_width
		visible: Global.keyNavigationEnabled && root.activeFocus
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
