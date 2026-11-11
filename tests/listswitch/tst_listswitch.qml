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

	readonly property string sliderUid: "mock/com.victronenergy.test.listslider/Speed"
	property real sliderHostValue

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

			PluginItemListView {

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

	function childText(item, text) {
		if (!item) {
			return null
		}
		// The row itself has a text property. Only the visible Text shows it.
		if (item instanceof Text && item.text === text) {
			return item
		}
		for (let i = 0; i < item.children.length; ++i) {
			const found = childText(item.children[i], text)
			if (found) {
				return found
			}
		}
		return null
	}

	function test_captionStaysBelowTextAndGrowsTheRow_data() {
		return [
			{ tag: "button", component: pluginButtonComponent, clickable: true },
			{ tag: "navigation", component: pluginNavigationComponent, clickable: true },
			{ tag: "quantity", component: pluginQuantityComponent, clickable: false },
			{ tag: "radio", component: pluginRadioComponent, clickable: false },
			// A click opens a dialog. The caption test only needs the row itself.
			{ tag: "spinbox", component: pluginSpinBoxComponent, clickable: false },
			{ tag: "switch", component: pluginListSwitchComponent, clickable: true },
			{ tag: "temperature", component: pluginTemperatureComponent, clickable: false },
			{ tag: "text", component: pluginTextComponent, clickable: false },
			{ tag: "textfield", component: pluginTextFieldComponent, clickable: false },
		]
	}

	function test_captionStaysBelowTextAndGrowsTheRow(data) {
		const caption = "Caption under the label"
		const plain = createTemporaryObject(data.component, root, { text: "Label", width: 400 })
		const row = createTemporaryObject(data.component, root, { text: "Label", caption: caption, width: 400 })
		verify(plain)
		verify(row)
		// A set caption makes the row taller than an empty one, and sits under the label,
		// inside the row. Layout settles a frame after the caption is set.
		tryVerify(function() { return plain.implicitHeight > 0 && row.implicitHeight > plain.implicitHeight })
		row.height = row.implicitHeight
		const label = childText(row, "Label")
		const captionLabel = childText(row, caption)
		verify(label !== null)
		verify(captionLabel !== null)
		verify(captionLabel.visible)
		tryVerify(function() {
			const labelBottom = label.mapToItem(row, 0, label.height).y
			const captionTop = captionLabel.mapToItem(row, 0, 0).y
			const captionBottom = captionLabel.mapToItem(row, 0, captionLabel.height).y
			return captionLabel.height > 0
					&& captionTop >= labelBottom - 1
					&& captionBottom <= row.height + 1
		})

		if (data.clickable) {
			let clicks = 0
			row.clicked.connect(function() { clicks += 1 })
			row.click()
			compare(clicks, 1)
		}
	}

	// The gui-v2 list item that a Plugin* list item wraps.
	function innerListItem(pluginListItem) {
		for (let i = 0; i < pluginListItem.children.length; ++i) {
			const child = pluginListItem.children[i]
			if (child.flat !== undefined) {
				return child
			}
		}
		return null
	}

	function test_flatIsPassedToTheInnerListItem_data() {
		return [
			{ tag: "button", component: pluginButtonComponent },
			{ tag: "navigation", component: pluginNavigationComponent },
			{ tag: "quantity", component: pluginQuantityComponent },
			{ tag: "radio", component: pluginRadioComponent },
			{ tag: "setting", component: pluginSettingComponent },
			{ tag: "slider", component: pluginSliderComponent },
			{ tag: "spinbox", component: pluginSpinBoxComponent },
			{ tag: "switch", component: pluginListSwitchComponent },
			{ tag: "temperature", component: pluginTemperatureComponent },
			{ tag: "text", component: pluginTextComponent },
			{ tag: "textfield", component: pluginTextFieldComponent },
		]
	}

	function test_flatIsPassedToTheInnerListItem(data) {
		const plain = createTemporaryObject(data.component, root, { text: "Label", width: 300 })
		const flat = createTemporaryObject(data.component, root, { text: "Label", width: 300, flat: true })
		verify(plain)
		verify(flat)
		const plainInner = innerListItem(plain)
		const flatInner = innerListItem(flat)
		verify(plainInner !== null)
		verify(flatInner !== null)

		compare(plainInner.flat, false)
		compare(plainInner.x, 0)
		compare(plainInner.width, 300)
		compare(flatInner.flat, true)
		compare(flatInner.x, 0)
		compare(flatInner.width, 300)
	}

	function findSlider(item) {
		if (!item) {
			return null
		}
		if (typeof item.valueAt === "function" && item.position !== undefined) {
			return item
		}
		for (let i = 0; i < item.children.length; ++i) {
			const found = findSlider(item.children[i])
			if (found) {
				return found
			}
		}
		return null
	}

	function test_sliderShowsTheBoundValue() {
		root.sliderHostValue = 30
		const row = createTemporaryObject(boundSliderComponent, root, { width: 400 })
		verify(row)
		const slider = findSlider(row)
		verify(slider !== null)
		compare(row.value, 30)
		compare(slider.value, 30)

		root.sliderHostValue = 70
		compare(row.value, 70)
		compare(slider.value, 70)
	}

	function test_sliderKeysChangeTheValue() {
		Global.keyNavigationEnabled = true
		root.sliderHostValue = 50
		const row = createTemporaryObject(boundSliderComponent, root, { width: 400 })
		verify(row)
		tryVerify(function() { return row.visible && row.height > 0 })
		compare(row.stepSize, 10)

		row.forceActiveFocus()
		tryCompare(row, "activeFocus", true)

		// Left and Right change the number only after Space, until Escape.
		keyClick(Qt.Key_Right)
		compare(row.value, 50)
		keyClick(Qt.Key_Space)
		keyClick(Qt.Key_Right)
		compare(row.value, 60)
		keyClick(Qt.Key_Left)
		keyClick(Qt.Key_Left)
		compare(row.value, 40)
		keyClick(Qt.Key_Escape)
		keyClick(Qt.Key_Right)
		compare(row.value, 40)
	}

	function test_sliderUsesTheDataItem() {
		MockManager.setValue(root.sliderUid, 40)
		MockManager.setProperty(root.sliderUid, "min", 0)
		MockManager.setProperty(root.sliderUid, "max", 200)
		Global.keyNavigationEnabled = true
		const row = createTemporaryObject(dataSliderComponent, root, { width: 400 })
		verify(row)
		tryCompare(row, "value", 40)
		compare(row.from, 0)
		compare(row.to, 200)
		compare(row.stepSize, 20)
		tryVerify(function() { return row.visible && row.height > 0 })

		row.forceActiveFocus()
		tryCompare(row, "activeFocus", true)
		keyClick(Qt.Key_Space)
		keyClick(Qt.Key_Right)
		tryCompare(row, "value", 60)
		compare(MockManager.value(root.sliderUid), 60)

		// Remove the value only after the row stops using it.
		row.destroy()
		wait(0)
		MockManager.removeValue(root.sliderUid)
	}

	Component {
		id: listSwitchComponent

		ListSwitch {}
	}

	Component {
		id: pluginListSwitchComponent

		PluginListSwitch {}
	}

	Component {
		id: pluginButtonComponent

		PluginListButton { secondaryText: "Go" }
	}

	Component {
		id: pluginNavigationComponent

		PluginListNavigation {}
	}

	Component {
		id: pluginQuantityComponent

		PluginListQuantity { value: 230; unit: PluginUnit.Volt_DC }
	}

	Component {
		id: pluginRadioComponent

		PluginListRadioButtonGroup {
			optionModel: [ { display: "Off", value: 0 }, { display: "On", value: 1 } ]
			currentIndex: 0
		}
	}

	Component {
		id: pluginSpinBoxComponent

		PluginListSpinBox { value: 12 }
	}

	Component {
		id: pluginTemperatureComponent

		PluginListTemperature {}
	}

	Component {
		id: pluginTextComponent

		PluginListText { secondaryText: "230 V" }
	}

	Component {
		id: pluginTextFieldComponent

		PluginListTextField { secondaryText: "name" }
	}

	Component {
		id: pluginSettingComponent

		PluginListSetting {
			PluginLabel { text: "Content" }
		}
	}

	Component {
		id: pluginSliderComponent

		PluginListSlider {}
	}

	Component {
		id: boundSliderComponent

		PluginListSlider {
			to: 100
			value: root.sliderHostValue
		}
	}

	Component {
		id: dataSliderComponent

		PluginListSlider {
			dataItem.uid: root.sliderUid
		}
	}
}
