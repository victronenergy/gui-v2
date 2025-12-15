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
			{
				tag: "Grid",
				widgetValues: { title: "Grid" },
				baseImageName: "overview_grid",
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

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root
	}

}
