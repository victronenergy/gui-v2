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
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Brief" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_initial() {
		addStep(UiTestStep.CaptureAndCompare, { imageName: "brief" })
		runSteps()
	}

	function test_sidePanel() {
		if (Theme.screenSize === Theme.Portrait) {
			// Portrait loads BriefSidePanel with the page. There is no
			// StatusBar button to open or close it.
			addStep(UiTestStep.WaitUntil, {
				callable: ()=> {
					const page = root.findObject(Global.mainView, {}, "BriefPage_Portrait")
					const panel = root.findObject(Global.mainView, {}, "BriefSidePanel")
					return !!page && page.visible !== false && !!panel && panel.visible !== false
				},
				message: "Waiting for inline BriefSidePanel",
			})
			addStep(UiTestStep.Invoke, {
				callable: ()=> {
					if (findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_off_32.svg") })
							|| findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_on_32.svg") })) {
						throw new Error("Portrait Brief must not show a StatusBar side-panel button")
					}
					return true
				},
				message: "Portrait BriefSidePanel is inline; no StatusBar side-panel icon",
			})
			runSteps()
			return
		}

		// Open side panel
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return root.findObject(Global.mainView.currentPage, {}, "BriefPage_Landscape")?.state === "panelOpened" } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "sidePanel_opened" })

		// Close side panel
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return root.findObject(Global.mainView.currentPage, {}, "BriefPage_Landscape")?.state === "initialized" } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "sidePanel_closed" })

		runSteps()
	}
}
