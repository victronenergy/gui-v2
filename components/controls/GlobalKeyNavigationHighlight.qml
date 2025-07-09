/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BorderImage {
	id: root

	anchors {
		fill: parent
		// we don't need to use helper.margins here
		// since the other specific margins automatically align with margins
		// if not explicitly set
		leftMargin: helper.leftMargin
		rightMargin: helper.rightMargin
		topMargin: helper.topMargin
		bottomMargin: helper.bottomMargin
	}
	border {
		left: helper.horizontalBorders
		right: helper.horizontalBorders
		top: helper.verticalBorders
		bottom: helper.verticalBorders
	}
	source: Theme.colorScheme === Theme.Light
			? "qrc:/images/key_navigation_highlight_light.svg"
			: "qrc:/images/key_navigation_highlight_dark.svg"

	visible: helper.showHighlight

	z: 1000 // show highlight above all siblings

	// (do not set asynchronous: true as this affects the border margins)

	KeyNavigationHighlightHelper {
		id: helper

		// Whether the highlight should be visible. No need to bind to activeFocusItem.visible
		// since we will "inherit" visible from the parent.
		readonly property bool showHighlight: Global.keyNavigationEnabled
				&& !Global.pageManager?.expandLayout
				&& active

		// KeyNavigationHighlightHelper isn't a QQuickItem so we have to
		// get the Window.activeFocusItem from the root instead.
		activeFocusItem: root.Window.activeFocusItem

		// If the width/height of the highlight is shorter than the corner size, then shrink the
		// border size to avoid cropping the corners of the image.
		horizontalBorders: Math.min(root.width * 0.5, Theme.geometry_focus_highlight_corner_size)
		verticalBorders: Math.min(root.height * 0.5, Theme.geometry_focus_highlight_corner_size)
	}

	// Automatic reparenting of this object into the activeFocusItem (or specified fill item)
	Binding {
		root.parent: helper.fill
		when: helper.fill && helper.showHighlight
	}
}
