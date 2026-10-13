/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	// These mimic the same properties from ListItem, so that the item can be
	// marked as hidden by VisibleItemModel.
	readonly property bool effectiveVisible: preferredVisible
	property bool preferredVisible: true

	leftPadding: Theme.geometry_page_content_horizontalMargin + Theme.geometry_shared_24_24_12
	rightPadding: Theme.geometry_page_content_horizontalMargin + Theme.geometry_shared_24_24_12
	topPadding: Theme.geometry_size_8
	bottomPadding: Theme.geometry_size_2 + Theme.geometry_size_4
	width: Math.max(implicitWidth, 1)
	font.pixelSize: Theme.font_listItem_flat_primary_size_flat
	wrapMode: Text.Wrap
	color: Theme.color_font_secondary
}
