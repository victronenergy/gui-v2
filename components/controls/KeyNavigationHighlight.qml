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
	property real margins

	z: 1000 // show highlight above all siblings
	visible: Global.keyNavigationEnabled && active && !Global.pageManager?.expandLayout

	Rectangle {
		anchors.fill: parent
		anchors.margins: root.margins
		color: Theme.color_focus_highlight
		opacity: 0.15
		radius: Theme.geometry_button_radius
	}

	BorderImage {
		anchors.fill: parent
		anchors.margins: root.margins
		source: Theme.colorScheme === Theme.Light
				? "qrc:/images/key_navigation_highlight_light.svg"
				: "qrc:/images/key_navigation_highlight_dark.svg"
		border {
			left: Theme.geometry_focus_highlight_corner_size
			right: Theme.geometry_focus_highlight_corner_size
			top: Theme.geometry_focus_highlight_corner_size
			bottom: Theme.geometry_focus_highlight_corner_size
		}
	}
}
