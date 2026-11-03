/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Start page tests with a Levels page (the mock configuration has tanks). See StartPageTestCase.
StartPageTestCase {
	hasLevelsPage: true

	function test_notifications() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Notifications),
				navPlugin: false, boatPage: true, alarm: false, expectedPage: "NotificationsPage.qml" })
	}

	function test_levels() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Levels_Tanks),
				navPlugin: false, boatPage: true, alarm: false, expectedPage: "LevelsPage.qml" })
	}

	function test_levels_nav_plugin() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Levels_Tanks),
				navPlugin: true, boatPage: true, alarm: false, expectedPage: "LevelsPage.qml" })
	}

	function test_notifications_nav_plugin() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Notifications),
				navPlugin: true, boatPage: true, alarm: false, expectedPage: "NotificationsPage.qml" })
	}

	function test_nav_plugin_page() {
		checkStartPage({ startPage: JSON.stringify({ main: { page: "StartPageNavPage.qml", properties: {} }, stack: [] }),
				navPlugin: true, boatPage: true, alarm: false, expectedPage: "StartPageNavPage.qml" })
	}

	// The configured start page is not a real page. After it fails to load,
	// the navbar must show Brief, not call goToStartPage() again.
	function test_missing_start_page_falls_back_to_brief() {
		const plugin = navPluginAt("MissingStart", "MissingStartPage.qml",
				GuiPluginLoader.NavigationPageLocation_BeforeLevels)
		addStep(UiTestStep.WaitUntil, { callable: ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui/ElectricPropulsionUI/Enabled", 0)
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui2/StartPageName",
					JSON.stringify({ main: { page: "MissingStartPage.qml", properties: {} }, stack: [] }))
			clearAlarms()
			reloadPlugins([ plugin ])
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => ready()
					&& pageNames().indexOf("MissingStartPage.qml") < 0
					&& pageName(Global.mainView.swipeView.currentItem) === "BriefPage.qml"
					&& pageName(Global.mainView.navBar.pages[Global.mainView.navBar.currentIndex]) === "BriefPage.qml",
			timeout: 90000
		})
		runSteps()
	}

	function test_stack_page() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_DeviceList),
				navPlugin: true, boatPage: true, alarm: false, expectedPage: "SettingsPage.qml",
				expectedStackPage: "DeviceListPage.qml" })
	}

	// With an active alarm, start-up shows the Notifications page instead of the start page.
	function test_active_alarm() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Overview),
				navPlugin: true, boatPage: true, alarm: true, expectedPage: "NotificationsPage.qml" })
	}
}
