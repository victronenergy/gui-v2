/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Loads probe pages through GuiPluginLoader.pluginsJson. The page URLs are in
// this module, and the resource is a dummy rcc, so the test writes nothing.
UiTestCase {
	id: root

	window: Global.main

	readonly property string dummyResource: "cXJlcwAAAAMAAABfAAAAGAAAAC8AAAAAAAAAE3N0YXJ0LXBhZ2UgVUkgdGVzdAoADA0ot6YAUwB0AGEAcgB0AFAAYQBnAGUATgBhAHYABgVpWRUAUgBFAEEARABNAEUAAAAAAAIAAAABAAAAAQAAAAAAAAAAAAAAAAACAAAAAQAAAAIAAAAAAAAAAAAAAB4AAAAAAAEAAAAAAAABoRUTDYM="

	function ready() {
		return Global.allPagesLoaded && !UiConfig.splashScreenVisible
	}

	function probePlugin(name, fileName) {
		return {
			name: name,
			version: "1.0",
			resource: root.dummyResource,
			integrations: [ {
				type: GuiPluginLoader.NavigationPage,
				url: "qrc:/qt/qml/Victron/UiTest/tests/ui/plugins/" + fileName,
				icon: "qrc:/images/levels.svg",
				title: name
			} ]
		}
	}

	function reloadProbes() {
		const desired = JSON.stringify([
			root.probePlugin("ProbeNav", "ProbeNav_Page.qml"),
			root.probePlugin("ProbeBroken", "ProbeBroken_Page.qml")
		])
		if (GuiPluginLoader.pluginsJson === desired) {
			GuiPluginLoader.pluginsJson = " "
		}
		GuiPluginLoader.pluginsJson = desired
	}

	function navHas(pageName) {
		const pages = Global.mainView.navBar.pages
		for (let i = 0; i < pages.length; ++i) {
			if (String(pages[i].url).indexOf(pageName) >= 0) {
				return true
			}
		}
		return false
	}

	function probeNavPage() {
		const pages = Global.mainView.navBar.pages
		for (let i = 0; i < pages.length; ++i) {
			if (String(pages[i].url).indexOf("ProbeNav_Page.qml") >= 0) {
				return pages[i]
			}
		}
		return null
	}

	function readTicks(item) {
		if (!item) {
			return 0
		}
		if (item.ticks !== undefined) {
			return Number(item.ticks)
		}
		const children = item.children
		if (!children) {
			return 0
		}
		for (let i = 0; i < children.length; ++i) {
			if (children[i] && children[i].ticks !== undefined) {
				return Number(children[i].ticks)
			}
			const nested = root.readTicks(children[i])
			if (nested > 0) {
				return nested
			}
		}
		return 0
	}

	function probeNavTicks() {
		return root.readTicks(root.probeNavPage())
	}

	function test_nav_plugin_idle_until_shown() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			root.reloadProbes()
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && root.navHas("ProbeNav_Page.qml"),
			timeout: 90000
		})
		addStep(UiTestStep.Wait, { timeout: 700 })
		addStep(UiTestStep.Invoke, { callable: () => {
			const ticks = root.probeNavTicks()
			console.warn("PROBE ticks before visit", ticks)
			return ticks === 0
		}})
		runSteps()
	}

	function test_nav_plugin_ticks_while_shown() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			root.reloadProbes()
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && root.navHas("ProbeNav_Page.qml"),
			timeout: 90000
		})
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

	function test_failed_nav_page_returns_to_previous() {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			root.reloadProbes()
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && root.navHas("ProbeBroken_Page.qml"),
			timeout: 90000
		})
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

	property int _ticksAtOpen: -1
}
