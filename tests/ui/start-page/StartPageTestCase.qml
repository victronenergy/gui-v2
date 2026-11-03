/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Checks that the configured start page is still shown once every main page has loaded. Boat,
// Levels and plugin nav pages can be inserted after the other pages. Inserting a row must not
// drop the configured start page.
//
// Each test sets the start page and reloads the UI by assigning GuiPluginLoader.pluginsJson.
// That sets the loader busy, which clears Global.appDataReady and goes through the same start-up
// path. Each test also sets everything else it depends on (the
// installed plugins, the Boat page and any alarm) before the rebuild, so the tests do not depend
// on each other or on their order. Without a Levels page, each test removes the mock tank and
// temperature services; they cannot be added back, so the tests with and without a Levels page are
// in separate UI tests. Both use the maximal mock configuration: the late pages arrive late more
// reliably with its load than with a small configuration.
//
// The plugins are set through GuiPluginLoader.pluginsJson, so the tests do not use the build's
// plugins directory and write no plugin state.
UiTestCase {
	id: root

	// Whether there is a Levels page. If not, the tank and temperature services are removed.
	required property bool hasLevelsPage

	window: Global.main

	// A nav plugin whose page is StartPageNavPage.qml. `resource` is a minimal rcc, because the
	// loader ignores a plugin without one.
	readonly property var navPlugin: ({
		name: "StartPageNav",
		version: "1.0",
		resource: "cXJlcwAAAAMAAABfAAAAGAAAAC8AAAAAAAAAE3N0YXJ0LXBhZ2UgVUkgdGVzdAoADA0ot6YAUwB0AGEAcgB0AFAAYQBnAGUATgBhAHYABgVpWRUAUgBFAEEARABNAEUAAAAAAAIAAAABAAAAAQAAAAAAAAAAAAAAAAACAAAAAQAAAAIAAAAAAAAAAAAAAB4AAAAAAAEAAAAAAAABoRUTDYM=",
		integrations: [ {
			type: GuiPluginLoader.NavigationPage,
			url: "qrc:/qt/qml/Victron/UiTest/tests/ui/start-page/StartPageNavPage.qml",
			icon: "qrc:/images/levels.svg",
			title: "Start"
		} ]
	})

	function ready() {
		return Global.allPagesLoaded && !UiConfig.splashScreenVisible && !!Global.mainView && !Global.mainView.animating
	}

	function pageName(page) {
		return page ? String(page.url).split("/").pop() : ""
	}

	function pageNames() {
		const pages = Global.mainView.navBar.pages
		let names = []
		for (let i = 0; i < pages.length; ++i) {
			names.push(pageName(pages[i]))
		}
		return names
	}

	function startPageConfig(type) {
		return Services.settings.startPageConfiguration._jsonStringForType(type)
	}

	function notificationUid(index) {
		return BackendConnection.serviceUidForType("platform") + "/Notifications/" + index
	}

	// populatePlugins() sets busy, which tears the UI down. The same string does not
	// reload, so write a different value first when a reload is required anyway.
	function reloadPlugins(plugins) {
		const desired = JSON.stringify(plugins)
		if (GuiPluginLoader.pluginsJson === desired) {
			GuiPluginLoader.pluginsJson = " "
		}
		GuiPluginLoader.pluginsJson = desired
	}

	function clearAlarms() {
		for (let i = 0; i < NotificationModel.count; ++i) {
			const uid = root.notificationUid(i)
			if (MockManager.value(uid + "/Type") === VenusOS.Notification_Alarm) {
				MockManager.setValue(uid + "/Active", 0)
				MockManager.setValue(uid + "/Acknowledged", 1)
			}
		}
	}

	// Rebuilds the UI with the given start page and state, then checks that `expectedPage` is shown
	// once all of the late pages are in the nav bar. Each late page must be present exactly when
	// expected, so that a test cannot pass because a late page never loaded.
	//
	// params: startPage (StartPageName JSON), navPlugin, boatPage, alarm (bool), expectedPage,
	// expectedStackPage (optional).
	function checkStartPage(params) {
		const latePages = { "BoatPage.qml": params.boatPage, "LevelsPage.qml": root.hasLevelsPage,
				"StartPageNavPage.qml": params.navPlugin }

		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui/ElectricPropulsionUI/Enabled",
					params.boatPage ? 1 : 0)
			if (!root.hasLevelsPage) {
				MockManager.removeServices("tank")
				MockManager.removeServices("temperature")
			}
			root.clearAlarms()
			if (params.alarm) {
				MockManager.addDummyNotification(true)
			}
			// Last, so this reload sees the boat page and alarms set above.
			root.reloadPlugins(params.navPlugin ? [ root.navPlugin ] : [])
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && (NotificationModel.activeAlarms > 0) === params.alarm,
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui2/StartPageName", params.startPage)
			root.reloadPlugins(params.navPlugin ? [ root.navPlugin ] : [])
			return !Global.allPagesLoaded
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => {
				if (!root.ready()) {
					return false
				}
				const names = root.pageNames()
				for (const name in latePages) {
					if (latePages[name] && names.indexOf(name) < 0) {
						return false
					}
				}
				return true
			},
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			const names = root.pageNames()
			const navBar = Global.mainView.navBar
			const currentPage = root.pageName(Global.mainView.swipeView.currentItem)
			const navPage = root.pageName(navBar.pages[navBar.currentIndex])
			const pageStack = Global.pageManager.pageStack
			const stackPage = pageStack.opened ? String(pageStack.topPageUrl) : ""
			console.warn("START PAGE expected:", params.expectedPage, "| view:", currentPage, "| nav:", navPage,
					"| stack:", stackPage, "| alarms:", NotificationModel.activeAlarms, "| pages:", names.join(","))
			for (const name in latePages) {
				if ((names.indexOf(name) >= 0) !== latePages[name]) {
					return false
				}
			}
			return currentPage === params.expectedPage
					&& navPage === params.expectedPage
					&& (params.expectedStackPage ? stackPage.endsWith(params.expectedStackPage) : stackPage === "")
		}})
		runSteps()
	}

	// A navigation plugin page. `location` is omitted when undefined, which defaults to BeforeLevels.
	function navPluginAt(name, fileName, location) {
		const integration = {
			type: GuiPluginLoader.NavigationPage,
			url: "qrc:/start-page-tests/" + fileName,
			icon: "qrc:/images/levels.svg",
			title: name
		}
		if (location !== undefined) {
			integration.location = location
		}
		return {
			name: name,
			version: "1.0",
			resource: root.navPlugin.resource,
			integrations: [ integration ]
		}
	}

	function nameBefore(names, earlier, later) {
		const a = names.indexOf(earlier)
		const b = names.indexOf(later)
		return a >= 0 && b >= 0 && a < b
	}

	// Reloads the given plugins and checks navbar order. Levels may or may not be present.
	function checkPluginPageOrder(plugins, assertOrder) {
		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui/ElectricPropulsionUI/Enabled", 1)
			root.clearAlarms()
			root.reloadPlugins(plugins)
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && root.pageNames().indexOf("BoatPage.qml") >= 0,
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			const names = root.pageNames()
			console.warn("NAV ORDER pages:", names.join(","))
			return assertOrder(names)
		}})
		runSteps()
	}

	function test_nav_plugin_locations() {
		const rejectedString = root.navPluginAt("RejectedString", "RejectedStringPage.qml")
		rejectedString.integrations[0].location = "BeforeBoat"
		root.checkPluginPageOrder([
			root.navPluginAt("BoatGap", "BoatGapPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeBoat),
			root.navPluginAt("LevelsGap", "LevelsGapPage.qml"),
			root.navPluginAt("SettingsGap", "SettingsGapPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeSettings),
			root.navPluginAt("RejectedZero", "RejectedZeroPage.qml", 0),
			root.navPluginAt("RejectedRange", "RejectedRangePage.qml", 99),
			rejectedString
		], function(names) {
			if (names.indexOf("RejectedZeroPage.qml") >= 0
					|| names.indexOf("RejectedRangePage.qml") >= 0
					|| names.indexOf("RejectedStringPage.qml") >= 0) {
				return false
			}
			if (!root.nameBefore(names, "BoatGapPage.qml", "BoatPage.qml")
					|| !root.nameBefore(names, "OverviewPage.qml", "LevelsGapPage.qml")
					|| !root.nameBefore(names, "LevelsGapPage.qml", "NotificationsPage.qml")
					|| !root.nameBefore(names, "NotificationsPage.qml", "SettingsGapPage.qml")
					|| !root.nameBefore(names, "SettingsGapPage.qml", "SettingsPage.qml")) {
				return false
			}
			if (names.indexOf("LevelsPage.qml") >= 0 && !root.nameBefore(names, "LevelsGapPage.qml", "LevelsPage.qml")) {
				return false
			}
			return true
		})
	}

	function test_nav_plugin_same_location() {
		// Zeta is listed first. The same location is ordered by plugin name, then URL.
		root.checkPluginPageOrder([
			root.navPluginAt("ZetaNav", "ZetaNavPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeLevels),
			root.navPluginAt("AlphaNav", "AlphaNavPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeLevels)
		], function(names) {
			if (!root.nameBefore(names, "OverviewPage.qml", "AlphaNavPage.qml")
					|| !root.nameBefore(names, "AlphaNavPage.qml", "ZetaNavPage.qml")
					|| !root.nameBefore(names, "ZetaNavPage.qml", "NotificationsPage.qml")) {
				return false
			}
			if (names.indexOf("LevelsPage.qml") >= 0 && !root.nameBefore(names, "ZetaNavPage.qml", "LevelsPage.qml")) {
				return false
			}
			return true
		})
	}

	function test_nav_plugin_other_locations() {
		root.checkPluginPageOrder([
			root.navPluginAt("BriefGap", "BriefGapPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeBrief),
			root.navPluginAt("OverviewGap", "OverviewGapPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeOverview),
			root.navPluginAt("NotificationsGap", "NotificationsGapPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeNotifications),
			root.navPluginAt("AfterSettingsGap", "AfterSettingsGapPage.qml", GuiPluginLoader.NavigationPageLocation_AfterSettings)
		], function(names) {
			if (!root.nameBefore(names, "BoatPage.qml", "BriefGapPage.qml")
					|| !root.nameBefore(names, "BriefGapPage.qml", "BriefPage.qml")
					|| !root.nameBefore(names, "BriefPage.qml", "OverviewGapPage.qml")
					|| !root.nameBefore(names, "OverviewGapPage.qml", "OverviewPage.qml")
					|| !root.nameBefore(names, "OverviewPage.qml", "NotificationsGapPage.qml")
					|| !root.nameBefore(names, "NotificationsGapPage.qml", "NotificationsPage.qml")
					|| !root.nameBefore(names, "SettingsPage.qml", "AfterSettingsGapPage.qml")) {
				return false
			}
			if (names.indexOf("LevelsPage.qml") >= 0
					&& !root.nameBefore(names, "LevelsPage.qml", "NotificationsGapPage.qml")) {
				return false
			}
			return names[names.length - 1] === "AfterSettingsGapPage.qml"
		})
	}

	function test_nav_plugin_same_name_url_order() {
		// Same plugin name. Order is the URL, not the JSON order.
		root.checkPluginPageOrder([
			root.navPluginAt("SameNav", "ZetaSamePage.qml", GuiPluginLoader.NavigationPageLocation_BeforeLevels),
			root.navPluginAt("SameNav", "AlphaSamePage.qml", GuiPluginLoader.NavigationPageLocation_BeforeLevels)
		], function(names) {
			return root.nameBefore(names, "OverviewPage.qml", "AlphaSamePage.qml")
					&& root.nameBefore(names, "AlphaSamePage.qml", "ZetaSamePage.qml")
					&& root.nameBefore(names, "ZetaSamePage.qml", "NotificationsPage.qml")
		})
	}

	function navPage(fileName) {
		const pages = Global.mainView.navBar.pages
		for (let i = 0; i < pages.length; ++i) {
			if (root.pageName(pages[i]) === fileName) {
				return pages[i]
			}
		}
		return null
	}

	function test_nav_plugin_icon_active() {
		const plugin = root.navPluginAt("IconActive", "StartPageNavPage.qml",
				GuiPluginLoader.NavigationPageLocation_BeforeLevels)
		plugin.integrations[0].url = "qrc:/qt/qml/Victron/UiTest/tests/ui/start-page/StartPageNavPage.qml"
		plugin.integrations[0].icon = "qrc:/images/levels.svg"
		plugin.integrations[0].iconActive = "qrc:/images/overview.svg"

		addStep(UiTestStep.WaitUntil, { callable: root.ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui/ElectricPropulsionUI/Enabled", 1)
			root.clearAlarms()
			root.reloadPlugins([ plugin ])
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && !!root.navPage("StartPageNavPage.qml"),
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			const page = root.navPage("StartPageNavPage.qml")
			const icon = String(page.iconSource)
			return icon.indexOf("levels.svg") >= 0 && icon.indexOf("overview.svg") < 0
		}})
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("StartPageNavPage.qml") })
		addStep(UiTestStep.WaitUntil, {
			callable: () => String(Global.mainView.swipeView.currentItem.url).endsWith("StartPageNavPage.qml")
					&& String(root.navPage("StartPageNavPage.qml").iconSource).indexOf("overview.svg") >= 0,
			timeout: 5000
		})
		runSteps()
	}
}
