/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS

/*
	A scrolling list of items, which fills its parent.

	Declare the items as direct children of it, for example:

		PluginGradientListView {
			PluginListSwitch { text: "Enabled" }
			PluginListNavigation { text: "Advanced"; pageUrl: Qt.resolvedUrl("AdvancedPage.qml") }
		}

	The items are fixed when the list is created. To hide an item, set its preferredVisible to false:
	the item then takes no space, and key navigation skips it. If that item already has key focus,
	focus moves to a visible item. Hiding it does not clear focus, and Qt still delivers keys to
	an item that has focus. Do not set 'visible' on an item.
*/
FocusScope {
	id: root

	// The list items, in order. Each one is a Plugin* list item, such as PluginListSwitch.
	default property list<PluginListItem> items

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	focus: true

	GradientListView {
		id: listView

		model: ObjectModel {
			id: rowModel
		}
	}

	// Nested, so this is not part of the plugin API. A function on the list would be.
	QtObject {
		id: hiddenRowFocus

		function watch(row) {
			// The parameter, not the loop variable: every connection must see its own list item.
			row.effectiveVisibleChanged.connect(function() {
				if (row.effectiveVisible || !row.activeFocus) {
					return
				}
				Qt.callLater(function() { move(row) })
			})
		}

		function move(row) {
			if (row.effectiveVisible || !row.activeFocus) {
				return
			}
			// focusPolicy follows effectiveVisible, so this runs after that binding updates.
			// Otherwise the helper still accepts this list item and puts focus back on it.
			listView.__keyNavHelper.updateFocusedItem()
			if (!row.activeFocus) {
				return
			}
			const next = nextVisibleRow(row)
			if (next) {
				for (let i = 0; i < root.items.length; ++i) {
					if (root.items[i] === next) {
						listView.currentIndex = i
						break
					}
				}
				next.forceActiveFocus()
			}
			if (row.activeFocus) {
				row.focus = false
			}
		}

		function nextVisibleRow(row) {
			const items = root.items
			let index = -1
			for (let i = 0; i < items.length; ++i) {
				if (items[i] === row) {
					index = i
					break
				}
			}
			for (let i = index + 1; i < items.length; ++i) {
				if (canFocus(items[i])) {
					return items[i]
				}
			}
			for (let i = index - 1; i >= 0; --i) {
				if (canFocus(items[i])) {
					return items[i]
				}
			}
			return null
		}

		function canFocus(row) {
			// Same test as Utils.acceptsKeyNavigation(): TabFocus, and enabled.
			return row.effectiveVisible && row.enabled && (row.focusPolicy & Qt.TabFocus)
		}
	}

	Component.onCompleted: {
		// Fill the model once, when every list item exists. The model is not bound to 'items', as the
		// items are fixed when the list is created.
		for (let i = 0; i < root.items.length; ++i) {
			const row = root.items[i]
			rowModel.append(row)
			hiddenRowFocus.watch(row)
		}
	}
}
