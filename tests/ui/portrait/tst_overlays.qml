/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Requires a portrait window, e.g.:
//   venus-gui-v2 --mock --resolution 480x800 --ui-test portrait
UiTestCase {
	id: root

	window: Global.main

	function _requirePortrait() {
		if (Theme.screenSize === Theme.Portrait) {
			return true
		}
		addStep(UiTestStep.Abort, {
			passed: false,
			message: "Requires Theme.Portrait; launch with --resolution 480x800",
		})
		runSteps()
		return false
	}

	function _statusBarIcon(fileName) {
		return findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/" + fileName) })
	}

	function _clickStatusBarIcon(fileName) {
		const icon = _statusBarIcon(fileName)
		if (!icon) {
			throw new Error("StatusBar icon not found: " + fileName)
		}
		return mouseClick(findClickableParent(icon))
	}

	function _typeIsShown(typeName) {
		const obj = findObject(Global.mainView, {}, typeName)
		return !!obj && obj.visible !== false
	}

	function _cardsIdleAndShown() {
		const loader = Global.mainView.cardsLoader
		return !Global.mainView.animating
			&& loader.viewActive
			&& !loader.animationRunning
			&& loader.status === Loader.Ready
	}

	function _cardsClosed() {
		const loader = Global.mainView.cardsLoader
		return !Global.mainView.cardsActive
			&& !loader.animationRunning
			&& !Global.mainView.animating
	}

	function initTestCase() {
		if (!_requirePortrait()) {
			return
		}
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Brief" }))) },
			message: "Open Brief",
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_brief_side_panel() {
		if (!_requirePortrait()) {
			return
		}
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _typeIsShown("BriefPage_Portrait") && _typeIsShown("BriefSidePanel") },
			message: "Waiting for inline BriefSidePanel",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				if (_statusBarIcon("icon_sidepanel_off_32.svg") || _statusBarIcon("icon_sidepanel_on_32.svg")) {
					throw new Error("Portrait Brief must not show a StatusBar side-panel button")
				}
				return true
			},
			message: "Portrait BriefSidePanel is inline; no StatusBar side-panel icon",
		})
		runSteps()
	}

	function test_control_cards() {
		if (!_requirePortrait()) {
			return
		}
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_controls_off_32.svg") },
			message: "Open control cards",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsIdleAndShown() && _typeIsShown("ControlCardsPage") },
			message: "Waiting for ControlCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const page = findObject(Global.mainView, {}, "ControlCardsPage")
				if (!page?.flickableView) {
					throw new Error("ControlCardsPage has no flickableView")
				}
				if (page.flickableView.orientation !== ListView.Vertical) {
					throw new Error("Portrait ControlCardsPage must use a vertical list")
				}
				return true
			},
			message: "Control cards use a vertical list in portrait",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_controls_on_32.svg") },
			message: "Close control cards",
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		runSteps()
	}

	function test_switch_pane() {
		if (!_requirePortrait()) {
			return
		}
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_smartswitch_off_32.svg") },
			message: "Open switch pane",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsIdleAndShown() && _typeIsShown("AuxCardsPage") },
			message: "Waiting for AuxCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const page = findObject(Global.mainView, {}, "AuxCardsPage")
				if (!page?.flickableView) {
					throw new Error("AuxCardsPage has no flickableView")
				}
				if (page.flickableView.orientation !== ListView.Vertical) {
					throw new Error("Portrait AuxCardsPage must use a vertical list")
				}
				return true
			},
			message: "Switch pane uses a vertical list in portrait",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_smartswitch_on_32.svg") },
			message: "Close switch pane",
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		runSteps()
	}
}
