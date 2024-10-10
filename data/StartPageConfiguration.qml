/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemSettingsUid
	readonly property bool hasStartPage: _startPage.isValid && _startPage.value !== VenusOS.StartPage_Type_Auto
	readonly property bool needsAutoConfigure: _startPage.value === VenusOS.StartPage_Type_Auto
	readonly property int startPageTimeout: _startPageTimeout.value || 0     // in seconds
	readonly property int autoConfigureTimeout: 60 // in seconds

	readonly property var options: [
		{
			display: CommonWords.auto,
			value: VenusOS.StartPage_Type_Auto,
			//% "After one minute of inactivity, if the current page is in this list, then use it as the start page."
			caption: qsTrId("startpage_option_auto_caption"),
		},
		{
			//: The 'Brief' page
			//% "Brief"
			display: qsTrId("startpage_option_brief_without_panel"),
			value: VenusOS.StartPage_Type_Brief_SidePanelClosed,
		},
		{
			//: The 'Brief' page, with the side panel opened
			//% "Brief (side panel open)"
			display: qsTrId("startpage_option_brief_with_panel"),
			value: VenusOS.StartPage_Type_Brief_SidePanelOpened,
		},
		{
			//: The 'Overview' page
			//% "Overview"
			display: qsTrId("startpage_option_overview"),
			value: VenusOS.StartPage_Type_Overview,
		},
		{
			//: The 'Levels' page, with the "Tanks" section opened
			//% "Levels (Tanks)"
			display: qsTrId("startpage_option_levels_tanks"),
			value: VenusOS.StartPage_Type_Levels_Tanks,
		},
		{
			//: The 'Levels' page, with the "Environment" section opened
			//% "Levels (Environment)"
			display: qsTrId("startpage_option_levels_environment"),
			value: VenusOS.StartPage_Type_Levels_Environment,
		},
		{
			//% "Battery list"
			display: qsTrId("startpage_option_battery list"),
			value: VenusOS.StartPage_Type_BatteryList,
		},
	]

	function loadStartPage(swipeView, stackPageUrls) {
		if (!hasStartPage) {
			return
		}
		switch (_startPage.value) {
		case VenusOS.StartPage_Type_Auto:
			break
		case VenusOS.StartPage_Type_Brief_SidePanelClosed:
		case VenusOS.StartPage_Type_Brief_SidePanelOpened:
			if (Global.pageManager.navBar.setCurrentPage("BriefPage.qml")) {
				swipeView.getCurrentPage().showSidePanel = _startPage.value === VenusOS.StartPage_Type_Brief_SidePanelOpened
			}
			break
		case VenusOS.StartPage_Type_Overview:
			Global.pageManager.navBar.setCurrentPage("OverviewPage.qml")
			break
		case VenusOS.StartPage_Type_Levels_Tanks:
		case VenusOS.StartPage_Type_Levels_Environment:
			if (Global.pageManager.navBar.setCurrentPage("LevelsPage.qml")) {
				swipeView.getCurrentPage().currentTabIndex = _startPage.value === VenusOS.StartPage_Type_Levels_Tanks ? 0 : 1
			}
			break
		case VenusOS.StartPage_Type_BatteryList:
			if (Global.pageManager.navBar.setCurrentPage("OverviewPage.qml")
					&& (stackPageUrls.length === 0 || !stackPageUrls[stackPageUrls.length - 1].endsWith("/BatteryListPage.qml"))) {
				Global.pageManager.popAllPages(PageStack.Immediate)
				Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml", {}, PageStack.Immediate)
			}
			break
		default:
			console.warn("Unsupported start page:", _startPage.value)
		}
	}

	function autoConfigure(mainPageName, mainPage, stackPageUrls) {
		if (!needsAutoConfigure) {
			return
		}
		if (!mainPageName || !mainPage) {
			console.warn("autoConfigure() failed: mainPageName or mainPage not set")
			return
		}
		switch (mainPageName) {
		case "BriefPage.qml":
			if (stackPageUrls.length === 0) {
				if (mainPage.showSidePanel === undefined) {
					console.warn("Error: BriefPage does not have showSidePanel property!")
				} else {
					_startPage.setValue(mainPage.showSidePanel
							? VenusOS.StartPage_Type_Brief_SidePanelOpened
							: VenusOS.StartPage_Type_Brief_SidePanelClosed)
				}
			}
			break
		case "OverviewPage.qml":
			if (stackPageUrls.length === 0) {
				_startPage.setValue(VenusOS.StartPage_Type_Overview)
			} else if (stackPageUrls[stackPageUrls.length - 1].endsWith("/BatteryListPage.qml")) {
				_startPage.setValue(VenusOS.StartPage_Type_BatteryList)
			}
			break
		case "LevelsPage.qml":
			if (stackPageUrls.length === 0) {
				if (mainPage.currentTabIndex === undefined) {
					console.warn("Error: LevelsPage does not have currentTabIndex property!")
				} else {
					_startPage.setValue(mainPage.currentTabIndex === 0
							? VenusOS.StartPage_Type_Levels_Tanks
							: VenusOS.StartPage_Type_Levels_Environment)
				}
			}
			break
		}
	}

	readonly property VeQuickItem _startPage: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/Gui2/StartPage"
	}

	readonly property VeQuickItem _startPageTimeout: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/Gui2/StartPageTimeout"
	}
}
