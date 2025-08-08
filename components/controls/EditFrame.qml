/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	property real arrowMargin: Theme.geometry_focus_highlight_border_size

	color: "transparent"
	border.color: Theme.color_focus_highlight
	border.width: Theme.geometry_focus_highlight_border_size
	radius: Theme.geometry_button_radius

	CP.ColorImage {
		anchors {
			top: parent.top
			topMargin: -height - root.arrowMargin
			horizontalCenter: parent.horizontalCenter
		}
		source: "qrc:/images/spinbox_arrow_up.svg"
		color: Theme.color_focus_highlight
	}

	CP.ColorImage {
		anchors {
			bottom: parent.bottom
			bottomMargin: -height - root.arrowMargin
			horizontalCenter: parent.horizontalCenter
		}
		source: "qrc:/images/spinbox_arrow_up.svg"
		color: Theme.color_focus_highlight
		rotation: 180
	}
}
