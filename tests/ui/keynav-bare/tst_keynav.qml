/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
	id: root

	window: Global.main

	property bool sawPluginIcon: false

	function ready() {
		return Global.allPagesLoaded && !UiConfig.splashScreenVisible
	}

	function focusIcon(item) {
		let n = item
		while (n) {
			if (n.icon && n.icon.source)
				return String(n.icon.source)
			n = n.parent
		}
		return ""
	}

	function test_right_reaches_trailing_buttons() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			Global.keyNavigationEnabled = true
			return Global.mainView.navBar.setCurrentPage("BriefPage.qml")
		}})
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_off_32.svg") })
			const btn = findClickableParent(img)
			if (!btn) {
				console.warn("KEYNAV controls button not found")
				return false
			}
			btn.forceActiveFocus()
			console.warn("KEYNAV focused controls", btn.activeFocus)
			return btn.activeFocus
		}})
		for (let i = 0; i < 6; ++i) {
			addStep(UiTestStep.Invoke, { callable: () => {
				const item = root.window.activeFocusItem
				if (!item) {
					console.warn("KEYNAV no active focus")
					return false
				}
				return keyClick(item, Qt.Key_Right)
			}})
			addStep(UiTestStep.Wait, { timeout: 50 })
		}
		addStep(UiTestStep.Invoke, { callable: () => {
			const icon = root.focusIcon(root.window.activeFocusItem)
			console.warn("KEYNAV landed on", icon)
			return icon.indexOf("icon_screen_sleep") >= 0 || icon.indexOf("icon_sidepanel") >= 0
		}})
		runSteps()
	}

	function test_right_reaches_plugin_before_trailing() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			Global.keyNavigationEnabled = true
			return Global.mainView.navBar.setCurrentPage("BriefPage.qml")
		}})
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_off_32.svg") })
			const btn = findClickableParent(img)
			if (!btn)
				return false
			btn.forceActiveFocus()
			return btn.activeFocus
		}})
		for (let i = 0; i < 4; ++i) {
			addStep(UiTestStep.Invoke, { callable: () => {
				const item = root.window.activeFocusItem
				if (!item)
					return false
				const icon = root.focusIcon(item)
				if (icon.indexOf("icon_brick") >= 0) {
					root.sawPluginIcon = true
					return true
				}
				return keyClick(item, Qt.Key_Right)
			}})
			addStep(UiTestStep.Wait, { timeout: 50 })
		}
		addStep(UiTestStep.Invoke, { callable: () => {
			console.warn("KEYNAV plugin icon seen", root.sawPluginIcon, "focus", root.focusIcon(root.window.activeFocusItem))
			return root.sawPluginIcon
		}})
		runSteps()
	}

	function test_left_from_sleep_reaches_side_panel() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			Global.keyNavigationEnabled = true
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_screen_sleep_32.svg") })
			const btn = findClickableParent(img)
			if (!btn || !btn.visible) {
				console.warn("KEYNAV sleep button not visible")
				return false
			}
			btn.forceActiveFocus()
			return btn.activeFocus && keyClick(btn, Qt.Key_Left)
		}})
		addStep(UiTestStep.Wait, { timeout: 50 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const icon = root.focusIcon(root.window.activeFocusItem)
			console.warn("KEYNAV left of sleep landed on", icon)
			return icon.indexOf("icon_sidepanel") >= 0
		}})
		runSteps()
	}
}
