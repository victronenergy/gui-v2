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
			const ticks = root.probeNavTicks()
			console.warn("PROBE ticks before visit", ticks)
			return ticks === 0
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

	function probeNavPage() {
		const pages = Global.mainView.navBar.pages
		for (let i = 0; i < pages.length; ++i) {
			if (String(pages[i].url).indexOf("ProbeNav_Page.qml") >= 0)
				return pages[i]
		}
		return null
	}

	function readTicks(item) {
		if (!item)
			return 0
		if (item.ticks !== undefined)
			return Number(item.ticks)
		const children = item.children
		if (!children)
			return 0
		for (let i = 0; i < children.length; ++i) {
			if (children[i] && children[i].ticks !== undefined)
				return Number(children[i].ticks)
			const nested = root.readTicks(children[i])
			if (nested > 0)
				return nested
		}
		return 0
	}

	function probeNavTicks() {
		return root.readTicks(root.probeNavPage())
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

	function test_nav_plugin_ticks_while_shown() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.WaitUntil, { callable: () => root.navHas("ProbeNav_Page.qml"), timeout: 5000 })
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("ProbeNav_Page.qml") })
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			root._ticksAtOpen = root.probeNavTicks()
			return true
		}})
		addStep(UiTestStep.Wait, { timeout: 500 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const now = root.probeNavTicks()
			console.warn("PROBE ticks while open", root._ticksAtOpen, "->", now)
			return now > root._ticksAtOpen
		}})
		runSteps()
	}

	function test_quickaccess_pane_opens_and_closes() {
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
			const img = findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/ProbeQuick/icon_brick.svg") })
			const btn = findClickableParent(img)
			if (!btn) {
				console.warn("ProbeQuick button missing")
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

	function test_portrait_hides_plugin_icon_on_subpage() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			if (Global.mainView.cardsActive)
				Global.mainView.cardsLoader.hide()
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
}
