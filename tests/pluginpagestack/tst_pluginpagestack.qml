/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import Victron.GuiPlugins
import QtTest

// VenusOS must not import Victron.GuiPlugins. This test may import both, and it loads fixture
// pages by URL, which is how PageStack.pushPluginPage() loads a real plugin page.
TestCase {
	id: root
	name: "PluginPageStackTest"
	when: windowShown

	readonly property string settingsUrl: "qrc:/pluginpagestack/pages/PluginSettingsPage.qml"
	readonly property string deviceUrl: "qrc:/pluginpagestack/pages/PluginDevicePageTest.qml"
	readonly property string venusUrl: "qrc:/pluginpagestack/pages/VenusPage.qml"
	readonly property string notAnItemUrl: "qrc:/pluginpagestack/pages/NotAnItem.qml"
	readonly property string brokenUrl: "qrc:/pluginpagestack/pages/BrokenPage.qml"

	property var _stack: null

	Window {
		id: stackWindow
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height
		visible: true
	}

	Component {
		id: stackComponent
		PageStack {}
	}

	Component {
		id: pluginRowComponent
		PluginListRow {}
	}

	function createStack() {
		const stack = stackComponent.createObject(stackWindow)
		verify(stack)
		_stack = stack
		return stack
	}

	function waitUntilIdle(stack) {
		tryCompare(stack, "animating", false)
	}

	function initTestCase() {
		// Unit tests do not load a mock configuration, so the access level is unset and
		// canAccess() is false. Service allows the default show level.
		MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel",
				VenusOS.User_AccessType_Service)
		tryVerify(function() {
			return !!Services.settings
					&& Services.settings.canAccess(VenusOS.User_AccessType_Service)
		}, 20000)
	}

	function init() {
		UiConfig.animationEnabled = false
		UiConfig.applicationVisible = true
		Global.allPagesLoaded = true
		Global.keyNavigationEnabled = false
		_stack = null
		compare(PluginPageTestTracker.live, 0)
	}

	function cleanup() {
		// Hosts have no parent. destroy() drops the last reference, and
		// collection brings live back to 0. It does not destroy them as children.
		if (_stack) {
			_stack.destroy()
			_stack = null
		}
		tryCompare(PluginPageTestTracker, "live", 0)
		Global.keyNavigationEnabled = false
		Global.allPagesLoaded = false
	}

	function test_pluginPageIsHosted() {
		const stack = createStack()
		const host = stack.pushPluginPage(settingsUrl, { title: "From caller" }, StackView.Immediate)
		verify(host)
		waitUntilIdle(stack)

		verify(host.__is_venus_gui_page__)
		compare(stack.depth, 1)
		compare(stack.currentItem, host)
		compare(host.pluginPage.objectName, "pluginSettingsPage")
		compare(host.pluginPage.parent, host)
		compare(host.pluginPage.anchors.fill, host)
		verify(!host.pluginPage.__is_venus_gui_page__)
		compare(host.pluginPage.title, "From caller")
		compare(host.title, "From caller")

		host.pluginPage.title = "Changed"
		compare(host.title, "Changed")
		compare(PluginPageTestTracker.live, 1)
	}

	function test_devicePageReceivesProperties() {
		const stack = createStack()
		const host = stack.pushPluginPage(deviceUrl, {
			serviceUid: "mock/com.victronenergy.battery/0",
			productId: 0x106,
			deviceName: "Test battery",
			title: "Cells"
		}, StackView.Immediate)
		verify(host)
		waitUntilIdle(stack)

		compare(host.pluginPage.serviceUid, "mock/com.victronenergy.battery/0")
		compare(host.pluginPage.productId, 0x106)
		compare(host.pluginPage.deviceName, "Test battery")
		compare(host.title, "Cells")
		compare(host.pluginPage.parent, host)
		compare(PluginPageTestTracker.live, 1)
	}

	function test_secondPluginPagePushesOntoOpenStack() {
		const stack = createStack()
		const first = stack.pushPluginPage(settingsUrl, {}, StackView.Immediate)
		verify(first)
		waitUntilIdle(stack)

		const second = stack.pushPluginPage(settingsUrl, { title: "Sub" }, StackView.Immediate)
		verify(second)
		waitUntilIdle(stack)
		compare(stack.depth, 2)
		compare(stack.currentItem, second)
		compare(second.pluginPage.title, "Sub")
		compare(second.title, "Sub")
		compare(second.pluginPage.parent, second)
		compare(PluginPageTestTracker.live, 2)

		// Back navigation uses the existing popExit path, shared with built-in pages.
		// Leaving the stack destroys every hosted plugin page.
		stack.popPage(first, StackView.PopTransition)
		waitUntilIdle(stack)
		compare(stack.depth, 1)
		compare(stack.currentItem, first)
	}

	function test_popAllDestroysHostAndPluginPage() {
		const stack = createStack()
		const first = stack.pushPluginPage(settingsUrl, {}, StackView.Immediate)
		verify(first)
		waitUntilIdle(stack)
		const second = stack.pushPluginPage(settingsUrl, { title: "Sub" }, StackView.Immediate)
		verify(second)
		waitUntilIdle(stack)
		compare(PluginPageTestTracker.live, 2)

		stack.popAllPages(StackView.Immediate)
		waitUntilIdle(stack)
		tryCompare(PluginPageTestTracker, "live", 0)
		compare(stack.depth, 0)
	}

	function test_pageRootIsRejectedAndDoesNotBlockALaterPush() {
		const stack = createStack()
		ignoreWarning(/Aborted attempt to push plugin page whose root is a Page/)
		compare(stack.pushPluginPage(venusUrl), null)
		compare(stack.depth, 0)
		tryCompare(PluginPageTestTracker, "live", 0)

		const host = stack.pushPluginPage(settingsUrl, {}, StackView.Immediate)
		verify(host)
		compare(stack.depth, 1)
		compare(PluginPageTestTracker.live, 1)
	}

	function test_nonItemRootIsRejected() {
		const stack = createStack()
		ignoreWarning(/Aborted attempt to push plugin page whose root is not an item/)
		compare(stack.pushPluginPage(notAnItemUrl), null)
		compare(stack.depth, 0)
		tryCompare(PluginPageTestTracker, "live", 0)
	}

	function test_compileErrorIsRejected() {
		const stack = createStack()
		// The logged line includes the QML error, so one pattern covers both.
		ignoreWarning(/Aborted attempt to push plugin page with errors:.*NotAType is not a type/)
		compare(stack.pushPluginPage(brokenUrl), null)
		compare(stack.depth, 0)
		compare(PluginPageTestTracker.live, 0)
	}

	function test_missingFileIsRejected() {
		const stack = createStack()
		ignoreWarning(/Aborted attempt to push plugin page with errors:/)
		compare(stack.pushPluginPage("qrc:/pluginpagestack/pages/Missing.qml"), null)
		compare(stack.depth, 0)
		compare(PluginPageTestTracker.live, 0)
	}

	function test_missingRequiredPropertiesAreRejected() {
		const stack = createStack()
		ignoreWarning(/Required property serviceUid was not initialized/)
		ignoreWarning(/Required property productId was not initialized/)
		ignoreWarning(/Required property deviceName was not initialized/)
		ignoreWarning(/Aborted attempt to push plugin page because createObject\(\) failed/)
		compare(stack.pushPluginPage(deviceUrl), null)
		compare(stack.depth, 0)
		tryCompare(PluginPageTestTracker, "live", 0)
	}

	function test_pushPageRejectsPluginPage() {
		const stack = createStack()
		ignoreWarning(/Aborted attempt to push page whose root is not a Page/)
		compare(stack.pushPage(settingsUrl), null)
		compare(stack.depth, 0)
		tryCompare(PluginPageTestTracker, "live", 0)
	}

	function test_pluginRowKeyHandlersFollowKeyNavigation() {
		// Settings are loaded in initTestCase. A missing settings object would make
		// effectiveVisible false and leave Keys.enabled false.
		Global.keyNavigationEnabled = false
		const row = pluginRowComponent.createObject(stackWindow)
		verify(row)
		tryCompare(row, "effectiveVisible", true)
		tryCompare(row.Keys, "enabled", false)
		Global.keyNavigationEnabled = true
		tryCompare(row.Keys, "enabled", true)
		row.preferredVisible = false
		tryCompare(row.Keys, "enabled", false)
		row.destroy()
	}
}
