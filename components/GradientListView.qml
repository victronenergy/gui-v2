/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

ListView {
	id: root

	width: parent.width
	height: parent.height
	bottomMargin: Theme.geometry_gradientList_bottomMargin
	leftMargin: Theme.geometry_page_content_horizontalMargin
	rightMargin: Theme.geometry_page_content_horizontalMargin
	boundsBehavior: Flickable.StopAtBounds

	// Note: do not set spacing here, as it creates extra spacing if an item has visible=false.
	// Instead, the spacing is added visually within ListItem's ListItemBackground.

	ViewGradient {
		anchors.bottom: root.bottom
	}

	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_gradientList_topMargin
		bottomPadding: Theme.geometry_gradientList_bottomMargin
	}
}
