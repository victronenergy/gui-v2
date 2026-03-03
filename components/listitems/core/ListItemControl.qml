/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A convenience base type for focusable list items, with a background rectangle and key navigation
	support.
*/
AbstractListItem {
	id: root

	readonly property real horizontalContentPadding: flat
			? Theme.geometry_listItem_flat_content_horizontalMargin
			: Theme.geometry_listItem_content_horizontalMargin

	// The default format for text in the item. Defaults to AutoText, same as for QtQuick Text.
	property int textFormat: Text.AutoText

	// If true, the default background is hidden.
	property bool flat

	// True if this item leads to a sub-page when clicked.
	property bool hasSubMenu

	leftPadding: horizontalContentPadding
	rightPadding: horizontalContentPadding
	topPadding: Theme.geometry_listItem_content_verticalMargin
	bottomPadding: Theme.geometry_listItem_content_verticalMargin
	implicitWidth: parent?.width ?? Theme.geometry_listItem_width
	implicitHeight: effectiveVisible ? Math.max(
			implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding) : 0
	spacing: Theme.geometry_listItem_content_spacing

	// By default, the item is visible if preferredVisible=true.
	effectiveVisible: preferredVisible
	visible: effectiveVisible

	// Allow item to receive focus within its focus scope.
	focus: true

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	focusPolicy: effectiveVisible ? Qt.TabFocus : Qt.NoFocus

	// Set the default font for control text.
	font.pixelSize: flat ? Theme.font_listItem_flat_primary_size_flat : Theme.font_listItem_primary_size
	font.family: Global.fontFamily

	// Provide key navigation between list items.
	KeyNavigationHighlight.active: root.activeFocus
	Keys.enabled: Global.keyNavigationEnabled

	background: ListItemBackground {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: Theme.geometry_listItem_height
		visible: !root.flat
	}
}
