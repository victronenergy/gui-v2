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

	name: "ListSwitchTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The focus test needs that.
	visible: true
	width: 400
	height: 400

	function initTestCase() {
		// Unit tests do not load a mock configuration, so the access level is unset and
		// canAccess() is false. Service allows every show and write level these rows use.
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

	function test_checkableClickTogglesOnce_data() {
		return [
			{ tag: "ListSwitch", component: listSwitchComponent },
			{ tag: "PluginListSwitch", component: pluginListSwitchComponent },
		]
	}

	function test_checkableClickTogglesOnce(data) {
		const row = createTemporaryObject(data.component, root, { checkable: true, text: "Switch" })
		const switchItem = childByName(row, "switchItem")
		verify(switchItem !== null)
		verify(switchItem.enabled)
		compare(switchItem.checkable, false)
		compare(row.checked, false)

		// click() is the Space key path. The Switch's clicked() is the touch path.
		// Each must change checked once. A second toggle in the same call would leave it unchanged.
		row.click()
		compare(row.checked, true)
		switchItem.clicked()
		compare(row.checked, false)
	}

	function test_hidingFocusedSwitchMovesKeyFocus_data() {
		return [
			{ tag: "next row", hide: "first", expect: "second" },
			{ tag: "previous row", hide: "second", expect: "first" },
		]
	}

	function test_hidingFocusedSwitchMovesKeyFocus(data) {
		// Hiding a focused row does not clear active focus, and Qt still delivers keys to it.
		// Space would toggle the hidden switch. Focus must move to a visible row first.
		Global.keyNavigationEnabled = true
		const host = createTemporaryObject(listHostComponent, root)
		verify(host)
		const hidden = data.hide === "first" ? host.first : host.second
		const shown = data.expect === "first" ? host.first : host.second
		tryVerify(function() { return host.first.visible && host.second.visible })
		// Focus through the list helper. forceActiveFocus() on a later row is undone,
		// because the helper's index is still the first row.
		host.first.forceActiveFocus()
		tryCompare(host.first, "activeFocus", true)
		if (hidden !== host.first) {
			keyClick(Qt.Key_Down)
			tryCompare(hidden, "activeFocus", true)
		}

		// Hiding the focused row clears TabFocus while it still has focus. Qt warns.
		ignoreWarning(/Cannot set activeFocusOnTab to false once item is the active focus item/)
		hidden.preferredVisible = false
		tryCompare(hidden, "activeFocus", false)
		tryCompare(shown, "activeFocus", true)

		keyClick(Qt.Key_Space)
		compare(hidden.checked, false)
		compare(shown.checked, true)
	}

	Component {
		id: listHostComponent

		Item {
			width: 400
			height: 400

			property alias first: firstSwitch
			property alias second: secondSwitch

			PluginGradientListView {

				PluginListSwitch {
					id: firstSwitch
					objectName: "first"
					checkable: true
					text: "First"
				}
				PluginListSwitch {
					id: secondSwitch
					objectName: "second"
					checkable: true
					text: "Second"
				}
			}
		}
	}

	Component {
		id: listSwitchComponent

		ListSwitch {}
	}

	Component {
		id: pluginListSwitchComponent

		PluginListSwitch {}
	}
}
