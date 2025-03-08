/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property bool active

	z: 1000 // show highlight above all siblings
	visible: active && (!Global.pageManager || !Global.pageManager.expandLayout)

	Rectangle {
		anchors.fill: parent
		color: Theme.color_focus_highlight
		opacity: 0.15
		radius: Theme.geometry_button_radius
	}

	CP.ColorImage {
		anchors {
			left: parent.left
			top: parent.top
		}
		source: "qrc:/images/key_navigation_top_left_corner.svg"
		color: Theme.color_focus_highlight
	}

	CP.ColorImage {
		anchors {
			right: parent.right
			top: parent.top
		}
		source: "qrc:/images/key_navigation_top_left_corner.svg"
		color: Theme.color_focus_highlight
		rotation: 90
	}

	CP.ColorImage {
		anchors {
			left: parent.left
			bottom: parent.bottom
		}
		source: "qrc:/images/key_navigation_top_left_corner.svg"
		color: Theme.color_focus_highlight
		rotation: -90
	}

	CP.ColorImage {
		anchors {
			right: parent.right
			bottom: parent.bottom
		}
		source: "qrc:/images/key_navigation_top_left_corner.svg"
		color: Theme.color_focus_highlight
		rotation: 180
	}
}
