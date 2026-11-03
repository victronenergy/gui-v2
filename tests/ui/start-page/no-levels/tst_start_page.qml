/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Start page tests without a Levels page, so that each other late page can be the only one.
// See StartPageTestCase.
StartPageTestCase {
	hasLevelsPage: false

	// The Boat page is not always still loading when the other pages are ready, so a single run
	// can miss a regression. Repeat the check.
	function test_only_boat_late_data() {
		return [ { tag: "1" }, { tag: "2" }, { tag: "3" }, { tag: "4" } ]
	}

	function test_only_boat_late(data) {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Notifications),
				navPlugin: false, boatPage: true, alarm: false, expectedPage: "NotificationsPage.qml" })
	}

	// No start page is set, and a nav plugin page is first. Plugin pages are inserted after the
	// other pages, so this one is inserted before the page that the view is showing, and the nav bar
	// index does not change. The view must show the same page as the nav bar. A nav page that fails
	// to load must then return to that page, not to Brief.
	function test_first_page_inserted_late() {
		const first = navPluginAt("FirstNav", "StartPageNavPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeBrief)
		first.integrations[0].url = "qrc:/qt/qml/Victron/UiTest/tests/ui/start-page/StartPageNavPage.qml"
		const failing = navPluginAt("FailingNav", "FailingNavPage.qml", GuiPluginLoader.NavigationPageLocation_BeforeSettings)
		const showsFirstPage = () => {
			const navBar = Global.mainView.navBar
			const currentPage = pageName(Global.mainView.swipeView.currentItem)
			const navPage = pageName(navBar.pages[navBar.currentIndex])
			console.warn("FIRST PAGE view:", currentPage, "| nav:", navPage, "| pages:", pageNames().join(","))
			return currentPage === "StartPageNavPage.qml" && navPage === "StartPageNavPage.qml"
		}

		addStep(UiTestStep.WaitUntil, { callable: ready, timeout: 90000 })
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui/ElectricPropulsionUI/Enabled", 0)
			MockManager.removeServices("tank")
			MockManager.removeServices("temperature")
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui2/StartPageName", "")
			clearAlarms()
			reloadPlugins([ first, failing ])
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => ready() && pageNames()[0] === "StartPageNavPage.qml"
					&& pageNames().indexOf("FailingNavPage.qml") >= 0,
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: showsFirstPage })
		addStep(UiTestStep.Invoke, { callable: () => Global.mainView.navBar.setCurrentPage("FailingNavPage.qml") })
		addStep(UiTestStep.WaitUntil, {
			callable: () => ready() && pageNames().indexOf("FailingNavPage.qml") < 0,
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: showsFirstPage })
		runSteps()
	}

	function test_only_nav_plugin_late() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Notifications),
				navPlugin: true, boatPage: false, alarm: false, expectedPage: "NotificationsPage.qml" })
	}

	function test_only_nav_plugin_late_active_alarm() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Overview),
				navPlugin: true, boatPage: false, alarm: true, expectedPage: "NotificationsPage.qml" })
	}
}
