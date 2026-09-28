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

	function _expectedCardsOrientation() {
		if (Theme.screenSize === Theme.Portrait) {
			return ListView.Vertical
		}
		return ListView.Horizontal
	}

	function _assertCardsList(typeName) {
		const page = findObject(Global.mainView, {}, typeName)
		if (!page || !page.flickableView) {
			throw new Error(typeName + " has no flickableView")
		}
		if (page.flickableView.orientation !== _expectedCardsOrientation()) {
			throw new Error(typeName + " list orientation does not match Theme.screenSize")
		}
		return true
	}

	function _cardsReady(typeName) {
		const loader = Global.mainView.cardsLoader
		return !Global.mainView.animating
				&& !!loader
				&& loader.viewActive
				&& !loader.animationRunning
				&& loader.status === Loader.Ready
				&& !!findObject(Global.mainView, {}, typeName)
	}

	function test_control_cards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsReady("ControlCardsPage") },
			message: "Waiting for ControlCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _assertCardsList("ControlCardsPage") },
			message: "Control cards list orientation matches Theme.screenSize",
		})
		runSteps(recursivePageCapture.start, [closeControlCards])
	}

	function closeControlCards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_switch_pane() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_smartswitch_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsReady("AuxCardsPage") },
			message: "Waiting for AuxCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _assertCardsList("AuxCardsPage") },
			message: "Switch pane list orientation matches Theme.screenSize",
		})
		runSteps(recursivePageCapture.start, [closeSwitchPane])
	}

	function closeSwitchPane() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_smartswitch_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root
	}
}
