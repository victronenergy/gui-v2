/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A convenience base type for focusable list items, with a background rectangle and key navigation
	support.

	Set preferredVisible=false if it should be hidden (e.g. if it would display invalid data).
*/
FocusScope {
	property bool preferredVisible: true

	// True if the item should be made visible. This is used by VisibleItemModel to filter out
	// non-valid items. (It must filter by 'effectiveVisible' instead of `visible', as the latter is
	// affected by the parent's visible value, causing the item to be unnecessarily filtered in and
	// out of a VisibleItemModel whenever a parent page is shown/hidden.)
	property bool effectiveVisible: preferredVisible

	property alias background: backgroundRect
	property alias navigationHighlight: keyNavigationHighlight

	// Allow item to receive focus within its focus scope.
	focus: true

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	// TODO from Qt 6.7 can change this to set focusPolicy instead.
	activeFocusOnTab: true

	ListItemBackground {
		id: backgroundRect
		anchors.fill: parent
		z: -2 // allow PressArea highlight to be seen
	}

	KeyNavigationHighlight {
		id: keyNavigationHighlight
		anchors.fill: parent
		active: parent.activeFocus
	}
}
