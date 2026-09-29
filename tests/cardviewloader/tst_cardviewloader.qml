/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "CardViewLoaderTest"
	when: windowShown

	Item {
		id: dummyBar
		width: 10
		height: 10
	}

	CardViewLoader {
		id: cards
		statusBarItem: dummyBar
		navBarItem: dummyBar
		swipeViewItem: dummyBar
		animationEnabled: false
	}

	Component {
		id: neverReadyPage
		Item {
			property alias flickableView: view
			ListView {
				id: view
				// Zero viewport so delegates are not created; count stays > 0
				// so _checkContentReady() remains false.
				width: 0
				height: 0
				model: 3
				delegate: Item {
					width: 1
					height: 1
				}
			}
		}
	}

	Component {
		id: emptyPage
		Item {}
	}

	function cleanup() {
		cards.hide()
		tryCompare(cards, "viewActive", false)
		// First-load cancel must drop the Loader so the next show() starts clean.
		if (cards.incubating || cards.active) {
			cards.active = false
		}
		tryCompare(cards, "incubating", false)
	}

	function test_timeoutDoesNotMarkUnreadyContentReady() {
		cards.show(neverReadyPage)
		tryCompare(cards, "status", Loader.Ready)
		verify(cards.viewActive)
		verify(cards.incubating)
		// Former timeout was 60 * 16ms and treated that as success even when
		// _checkContentReady() was still false.
		wait(1200)
		compare(cards.status, Loader.Ready)
		verify(cards.viewActive)
		verify(cards.incubating)
		verify(!cards.shown)
	}

	function test_emptyPageBecomesReady() {
		cards.show(emptyPage)
		tryCompare(cards, "shown", true)
		verify(!cards.incubating)
	}
}
