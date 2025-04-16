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
			// If the width/height of the highlight is shorter than the corner size, then shrink the
			// border size to avoid cropping the corners of the image.
			left: Math.min(root.width / 2, Theme.geometry_focus_highlight_corner_size)
			right: Math.min(root.width / 2, Theme.geometry_focus_highlight_corner_size)
			top: Math.min(root.height / 2, Theme.geometry_focus_highlight_corner_size)
			bottom: Math.min(root.height / 2, Theme.geometry_focus_highlight_corner_size)
		}
	}
}
