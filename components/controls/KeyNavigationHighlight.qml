/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BorderImage {
	id: root

	property bool active

	z: 1000 // show highlight above all siblings
	visible: Global.keyNavigationEnabled && active && !Global.pageManager?.expandLayout
	// (do not set asynchronous: true as this affects the border margins)

	// If the width/height of the highlight is shorter than the corner size, then shrink the
	// border size to avoid cropping the corners of the image.
	readonly property int _horizontalBorders: Math.min(root.width * 0.5, Theme.geometry_focus_highlight_corner_size)
	readonly property int _verticalBorders: Math.min(root.height * 0.5, Theme.geometry_focus_highlight_corner_size)

	source: Theme.colorScheme === Theme.Light
			? "qrc:/images/key_navigation_highlight_light.svg"
			: "qrc:/images/key_navigation_highlight_dark.svg"
	border {
		left: root._horizontalBorders
		right: root._horizontalBorders
		top: root._verticalBorders
		bottom: root._verticalBorders
	}
}
