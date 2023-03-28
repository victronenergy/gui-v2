/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListView {
	id: root

	x: Theme.geometry.page.content.horizontalMargin
	width: parent.width - Theme.geometry.page.content.horizontalMargin
	height: parent.height
	topMargin: Theme.geometry.gradientList.topMargin
	bottomMargin: Theme.geometry.gradientList.bottomMargin
	rightMargin: Theme.geometry.page.content.horizontalMargin

	// Note: do not set spacing here, as it creates extra spacing if an item has visible=false.
	// Instead, the spacing is added visually within ListItem's ListItemBackground.

	ViewGradient {
		anchors {
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry.gradientList.topMargin
		bottomPadding: Theme.geometry.gradientList.bottomMargin
	}
}
