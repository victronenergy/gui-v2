/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The base type of every Plugin* row, such as PluginListSwitch and PluginListItem. Only rows of
	this type can be declared in a PluginGradientListView.

	It holds what every row does in the same way: whether the row is shown, and key navigation.
	Do not use it directly. For a row that the other Plugin* types do not cover, use
	PluginListItem.
*/
FocusScope {
	// Set to false to hide the row. The row then takes no space, and key navigation skips it.
	// Do not set 'visible'. Hiding a row that already has key focus does not clear that
	// focus; PluginGradientListView moves it to a visible row.
	property bool preferredVisible: true
	// The lowest access level that shows the row.
	property int showAccessLevel: PluginAccessLevel.User
	// True when the row is shown: preferredVisible is true, and the user has showAccessLevel.
	// Services.settings is loaded asynchronously. Calling canAccess on a missing object throws
	// and breaks this binding, so the row would stay hidden after settings arrive.
	readonly property bool effectiveVisible: preferredVisible
			&& (Services.settings?.canAccess(showAccessLevel) ?? false)

	width: parent?.width ?? implicitWidth
	visible: effectiveVisible
	focusPolicy: effectiveVisible ? Qt.TabFocus : Qt.NoFocus
	// A plugin handles keys on this row, for example Keys.onSpacePressed, and cannot import
	// Victron.VenusOS to guard them. The inner row's guard does not cover handlers attached
	// here. A hidden row can still have active focus, and Qt delivers keys to that focus,
	// so these handlers also require the row to be shown.
	Keys.enabled: effectiveVisible && Global.keyNavigationEnabled
}
