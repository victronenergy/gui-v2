/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS

/*
	A scrolling list of the items declared inside it, which fills its parent. For a list with one
	item for each entry in a model, use PluginModelListView.

	Declare the items as direct children of it, for example:

		PluginItemListView {
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
			id: itemModel
		}
	}

	// Nested, so this is not part of the plugin API. A function on the list would be.
	QtObject {
		id: hiddenItemFocus

		function watch(item) {
			// The parameter, not the loop variable: every connection must see its own list item.
			item.effectiveVisibleChanged.connect(function() {
				if (item.effectiveVisible || !item.activeFocus) {
					return
				}
				Qt.callLater(function() { move(item) })
			})
		}

		function move(item) {
			if (item.effectiveVisible || !item.activeFocus) {
				return
			}
			// focusPolicy follows effectiveVisible, so this runs after that binding updates.
			// Otherwise the helper still accepts this list item and puts focus back on it.
			listView.__keyNavHelper.updateFocusedItem()
			if (!item.activeFocus) {
				return
			}
			const next = nextVisibleItem(item)
			if (next) {
				for (let i = 0; i < root.items.length; ++i) {
					if (root.items[i] === next) {
						listView.currentIndex = i
						break
					}
				}
				next.forceActiveFocus()
			}
			if (item.activeFocus) {
				item.focus = false
			}
		}

		function nextVisibleItem(item) {
			const items = root.items
			let index = -1
			for (let i = 0; i < items.length; ++i) {
				if (items[i] === item) {
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

		function canFocus(item) {
			// Same test as Utils.acceptsKeyNavigation(): TabFocus, and enabled.
			return item.effectiveVisible && item.enabled && (item.focusPolicy & Qt.TabFocus)
		}
	}

	Component.onCompleted: {
		// Fill the model once, when every list item exists. The model is not bound to 'items', as the
		// items are fixed when the list is created.
		for (let i = 0; i < root.items.length; ++i) {
			const item = root.items[i]
			itemModel.append(item)
			hiddenItemFocus.watch(item)
		}
	}
}
