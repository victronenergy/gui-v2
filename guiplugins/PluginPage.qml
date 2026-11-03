/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The base type of a plugin page.

	The app shows it inside a page of its own, which provides the status bar title (from 'title'),
	the back button, and the page size. Put a PluginItemListView or a PluginModelListView inside it
	to show a list of list items, or a PluginCardListView to show cards.
*/
FocusScope {
	// The page title, shown in the status bar.
	property string title

	// The page stack reads this to recognise a plugin page. It is not part of the plugin API.
	readonly property bool __is_plugin_page__: true

	focus: true

	// A direct list or card sets focusPolicy when it can take key navigation.
	// Items in a layout are not reached, so they do not count.
	focusPolicy: {
		const kids = children
		for (let i = 0; i < kids.length; ++i) {
			const child = kids[i]
			if (child.enabled && child.visible && (child.focusPolicy & Qt.TabFocus)) {
				return Qt.TabFocus
			}
		}
		return Qt.NoFocus
	}
}
