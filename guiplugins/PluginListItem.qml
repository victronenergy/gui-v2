/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The base type of every Plugin* list item, such as PluginListSwitch and PluginListSetting. Only
	list items of this type can be declared in a PluginItemListView, or be the delegate of a
	PluginModelListView.

	It holds what every list item does in the same way: whether the list item is shown, and key
	navigation. Do not use it directly. For a list item that the other Plugin* types do not cover,
	use PluginListSetting.
*/
FocusScope {
	// Set to false to hide the list item. It then takes no space, and key navigation skips it.
	// Do not set 'visible'. Hiding a list item that already has key focus does not clear that
	// focus; the list view moves it to a visible list item.
	property bool preferredVisible: true
	// The lowest access level that shows the list item.
	property int showAccessLevel: PluginAccessLevel.User
	// True when the list item is shown: preferredVisible is true, and the user has showAccessLevel.
	// Services.settings is loaded asynchronously. Calling canAccess on a missing object throws
	// and breaks this binding, so the list item would stay hidden after settings arrive.
	readonly property bool effectiveVisible: preferredVisible
			&& (Services.settings?.canAccess(showAccessLevel) ?? false)

	width: parent?.width ?? implicitWidth
	visible: effectiveVisible
	focusPolicy: effectiveVisible ? Qt.TabFocus : Qt.NoFocus
	// A plugin handles keys on this list item, for example Keys.onSpacePressed, and cannot import
	// Victron.VenusOS to guard them. The inner item's guard does not cover handlers attached
	// here. A hidden list item can still have active focus, and Qt delivers keys to that focus,
	// so these handlers also require the list item to be shown.
	Keys.enabled: effectiveVisible && Global.keyNavigationEnabled
}
