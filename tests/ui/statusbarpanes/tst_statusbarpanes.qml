/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Status bar pane buttons added, ordered, enabled and removed by other features.
UiTestCase {
	id: root

	property StatusBarPane paneA
	property StatusBarPane paneB
	property var closedX: ({})

	window: Global.main

	function capture(name) {
		addStep(UiTestStep.CaptureAndCompare, { imageName: name })
	}

	function waitForAnimations() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
	}

	function button(iconSource) {
		const icon = findItem(Global.mainView.statusBar, { "source": Qt.url(iconSource) })
		return icon ? findClickableParent(icon) : null
	}

	function shown(iconSource) {
		const item = button(iconSource)
		return !!item && item.visible
	}

	function click(iconSource) {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(button(iconSource)) } })
		waitForAnimations()
	}

	function paneIds() {
		const ids = []
		for (let i = 0; i < Global.statusBarPanes.count; ++i) {
			ids.push(Global.statusBarPanes.get(i).pane.paneId)
		}
		return ids.join(",")
	}

	function iconX(iconSource) {
		const icon = findItem(Global.mainView.statusBar, { "source": Qt.url(iconSource) })
		return icon ? icon.mapToItem(null, 0, 0).x : NaN
	}

	// Records where the buttons are while no cards view is open.
	function recordClosedPositions() {
		addStep(UiTestStep.Invoke, { callable: ()=> {
			closedX = {
				controls: iconX("qrc:/images/icon_controls_off_32.svg"),
				switches: iconX("qrc:/images/icon_smartswitch_off_32.svg"),
				a: iconX("qrc:/images/icon_integration_32.svg"),
				b: iconX("qrc:/images/icon_vrm_32.svg"),
			}
			return true
		} })
	}

	// Checks, once the screen has settled, that a button has not moved since no cards view was open.
	function checkInPlace(name, iconSource, closedKey) {
		capture(name)
		addStep(UiTestStep.Invoke, { callable: ()=> {
			const x = iconX(iconSource)
			if (x !== closedX[closedKey]) {
				console.warn(name + ": button moved from", closedX[closedKey], "to", x)
				return false
			}
			return true
		} })
	}

	// Opening Control Cards or a pane does not move the button that closes it, and blanks the
	// pane buttons other than the one that closes it.
	function checkCardsOpenedInPlace(prefix) {
		recordClosedPositions()
		click("qrc:/images/icon_controls_off_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return Global.mainView.cardsActive
				&& shown("qrc:/images/icon_controls_on_32.svg")
				&& !shown("qrc:/images/icon_smartswitch_off_32.svg")
				&& !shown("qrc:/images/icon_integration_32.svg")
				&& !shown("qrc:/images/icon_vrm_32.svg")
		} })
		checkInPlace(prefix + "controls-opened", "qrc:/images/icon_controls_on_32.svg", "controls")
		click("qrc:/images/icon_controls_on_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.cardsActive && shown("qrc:/images/icon_vrm_32.svg")
		} })

		click("qrc:/images/icon_integration_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return paneA.opened && Global.mainView.currentPage.title === "Example A"
				&& shown("qrc:/images/icon_open_link_32.svg")
				&& !shown("qrc:/images/icon_vrm_32.svg")
				&& !shown("qrc:/images/icon_smartswitch_off_32.svg")
		} })
		checkInPlace(prefix + "pane-a-opened", "qrc:/images/icon_open_link_32.svg", "a")
		click("qrc:/images/icon_open_link_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !paneA.opened && !Global.mainView.cardsActive && shown("qrc:/images/icon_vrm_32.svg")
		} })

		click("qrc:/images/icon_vrm_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return paneB.opened && Global.mainView.currentPage.title === "Example B"
				&& shown("qrc:/images/icon_close_32.svg")
				&& !shown("qrc:/images/icon_integration_32.svg")
		} })
		checkInPlace(prefix + "pane-b-opened", "qrc:/images/icon_close_32.svg", "b")
		click("qrc:/images/icon_close_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !paneB.opened && !Global.mainView.cardsActive && shown("qrc:/images/icon_integration_32.svg")
		} })

		// The built-in switch pane is a pane like any other.
		click("qrc:/images/icon_smartswitch_off_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return Global.statusBarPanes.findPane("switches").opened && !paneA.opened
				&& shown("qrc:/images/icon_smartswitch_on_32.svg")
				&& !shown("qrc:/images/icon_integration_32.svg")
		} })
		checkInPlace(prefix + "switches-opened", "qrc:/images/icon_smartswitch_on_32.svg", "switches")
		click("qrc:/images/icon_smartswitch_on_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.cardsActive && shown("qrc:/images/icon_integration_32.svg")
		} })
	}

	function test_status_bar_panes() {
		// Panes are ordered by 'order', whatever order they are added in.
		addStep(UiTestStep.Invoke, { callable: ()=> {
			paneB = examplePaneB.createObject(root)
			paneA = examplePaneA.createObject(root)
			return paneIds() === "switches,example-a,example-b"
		} })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return shown("qrc:/images/icon_integration_32.svg") && shown("qrc:/images/icon_vrm_32.svg")
		} })
		addStep(UiTestStep.Invoke, { callable: ()=> {
			const switches = button("qrc:/images/icon_smartswitch_off_32.svg").mapToItem(null, 0, 0).x
			const a = button("qrc:/images/icon_integration_32.svg").mapToItem(null, 0, 0).x
			const b = button("qrc:/images/icon_vrm_32.svg").mapToItem(null, 0, 0).x
			return switches < a && a < b
		} })
		capture("panes-closed")
		checkCardsOpenedInPlace("")

		// An unavailable pane has no button.
		addStep(UiTestStep.Invoke, { callable: ()=> { paneA.available = false; return true } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !shown("qrc:/images/icon_integration_32.svg") && shown("qrc:/images/icon_vrm_32.svg")
		} })
		capture("pane-a-unavailable")
		addStep(UiTestStep.Invoke, { callable: ()=> { paneA.available = true; return true } })

		// A second pane with the same id is ignored, and destroying it leaves the first in place.
		addStep(UiTestStep.Invoke, { callable: ()=> {
			const duplicate = examplePaneA.createObject(root)
			const ignored = paneIds() === "switches,example-a,example-b"
			duplicate.destroy()
			return ignored
		} })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return paneIds() === "switches,example-a,example-b" } })

		// Portrait shows the same buttons, in the same order.
		addStep(UiTestStep.Invoke, { callable: ()=> { Global.main.width = 480; Global.main.height = 800; return true } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return Theme.screenSize === Theme.Portrait
				&& shown("qrc:/images/icon_integration_32.svg") && shown("qrc:/images/icon_vrm_32.svg")
		} })
		addStep(UiTestStep.Invoke, { callable: ()=> {
			const a = button("qrc:/images/icon_integration_32.svg").mapToItem(null, 0, 0).x
			const b = button("qrc:/images/icon_vrm_32.svg").mapToItem(null, 0, 0).x
			return a < b
		} })
		capture("portrait-panes")
		checkCardsOpenedInPlace("portrait-")

		// Destroying a pane removes its button.
		addStep(UiTestStep.Invoke, { callable: ()=> { paneB.destroy(); return true } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return paneIds() === "switches,example-a" && !button("qrc:/images/icon_vrm_32.svg")
		} })

		// Destroying an open pane closes it.
		click("qrc:/images/icon_integration_32.svg")
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return paneA.opened } })
		addStep(UiTestStep.Invoke, { callable: ()=> { paneA.destroy(); return true } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return paneIds() === "switches" && !Global.mainView.cardsActive
		} })
		waitForAnimations()
		capture("portrait-open-pane-destroyed")
		runSteps()
	}

	// Example: another feature adds a status bar button that opens its own pane.
	Component {
		id: examplePaneA

		StatusBarPane {
			paneId: "example-a"
			order: 200
			iconSource: "qrc:/images/icon_integration_32.svg"
			activeIconSource: "qrc:/images/icon_open_link_32.svg"
			paneComponent: Component {
				Page {
					title: "Example A"
				}
			}
		}
	}

	Component {
		id: examplePaneB

		StatusBarPane {
			paneId: "example-b"
			order: 300
			iconSource: "qrc:/images/icon_vrm_32.svg"
			activeIconSource: "qrc:/images/icon_close_32.svg"
			paneComponent: Component {
				Page {
					title: "Example B"
				}
			}
		}
	}
}
