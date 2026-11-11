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
	// TestCase is invisible, so a child cannot take active focus. The key tests need that.
	visible: true
	width: 600
	height: 800

	Component {
		id: plainCard

		PluginCard {
			focus: false
		}
	}

	Component {
		id: filledCard

		PluginCard {
			id: filled

			focus: false
			title: "Pump"
			status: "Off"
			iconSource: PluginIcons.battery

			Rectangle {
				objectName: "extra"
				width: 4
				height: 4
			}

			PluginLabel {
				objectName: "inset"
				x: filled.contentMargin
				text: "Inset"
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
		id: cardInHostComponent

		// Counts the Up and Down keys that reach it from the card.
		Item {
			id: host

			property int upPresses
			property int downPresses
			property alias card: card
			property alias pumpSwitch: pumpSwitch
			property alias resetButton: resetButton
			property alias speedSlider: speedSlider

			width: 600
			height: 800
			Keys.onUpPressed: host.upPresses += 1
			Keys.onDownPressed: host.downPresses += 1

			PluginCard {
				id: card

				focus: false
				title: "Pump"

				PluginListSwitch {
					id: pumpSwitch

					flat: true
					text: "Pump"
					checkable: true
					writeAccessLevel: PluginAccessLevel.User
				}
				PluginLabel {
					text: "Speed"
				}
				PluginButton {
					id: resetButton

					text: "Reset"
				}
				PluginListSlider {
					id: speedSlider

					flat: true
					text: "Speed"
					to: 100
				}
			}
		}
	}

	function initTestCase() {
		// Unit tests do not load a mock configuration, so the access level is unset and
		// canAccess() is false, which hides the list items. User is enough to show them.
		MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel",
				VenusOS.User_AccessType_User)
		tryVerify(function() {
			return !!Services.settings
					&& Services.settings.canAccess(VenusOS.User_AccessType_User)
		}, 20000)
	}

	function init() {
		Global.keyNavigationEnabled = false
	}

	function cleanup() {
		Global.keyNavigationEnabled = false
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

	// The gui-v2 list item that a Plugin* list item wraps.
	function innerListItem(pluginListItem) {
		for (let i = 0; i < pluginListItem.children.length; ++i) {
			const child = pluginListItem.children[i]
			if (child.flat !== undefined) {
				return child
			}
		}
		return null
	}

	function createHost() {
		const host = createTemporaryObject(cardInHostComponent, root)
		verify(host !== null)
		tryVerify(function() {
			return host.pumpSwitch.visible && host.speedSlider.visible
					&& host.pumpSwitch.height > 0 && host.speedSlider.height > 0
		})
		return host
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
		// The column sits below the title and status, and is as wide as the card.
		compare(extra.y, 0)
		const position = extra.mapToItem(card, 0, 0)
		verify(position.y > 0, "content y was " + position.y)
		compare(position.x, 0)
	}

	function findText(item, text) {
		if (item.text === text) {
			return item
		}
		for (let i = 0; i < item.children.length; ++i) {
			const found = findText(item.children[i], text)
			if (found) {
				return found
			}
		}
		return null
	}

	function test_contentMarginLinesUpContentWithTheStatus() {
		const card = createTemporaryObject(filledCard, root)
		verify(card !== null)
		verify(card.contentMargin > 0)
		const inset = findNamed(card, "inset")
		const status = findText(card, "Off")
		verify(inset !== null)
		verify(status !== null)
		compare(inset.mapToItem(card, 0, 0).x, status.mapToItem(card, 0, 0).x)
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

	function test_flatListItemsSpanTheCard() {
		const host = createHost()
		const items = [ host.pumpSwitch, host.speedSlider ]
		for (let i = 0; i < items.length; ++i) {
			const inner = innerListItem(items[i])
			verify(inner !== null)
			compare(inner.flat, true)
			compare(inner.mapToItem(host.card, 0, 0).x, 0)
			compare(inner.width, host.card.width)
		}
	}

	function test_cardWithoutFocusableContentShowsTheHighlight() {
		Global.keyNavigationEnabled = true
		const card = createTemporaryObject(filledCard, root)
		verify(card !== null)
		verify(!card.KeyNavigationHighlight.active)

		card.forceActiveFocus()
		tryCompare(card, "activeFocus", true)
		verify(card.KeyNavigationHighlight.active)
	}

	function test_upAndDownMoveTheKeyFocusBetweenTheControls() {
		Global.keyNavigationEnabled = true
		const host = createHost()

		// The first control inside the card takes the key focus, and the card is not highlighted.
		host.card.forceActiveFocus()
		tryCompare(host.pumpSwitch, "activeFocus", true)
		verify(!host.card.KeyNavigationHighlight.active)

		// The label cannot take the key focus, so Down moves past it to the button.
		keyClick(Qt.Key_Down)
		tryCompare(host.resetButton, "activeFocus", true)
		keyClick(Qt.Key_Down)
		tryCompare(host.speedSlider, "activeFocus", true)
		keyClick(Qt.Key_Up)
		tryCompare(host.resetButton, "activeFocus", true)
		keyClick(Qt.Key_Up)
		tryCompare(host.pumpSwitch, "activeFocus", true)
		verify(!host.card.KeyNavigationHighlight.active)

		// The key reaches the focused control.
		keyClick(Qt.Key_Space)
		compare(host.pumpSwitch.checked, true)

		compare(host.upPresses, 0)
		compare(host.downPresses, 0)
	}

	function test_keysPastEitherEndGoToTheItemThatHoldsTheCard() {
		Global.keyNavigationEnabled = true
		const host = createHost()

		host.card.forceActiveFocus()
		tryCompare(host.pumpSwitch, "activeFocus", true)
		keyClick(Qt.Key_Up)
		compare(host.upPresses, 1)
		verify(host.pumpSwitch.activeFocus)

		keyClick(Qt.Key_Down)
		keyClick(Qt.Key_Down)
		tryCompare(host.speedSlider, "activeFocus", true)
		keyClick(Qt.Key_Down)
		compare(host.downPresses, 1)
		verify(host.speedSlider.activeFocus)
		compare(host.upPresses, 1)
	}
}
