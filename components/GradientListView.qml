/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListView {
	id: root

	bottomMargin: Theme.geometry_gradientList_bottomMargin
	leftMargin: Theme.geometry_page_content_horizontalMargin
	rightMargin: Theme.geometry_page_content_horizontalMargin
	spacing: Theme.geometry_gradientList_spacing

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_gradientList_topMargin
		bottomPadding: Theme.geometry_gradientList_bottomMargin
	}

	ViewGradient {
		anchors.bottom: root.bottom
	}
}
