/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginModelListViewTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The focus tests need that.
	visible: true
	width: 400
	height: 400

	function initTestCase() {
		// Unit tests do not load a mock configuration, so the access level is unset and
		// canAccess() is false, and every list item is hidden.
		MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel",
				VenusOS.User_AccessType_Service)
		tryVerify(function() {
			return !!Services.settings
					&& Services.settings.canAccess(VenusOS.User_AccessType_Service)
		}, 20000)
	}

	function init() {
		Global.keyNavigationEnabled = false
	}

	function cleanup() {
		Global.keyNavigationEnabled = false
	}

	Component {
		id: listHostComponent

		Item {
			property alias list: list
			property alias listModel: listModel

			width: 400
			height: 400

			ListModel {
				id: listModel

				ListElement { name: "first"; shown: true }
				ListElement { name: "second"; shown: true }
				ListElement { name: "third"; shown: true }
			}

			PluginModelListView {
				id: list

				model: listModel

				header: PluginPrimaryListLabel {
					objectName: "header"
					text: "Header"
				}

				delegate: PluginListText {
					required property string name
					required property bool shown

					objectName: name
					text: name
					preferredVisible: shown
				}
			}
		}
	}

	function childByName(item, objectName) {
		if (!item) {
			return null
		}
		if (item.objectName === objectName) {
			return item
		}
		for (let i = 0; i < item.children.length; ++i) {
			const found = childByName(item.children[i], objectName)
			if (found) {
				return found
			}
		}
		return null
	}

	function createList() {
		const host = createTemporaryObject(listHostComponent, root)
		verify(host)
		tryVerify(function() {
			return !!childByName(host, "first") && !!childByName(host, "third")
		})
		return host
	}

	// Focus the first list item. The list helper focuses the first list item that accepts key
	// navigation.
	function focusFirstListItem(host) {
		const first = childByName(host, "first")
		first.forceActiveFocus()
		tryCompare(first, "activeFocus", true)
	}

	function test_listItemsAreBelowTheHeader() {
		const host = createList()
		compare(host.list.count, 3)
		const header = childByName(host, "header")
		const first = childByName(host, "first")
		const second = childByName(host, "second")
		verify(header)
		verify(header.visible)
		verify(header.height > 0)
		verify(header.y + header.height <= first.y)
		verify(first.y + first.height <= second.y)
		// A list item takes the width of the list.
		compare(first.width, host.list.width)
	}

	function test_keyNavigationMovesThroughListItems() {
		Global.keyNavigationEnabled = true
		const host = createList()
		focusFirstListItem(host)
		keyClick(Qt.Key_Down)
		tryCompare(childByName(host, "second"), "activeFocus", true)
		keyClick(Qt.Key_Down)
		tryCompare(childByName(host, "third"), "activeFocus", true)
		keyClick(Qt.Key_Up)
		tryCompare(childByName(host, "second"), "activeFocus", true)
	}

	function test_keyNavigationSkipsHiddenListItems() {
		Global.keyNavigationEnabled = true
		const host = createList()
		host.listModel.setProperty(1, "shown", false)
		const second = childByName(host, "second")
		tryCompare(second, "visible", false)
		compare(second.height, 0)
		focusFirstListItem(host)
		keyClick(Qt.Key_Down)
		tryCompare(childByName(host, "third"), "activeFocus", true)
	}

	function test_hidingFocusedListItemMovesKeyFocus_data() {
		return [
			// No list item is before the first one, so focus moves to the next one.
			{ tag: "first list item", hide: 0, expect: "second" },
			{ tag: "second list item", hide: 1, expect: "first" },
		]
	}

	function test_hidingFocusedListItemMovesKeyFocus(data) {
		// Qt still delivers keys to a hidden item that has focus. Focus must move to a visible
		// list item.
		Global.keyNavigationEnabled = true
		const host = createList()
		focusFirstListItem(host)
		const hidden = childByName(host, host.listModel.get(data.hide).name)
		if (data.hide > 0) {
			keyClick(Qt.Key_Down)
			tryCompare(hidden, "activeFocus", true)
		}

		// Hiding the focused list item clears TabFocus while it still has focus. Qt warns.
		ignoreWarning(/Cannot set activeFocusOnTab to false once item is the active focus item/)
		host.listModel.setProperty(data.hide, "shown", false)
		tryCompare(hidden, "activeFocus", false)
		tryCompare(childByName(host, data.expect), "activeFocus", true)
	}

	function test_hidingOnlyVisibleListItemClearsItsFocus() {
		Global.keyNavigationEnabled = true
		const host = createList()
		host.listModel.remove(1, 2)
		focusFirstListItem(host)
		const first = childByName(host, "first")

		ignoreWarning(/Cannot set activeFocusOnTab to false once item is the active focus item/)
		host.listModel.setProperty(0, "shown", false)
		tryCompare(first, "activeFocus", false)
		verify(host.list.activeFocus)
	}

	function test_removingFocusedListItemMovesKeyFocus_data() {
		return [
			{ tag: "middle list item", remove: 1, expect: "third" },
			// No list item is after the last one, so focus moves to the one before it.
			{ tag: "last list item", remove: 2, expect: "second" },
			// The list view makes the hidden list item current, and focuses it.
			{ tag: "next list item is hidden", remove: 1, hide: 2, expect: "first" },
		]
	}

	function test_removingFocusedListItemMovesKeyFocus(data) {
		Global.keyNavigationEnabled = true
		const host = createList()
		if (data.hide !== undefined) {
			host.listModel.setProperty(data.hide, "shown", false)
		}
		focusFirstListItem(host)
		for (let i = 0; i < data.remove; ++i) {
			keyClick(Qt.Key_Down)
		}
		tryCompare(childByName(host, host.listModel.get(data.remove).name), "activeFocus", true)

		host.listModel.remove(data.remove)
		tryCompare(childByName(host, data.expect), "activeFocus", true)
		compare(host.list.count, 2)
	}
}
