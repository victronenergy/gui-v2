/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A scrolling list with one list item for each entry in a model, which fills its parent. For a
	list of items that are declared inside it, use PluginItemListView.

	Set model to a list model, such as a PluginDeviceModel, and delegate to a Plugin* list item,
	for example:

		PluginModelListView {
			model: PluginDeviceModel { serviceTypes: ["tank"] }
			delegate: PluginListText {
				required property string name
				text: name
			}
		}

	header is an optional item above the list items, such as a PluginPrimaryListLabel. It scrolls
	with the list items. Keep it shorter than the list.

	Key navigation moves through the list items, and skips hidden ones. If the list item with key
	focus is hidden, or its entry is removed from the model, focus moves to a visible list item.
*/
FocusScope {
	id: root

	// The list model, such as a PluginDeviceModel or a PluginDataPathModel.
	property var model
	// The list item for each entry in the model. It must be a Plugin* list item.
	property Component delegate
	// An item above the list items. Optional.
	property Component header
	readonly property int count: listView.count

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	focus: true

	GradientListView {
		id: listView

		model: root.model
		delegate: root.delegate
		header: root.header

		// The current item changes when the entry of the focused list item is removed.
		onCurrentItemChanged: Qt.callLater(itemFocus.keepOnVisibleItem)
	}

	Connections {
		target: listView.currentItem
		ignoreUnknownSignals: true

		function onEffectiveVisibleChanged() {
			Qt.callLater(itemFocus.keepOnVisibleItem)
		}
	}

	// Nested, so this is not part of the plugin API. A function on the list would be.
	QtObject {
		id: itemFocus

		// Called later, so that a hidden list item's focusPolicy has been updated. Otherwise the
		// helper still accepts that list item and puts focus back on it.
		function keepOnVisibleItem() {
			if (!Global.keyNavigationEnabled || !listView.activeFocus || listView.headerItem?.activeFocus) {
				return
			}
			// The current item is the list item that key navigation focused.
			const item = listView.currentItem
			const itemIsHidden = item?.effectiveVisible === false
			if (item?.activeFocus && !itemIsHidden) {
				return
			}
			// The focused list item is hidden, or its entry was removed from the model.
			listView.__keyNavHelper.updateFocusedItem()
			if (itemIsHidden && item.activeFocus) {
				// No other list item can take focus. Qt still delivers keys to a hidden item that
				// has focus.
				item.focus = false
			}
		}
	}
}
