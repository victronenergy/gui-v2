/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Checks that the configured start page is still shown once every main page has loaded. The
// pages that load late at start-up (Boat, Levels and plugin nav pages) are added to the swipe view
// after the others, and a change to the page list resets the view to the first page.
//
// Each test sets the start page and rebuilds the UI. That is what a plugin reload does, and it
// goes through the same start-up path. Each test also sets everything else it depends on (the
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
		return Global.systemSettings.startPageConfiguration._jsonStringForType(type)
	}

	function notificationUid(index) {
		return BackendConnection.serviceUidForType("platform") + "/Notifications/" + index
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
			// Last, as a change of plugins rebuilds the UI.
			GuiPluginLoader.pluginsJson = JSON.stringify(params.navPlugin ? [ root.navPlugin ] : [])
			return true
		}})
		addStep(UiTestStep.WaitUntil, {
			callable: () => root.ready() && (NotificationModel.activeAlarms > 0) === params.alarm,
			timeout: 90000
		})
		addStep(UiTestStep.Invoke, { callable: () => {
			MockManager.setValue(BackendConnection.serviceUidForType("settings") + "/Settings/Gui2/StartPageName", params.startPage)
			Global.main.rebuildUi()
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
}
