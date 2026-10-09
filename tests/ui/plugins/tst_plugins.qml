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

	function ready() {
		return Global.allPagesLoaded && !UiConfig.splashScreenVisible
	}

	function pluginNames() {
		const pl = GuiPluginLoader.plugins
		let names = []
		for (let i = 0; i < pl.length; ++i)
			names.push(pl[i].name)
		return names.join(",")
	}

	function test_nav_plugin_idle_until_shown() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Wait, { timeout: 700 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const names = root.pluginNames()
			if (names.indexOf("ProbeNav") < 0) {
				console.warn("PROBE plugins missing:", names)
				return false
			}
			const ticks = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			console.warn("PROBE ticks before visit", ticks)
			return ticks === 0
		}})
		runSteps()
	}

	function test_enable_keeps_current_page() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("NotificationsPage.qml") })
		addStep(UiTestStep.WaitUntil, {
			callable: () => String(Global.mainView.swipeView.currentItem.url).endsWith("NotificationsPage.qml"),
			timeout: 5000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeNav", false)
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const url = String(Global.mainView.swipeView.currentItem ? Global.mainView.swipeView.currentItem.url : "")
			console.warn("PAGE after enable flip", url, "nav", Global.mainView.navBar.currentIndex,
					"probe still listed", root.navHas("ProbeNav_Page.qml"))
			if (root.navHas("ProbeNav_Page.qml"))
				return false
			if (!url.endsWith("NotificationsPage.qml"))
				return false
			GuiPluginLoader.setPluginEnabled("ProbeNav", true)
			return true
		}})
		runSteps()
	}

	function navHas(pageName) {
		const pages = Global.mainView.navBar.pages
		for (let i = 0; i < pages.length; ++i) {
			if (String(pages[i].url).indexOf(pageName) >= 0)
				return true
		}
		return false
	}

	// findItem walks QObject children and misses this portrait repeater's icon.
	// The icon is in the visual tree; match the source string there.
	function findVisual(item, needle) {
		if (!item)
			return null
		if (item.source !== undefined && String(item.source).indexOf(needle) >= 0)
			return item
		const children = item.children
		if (!children)
			return null
		for (let i = 0; i < children.length; ++i) {
			const found = root.findVisual(children[i], needle)
			if (found)
				return found
		}
		return null
	}

	function probeQuickButton() {
		const img = root.findVisual(Global.mainView.statusBar, "qrc:/ProbeQuick/icon_brick.svg")
		return img ? findClickableParent(img) : null
	}

	function test_disabled_nav_plugin_stops() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.WaitUntil, { callable: () => root.navHas("ProbeNav_Page.qml"), timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("ProbeNav_Page.qml") })
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			root._ticksAtOpen = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const now = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			console.warn("PROBE ticks while open", root._ticksAtOpen, "->", now)
			if (now <= root._ticksAtOpen)
				return false
			root._ticksBeforeDisable = now
			GuiPluginLoader.setPluginEnabled("ProbeNav", false)
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 700 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const now = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			console.warn("PROBE ticks after disable", root._ticksBeforeDisable, "->", now)
			return now === root._ticksBeforeDisable
		}})
		runSteps()
	}

	function test_quickaccess_pane_survives_reset() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			if (Global.mainView.cardsActive)
				Global.mainView.cardsLoader.hide()
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/ProbeQuick/icon_brick.svg") })
			const btn = findClickableParent(img)
			if (!btn) {
				console.warn("ProbeQuick button not found")
				return false
			}
			return mouseClick(btn)
		}})
		addStep(UiTestStep.WaitUntil, { callable: () => Global.mainView.cardsActive, timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeCard", false)
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/ProbeQuick/icon_brick.svg") })
			const btn = findClickableParent(img)
			if (!btn) {
				console.warn("ProbeQuick button missing after model reset")
				return false
			}
			console.warn("PANE cardsActive", Global.mainView.cardsActive, "opacity", btn.opacity, "visible", btn.visible)
			if (Global.mainView.cardsActive && btn.opacity < 0.05)
				return false
			return mouseClick(btn)
		}})
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			console.warn("PANE cardsActive after close click", Global.mainView.cardsActive)
			return !Global.mainView.cardsActive
		}})
		runSteps()
	}

	function test_disabling_open_quickaccess_closes_pane() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeQuick", true)
			if (Global.mainView.cardsActive)
				Global.mainView.cardsLoader.hide()
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/ProbeQuick/icon_brick.svg") })
			const btn = findClickableParent(img)
			if (!btn) {
				console.warn("ProbeQuick button not found for close-on-disable")
				return false
			}
			return mouseClick(btn)
		}})
		addStep(UiTestStep.WaitUntil, { callable: () => Global.mainView.cardsActive, timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeQuick", false)
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			console.warn("PANE cardsActive after disabling ProbeQuick", Global.mainView.cardsActive)
			return !Global.mainView.cardsActive
		}})
		runSteps()
	}

	function test_portrait_hides_plugin_icon_on_subpage() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			if (Global.mainView.cardsActive)
				Global.mainView.cardsLoader.hide()
			GuiPluginLoader.setPluginEnabled("ProbeQuick", true)
			// The status bar picks its layout from Theme.screenSize. The Xvfb
			// screen is landscape, so select portrait directly.
			Theme.screenSize = Theme.Portrait
			console.warn("PORTRAIT screenSize", Theme.screenSize, "isDesktop", Global.isDesktop, "isGx", Global.isGxDevice)
			return Theme.screenSize === Theme.Portrait
		}})
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const btn = root.probeQuickButton()
			console.warn("PORTRAIT main visible", btn ? btn.visible : "missing",
					"opened", Global.pageManager.pageStack.opened,
					"cards", Global.mainView.cardsActive)
			if (!btn || btn.visible !== true) {
				root.dumpImageSources(Global.mainView.statusBar, 0)
				return false
			}
			return true
		}})
		addStep(UiTestStep.Invoke, { callable: () => {
			Global.pageManager.pushPage("/pages/settings/PageSettingsGeneral.qml", {})
			return true
		}})
		addStep(UiTestStep.WaitUntil, { callable: () => Global.pageManager.pageStack.opened, timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const btn = root.probeQuickButton()
			console.warn("PORTRAIT subpage visible", btn ? btn.visible : "missing",
					"opened", Global.pageManager.pageStack.opened)
			return !!btn && btn.visible === false
		}})
		runSteps()
	}

	function test_reenable_does_not_load_offscreen() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeNav", true)
			return Global.mainView.navBar.setCurrentPage("ProbeNav_Page.qml")
		}})
		addStep(UiTestStep.WaitUntil, { callable: () => root.navHas("ProbeNav_Page.qml"), timeout: 5000 })
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			GuiPluginLoader.setPluginEnabled("ProbeNav", false)
			return true
		}})
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("NotificationsPage.qml") })
		addStep(UiTestStep.Wait, { timeout: 400 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const url = String(Global.mainView.swipeView.currentItem ? Global.mainView.swipeView.currentItem.url : "")
			if (!url.endsWith("NotificationsPage.qml"))
				return false
			root._ticksBeforeDisable = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			GuiPluginLoader.setPluginEnabled("ProbeNav", true)
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 700 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const now = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			console.warn("PROBE ticks after re-enable offscreen", root._ticksBeforeDisable, "->", now)
			return now === root._ticksBeforeDisable
		}})
		runSteps()
	}

	function test_failed_nav_page_returns_to_previous() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.WaitUntil, { callable: () => root.navHas("ProbeBroken_Page.qml"), timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("OverviewPage.qml") })
		addStep(UiTestStep.WaitUntil, {
			callable: () => String(Global.mainView.swipeView.currentItem.url).endsWith("OverviewPage.qml"),
			timeout: 5000
		})
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("ProbeBroken_Page.qml") })
		addStep(UiTestStep.WaitUntil, {
			callable: () => String(Global.mainView.swipeView.currentItem.url).endsWith("OverviewPage.qml")
					&& !root.navHas("ProbeBroken_Page.qml"),
			timeout: 5000
		})
		runSteps()
	}

	function dumpImageSources(item, depth) {
		if (!item || depth > 8)
			return
		if (item.source !== undefined && String(item.source).length > 0)
			console.warn("PORTRAIT src", String(item.source))
		const children = item.children
		if (!children)
			return
		for (let i = 0; i < children.length; ++i)
			root.dumpImageSources(children[i], depth + 1)
	}

	property int _ticksAtOpen: -1
	property int _ticksBeforeDisable: -1
}
