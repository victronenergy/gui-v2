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

	anchors {
		left: parent ? parent.left : undefined
		leftMargin: Theme.geometry_listItem_content_horizontalMargin
	}
	topPadding: Theme.geometry_settingsListHeader_topPadding
	bottomPadding: Theme.geometry_settingsListHeader_bottomPadding
	width: Math.max(implicitWidth, 1)
	font.pixelSize: Theme.font_size_body1
	wrapMode: Text.Wrap
	color: Theme.color_font_secondary
}
