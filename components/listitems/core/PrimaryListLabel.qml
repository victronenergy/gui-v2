/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Label {
	// These mimic the same properties from ListItem, so that the item can be
	// marked as hidden by VisibleItemModel.
	readonly property bool effectiveVisible: preferredVisible
	property bool preferredVisible: true

	width: parent ? parent.width : 0
	height: preferredVisible ? implicitHeight : 0
	visible: preferredVisible
	topPadding: preferredVisible ? Theme.geometry_listItem_content_verticalMargin : 0
	bottomPadding: preferredVisible ? Theme.geometry_listItem_content_verticalMargin : 0
	leftPadding: Theme.geometry_listItem_content_horizontalMargin
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
	font.pixelSize: Theme.font_size_body1
	wrapMode: Text.Wrap
}
