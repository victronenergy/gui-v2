/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
	id: root

	window: Global.main

	function initTestCase() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function cleanup() {
		Global.pageManager.popAllPages()

		// No steps have been added, so call goToNextTestFunction() instead of runSteps() to
		// continue the testing.
		goToNextTestFunction()
	}

	function test_initial() {
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview" })
		runSteps()
	}

	function test_drilldown_data() {
		return [
			// Left widgets
			{
				tag: "Grid",
				widgetValues: { title: "Grid" },
				baseImageName: "overview_grid",
			},
			{
				tag: "Generator",
				widgetValues: { title: "Generator" },
				baseImageName: "overview_generator",
			},
			{
				tag: "Solar yield",
				widgetValues: { title: "Solar yield" },
				baseImageName: "overview_solar_yield",
			},
			{
				tag: "Alternator",
				widgetValues: { title: "Alternator" },
				baseImageName: "overview_alternator",
			},
			{
				tag: "Wind charger",
				widgetValues: { title: "Wind charger" },
				baseImageName: "overview_wind_charger",
			},

			// Centre widgets
			{
				tag: "Inverter/Charger",
				widgetValues: { title: "Inverter / Charger" },
				baseImageName: "overview_inverter_charger",
			},
			{
				tag: "Battery",
				widgetValues: { title: "Battery" },
				baseImageName: "overview_battery",
			},

			// Right widgets
			{
				tag: "AC Loads",
				widgetValues: { title: "AC Loads" },
				baseImageName: "overview_ac_loads",
			},
			{
				tag: "EVCS",
				widgetValues: { title: "EVCS" },
				baseImageName: "overview_evcs",
			},
			{
				tag: "Essential Loads",
				widgetValues: { title: "Essential Loads" },
				baseImageName: "overview_essential_loads",
			},
			{
				tag: "DC Loads",
				widgetValues: { title: "DC Loads" },
				baseImageName: "overview_dc_loads",
			},
		]
	}

	function test_drilldown(data) {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView.currentPage, data.widgetValues))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(recursivePageCapture.start, [data.baseImageName])
	}

	// Ideally RecursivePageCapture would handle clicking list buttons as well, so that this kind of
	// test is not necessary. However, some list buttons have side-effects when triggered (e.g.
	// quitting the app, or changing a displayed value in the parent page) so that requires some
	// more thought.
	function test_grid_dialogs() {
		// Grid (AC input) page
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView.currentPage, { title: "Grid" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_grid" })

		// Mode dialog
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView.currentPage, { text: "On" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return Global.dialogLayer.currentDialog?.opened } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_grid_mode" })
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.dialogLayer.currentDialog.footer, { text: "Cancel" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.dialogLayer.currentDialog } })

		// Current limit dialog
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView.currentPage, { text: "25.0A" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return Global.dialogLayer.currentDialog?.opened } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_grid_current_limit" })
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.dialogLayer.currentDialog.footer, { text: "Cancel" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.dialogLayer.currentDialog } })

		runSteps()
	}

	function test_solar_history() {
		// Open the "History" page of a solar tracker with history details.
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(
				findItem(Global.mainView.currentPage, { title: "Solar yield" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.Invoke, { callable: ()=> {
			// Click list item named "MPPT - multi-tracker-Tracker 1"
			const listView = findItem(Global.mainView.currentPage, {}, "GradientListView")
			return mouseClick(findClickableChild(listView.itemAtIndex(1)))
		} })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(
				findItem(Global.mainView.currentPage, { text: "History" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_today" })

		// Go to each next combo box option, and do a capture.
		let optionCapture
		for (optionCapture of ["yesterday", "7days", "14days", "31days"]) {
			addStep(UiTestStep.Invoke, { callable: ()=> {
				return findItem(Global.mainView.currentPage, {}, "ComboBox").incrementCurrentIndex() && true
			} })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_table_%1".arg(optionCapture) })
		}

		// Open "Chart" tab (for 31 days)
		addStep(UiTestStep.Invoke, { callable: ()=> {
			return findItem(Global.mainView.currentPage, {}, "TabBar").clickButton(1) && true
		} })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_chart_31days" })

		// Open chart for 14 days and 7 days
		for (optionCapture of ["14days", "7days"]) {
			addStep(UiTestStep.Invoke, { callable: ()=> {
				return findItem(Global.mainView.currentPage, {}, "ComboBox").decrementCurrentIndex() && true
			} })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_chart_%1".arg(optionCapture) })
		}

		// In "7 days" chart, open the history details dialog for the last day (day 6), then click
		// the left arrow icon to go back all the way to the first day (day 0).
		addStep(UiTestStep.Invoke, { callable: ()=> {
			return findItem(Global.mainView.currentPage, {}, "SolarHistoryChart").openHistoryForDay(6)
		} })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return Global.dialogLayer.currentDialog?.opened } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_chart_7days_day6" })
		for (let day = 5; day >= 0; day--) {
			addStep(UiTestStep.Invoke, { callable: ()=> {
				return mouseClick(findItem(Global.dialogLayer.currentDialog.background, {}, "ArrowButton"))
			} })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_chart_7days_day%1".arg(day) })
		}

		// Open the error view for day 0.
		addStep(UiTestStep.Invoke, { callable: ()=> {
			const errorView = findItem(Global.dialogLayer.currentDialog.contentItem, {}, "SolarHistoryErrorView")
			errorView.expanded = true
			return true
		} })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_chart_7days_day0_errors" })

		// Close the history details dialog.
		addStep(UiTestStep.Invoke, { callable: ()=> {
			return mouseClick(findItem(Global.dialogLayer.currentDialog.contentItem, {}, "CloseButton"))
		} })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview_solar_history_dialog_closed" })

		runSteps()
	}

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root
	}
}
