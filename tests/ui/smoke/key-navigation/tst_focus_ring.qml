/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

// Captures the key navigation focus ring on a navigation bar button and on a settings list item,
// so that its color can be checked, for example with a branding plugin installed.
UiTestCase {
	id: root

	window: Global.main

	// Turns on key navigation, as pressing an arrow key does, and gives the key-navigable item
	// that contains item the focus, so that the focus ring is drawn around it.
	function focusItem(item) {
		while (item && !(item.focusPolicy & Qt.TabFocus)) {
			item = item.parent
		}
		if (!item) {
			throw new Error("No key-navigable item to focus")
		}
		Global.keyNavigationEnabled = true
		item.forceActiveFocus()
		return item.activeFocus
	}

	function test_focusRing() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView.navBar, { text: "Settings" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.Invoke, { callable: ()=> { return focusItem(findClickableChild(findItem(Global.mainView.navBar, { text: "Settings" }))) } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "focus_ring_nav_bar_button" })
		// Use the first list item: when the list first gets the focus, it moves the focus to its
		// first item, as when the user navigates into the page.
		addStep(UiTestStep.Invoke, { callable: ()=> { return focusItem(findItem(Global.mainView.currentPage, { text: "Devices" })) } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "focus_ring_settings_list_item" })
		runSteps()
	}
}
