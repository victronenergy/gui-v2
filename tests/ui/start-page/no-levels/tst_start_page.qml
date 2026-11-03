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

	function test_only_nav_plugin_late() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Notifications),
				navPlugin: true, boatPage: false, alarm: false, expectedPage: "NotificationsPage.qml" })
	}

	function test_only_nav_plugin_late_active_alarm() {
		checkStartPage({ startPage: startPageConfig(VenusOS.StartPage_Type_Overview),
				navPlugin: true, boatPage: false, alarm: true, expectedPage: "NotificationsPage.qml" })
	}
}
