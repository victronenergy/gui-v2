/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginCardTest"
	when: windowShown

	Component {
		id: plainCard

		PluginCard {
			focus: false
		}
	}

	Component {
		id: filledCard

		PluginCard {
			focus: false
			title: "Pump"
			status: "Off"
			iconSource: PluginIcons.battery

			Rectangle {
				objectName: "extra"
				width: 4
				height: 4
			}
		}
	}

	Component {
		id: tallCard

		PluginCard {
			focus: false

			Rectangle {
				width: 10
				height: 800
			}
		}
	}

	Component {
		id: cardWithFocusedContent

		PluginCard {
			focus: false

			Item {
				objectName: "focusedContent"
				width: 4
				height: 4
				focus: true
			}
		}
	}

	function findNamed(item, objectName) {
		if (item.objectName === objectName) {
			return item
		}
		for (let i = 0; i < item.children.length; ++i) {
			const found = findNamed(item.children[i], objectName)
			if (found) {
				return found
			}
		}
		return null
	}

	function test_propertiesRoundTrip() {
		const card = createTemporaryObject(plainCard, root)
		verify(card !== null)

		card.title = "Pump"
		card.status = "Off"
		card.iconSource = PluginIcons.battery

		compare(card.title, "Pump")
		compare(card.status, "Off")
		compare(typeof card.title, "string")
		compare(typeof card.status, "string")
		compare(card.iconSource.toString(), PluginIcons.battery.toString())
		compare(card.implicitWidth, Theme.geometry_controlCard_maximumWidth)
		compare(card.implicitHeight, Theme.geometry_controlCard_height)
		compare(card.width, card.implicitWidth)
		compare(card.height, card.implicitHeight)
	}

	function test_contentIsPlacedInsideTheCard() {
		const card = createTemporaryObject(filledCard, root)
		verify(card !== null)

		const extra = findNamed(card, "extra")
		verify(extra !== null)
		verify(extra.parent !== null)
		verify(extra.parent !== card)
		// The rectangle is the first item in the content column, so its own y is 0.
		// The column sits below the title and status, inset by the card's content margin.
		compare(extra.y, 0)
		verify(extra.parent.y > 0, "content y was " + extra.parent.y)
		compare(extra.parent.x, Theme.geometry_controlCard_contentMargins)
	}

	function test_growsToFitContent() {
		const plain = createTemporaryObject(plainCard, root)
		const tall = createTemporaryObject(tallCard, root)
		verify(plain !== null)
		verify(tall !== null)
		verify(tall.implicitHeight > plain.implicitHeight)
		verify(tall.height > Theme.geometry_controlCard_height)
	}

	function test_emptyStatusStillHasASize() {
		const card = createTemporaryObject(filledCard, root, { status: "" })
		verify(card !== null)
		compare(card.status, "")
		verify(card.implicitWidth > 0)
		verify(card.implicitHeight > 0)
	}

	function test_cardWithTheKeyFocusShowsTheHighlight() {
		const card = createTemporaryObject(filledCard, root)
		verify(card !== null)
		verify(!card.KeyNavigationHighlight.active)

		card.forceActiveFocus()
		tryCompare(card, "activeFocus", true)
		compare(card.Window.activeFocusItem, card)
		verify(card.KeyNavigationHighlight.active)
	}

	function test_keyFocusGoesToContentWithFocus() {
		const card = createTemporaryObject(cardWithFocusedContent, root)
		verify(card !== null)
		const content = findNamed(card, "focusedContent")
		verify(content !== null)

		card.forceActiveFocus()
		tryCompare(content, "activeFocus", true)
		compare(card.Window.activeFocusItem, content)
		// The card has activeFocus too, because the content is inside it, but it is not highlighted.
		verify(card.activeFocus)
		verify(!card.KeyNavigationHighlight.active)
	}
}
