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

	property int initialScreenSize

	name: "PluginCardListViewTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The key tests need that.
	visible: true
	// Wide enough for three landscape cards side by side.
	width: 1600
	height: 1000

	Component {
		id: hostComponent

		// Counts the arrow keys that reach it from the list.
		FocusScope {
			id: host

			property int leftPresses
			property int rightPresses
			property int upPresses
			property int downPresses
			property alias list: list
			property alias pumpCard: pumpCard
			property alias tankCard: tankCard
			property alias energyCard: energyCard
			property alias pumpSwitch: pumpSwitch
			property alias heaterSwitch: heaterSwitch
			property alias tankSwitch: tankSwitch

			width: 1600
			height: 1000
			focus: true
			Keys.onLeftPressed: host.leftPresses += 1
			Keys.onRightPressed: host.rightPresses += 1
			Keys.onUpPressed: host.upPresses += 1
			Keys.onDownPressed: host.downPresses += 1

			PluginCardListView {
				id: list

				PluginCard {
					id: pumpCard

					title: "Pump"

					PluginListSwitch {
						id: pumpSwitch

						flat: true
						text: "Pump"
						writeAccessLevel: PluginAccessLevel.User
					}

					PluginListSwitch {
						id: heaterSwitch

						flat: true
						text: "Heater"
						writeAccessLevel: PluginAccessLevel.User
					}
				}

				PluginCard {
					id: tankCard

					title: "Tank"

					PluginListSwitch {
						id: tankSwitch

						flat: true
						text: "Fill"
						writeAccessLevel: PluginAccessLevel.User
					}
				}

				// Nothing in this card can take the key focus, so the card takes it.
				PluginCard {
					id: energyCard

					title: "Energy"
				}
			}
		}
	}

	Component {
		id: twoCardsComponent

		Item {
			property alias list: list
			property alias firstCard: firstCard

			width: 1600
			height: 1000

			PluginCardListView {
				id: list

				PluginCard {
					id: firstCard

					title: "Pump"
				}

				PluginCard {
					title: "Tank"
				}
			}
		}
	}

	function initTestCase() {
		root.initialScreenSize = Theme.screenSize
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
		Theme.screenSize = root.initialScreenSize
	}

	// The gui-v2 list view inside a PluginCardListView.
	function innerListView(list) {
		for (let i = 0; i < list.children.length; ++i) {
			const child = list.children[i]
			if (child.orientation !== undefined) {
				return child
			}
		}
		return null
	}

	function createHost() {
		const host = createTemporaryObject(hostComponent, root)
		verify(host !== null)
		tryVerify(function() {
			return host.pumpSwitch.visible && host.heaterSwitch.visible && host.tankSwitch.visible
					&& host.pumpSwitch.height > 0 && host.tankSwitch.height > 0
		})
		return host
	}

	function test_landscapeLayout_data() {
		return [
			{ tag: "FiveInch", screenSize: Theme.FiveInch },
			{ tag: "SevenInch", screenSize: Theme.SevenInch },
		]
	}

	function test_landscapeLayout(data) {
		Theme.screenSize = data.screenSize
		const host = createHost()
		const view = innerListView(host.list)
		verify(view !== null)

		compare(host.list.width, host.width)
		compare(host.list.height, host.height)
		compare(view.orientation, ListView.Horizontal)
		compare(view.width, host.width - 2 * Theme.geometry_controlCardsPage_horizontalMargin)
		compare(view.height, host.height - Theme.geometry_controlCardsPage_bottomMargin)

		// With more than two cards, the cards are as narrow as gui-v2's cards can be, and stand
		// side by side, in order, as tall as the list. The list places them when it lays itself
		// out, so wait for that.
		const cards = [ host.pumpCard, host.tankCard, host.energyCard ]
		for (let i = 0; i < cards.length; ++i) {
			compare(cards[i].width, Theme.geometry_controlCard_minimumWidth)
			compare(cards[i].height, view.height)
			tryCompare(cards[i], "x", i * (Theme.geometry_controlCard_minimumWidth
					+ Theme.geometry_controlCardsPage_spacing))
			compare(cards[i].y, 0)
		}
	}

	function test_twoCardsAreWider() {
		Theme.screenSize = Theme.FiveInch
		const host = createTemporaryObject(twoCardsComponent, root)
		verify(host !== null)
		verify(Theme.geometry_controlCard_maximumWidth > Theme.geometry_controlCard_minimumWidth)
		compare(host.firstCard.width, Theme.geometry_controlCard_maximumWidth)
	}

	function test_portraitLayout() {
		Theme.screenSize = Theme.Portrait
		const host = createHost()
		const view = innerListView(host.list)
		verify(view !== null)

		compare(view.orientation, ListView.Vertical)
		compare(view.width, host.width - 2 * Theme.geometry_controlCardsPage_horizontalMargin)

		// The cards stand one above the other, in order, as wide as the list, and as tall as their
		// content needs. The list places them when it lays itself out, so wait for that.
		const cards = [ host.pumpCard, host.tankCard, host.energyCard ]
		let y = 0
		for (let i = 0; i < cards.length; ++i) {
			compare(cards[i].width, view.width)
			compare(cards[i].height, cards[i].implicitHeight)
			tryCompare(cards[i], "y", y)
			compare(cards[i].x, 0)
			y += cards[i].height + Theme.geometry_controlCardsPage_spacing
		}
	}

	function test_followsAChangeOfLayout() {
		Theme.screenSize = Theme.SevenInch
		const host = createHost()
		const view = innerListView(host.list)
		compare(host.pumpCard.width, Theme.geometry_controlCard_minimumWidth)

		Theme.screenSize = Theme.Portrait
		compare(view.orientation, ListView.Vertical)
		compare(host.pumpCard.width, view.width)
		compare(host.pumpCard.height, host.pumpCard.implicitHeight)
	}

	function test_landscapeKeyNavigation() {
		Theme.screenSize = Theme.SevenInch
		Global.keyNavigationEnabled = true
		const host = createHost()

		// The first control in the first card takes the key focus.
		host.forceActiveFocus()
		tryCompare(host.pumpSwitch, "activeFocus", true)

		// Up and Down move within the card, and past either end, go to the item that holds the
		// list.
		keyClick(Qt.Key_Down)
		tryCompare(host.heaterSwitch, "activeFocus", true)
		keyClick(Qt.Key_Down)
		compare(host.downPresses, 1)
		verify(host.heaterSwitch.activeFocus)
		keyClick(Qt.Key_Up)
		tryCompare(host.pumpSwitch, "activeFocus", true)
		keyClick(Qt.Key_Up)
		compare(host.upPresses, 1)
		verify(host.pumpSwitch.activeFocus)

		// Left and Right move between the cards. A card with nothing that can take the key focus
		// takes it, and shows the highlight.
		keyClick(Qt.Key_Right)
		tryCompare(host.tankSwitch, "activeFocus", true)
		keyClick(Qt.Key_Right)
		tryCompare(host.energyCard, "activeFocus", true)
		verify(host.energyCard.KeyNavigationHighlight.active)
		keyClick(Qt.Key_Right)
		compare(host.rightPresses, 1)
		verify(host.energyCard.activeFocus)

		keyClick(Qt.Key_Left)
		tryCompare(host.tankSwitch, "activeFocus", true)
		keyClick(Qt.Key_Left)
		tryCompare(host.pumpSwitch, "activeFocus", true)
		keyClick(Qt.Key_Left)
		compare(host.leftPresses, 1)
		verify(host.pumpSwitch.activeFocus)

		compare(host.upPresses, 1)
		compare(host.downPresses, 1)
		compare(host.rightPresses, 1)
	}

	function test_portraitKeyNavigation() {
		Theme.screenSize = Theme.Portrait
		Global.keyNavigationEnabled = true
		const host = createHost()

		host.forceActiveFocus()
		tryCompare(host.pumpSwitch, "activeFocus", true)

		// Up and Down move within a card, and from the first or last control, to the previous or
		// next card.
		keyClick(Qt.Key_Down)
		tryCompare(host.heaterSwitch, "activeFocus", true)
		keyClick(Qt.Key_Down)
		tryCompare(host.tankSwitch, "activeFocus", true)
		keyClick(Qt.Key_Down)
		tryCompare(host.energyCard, "activeFocus", true)
		keyClick(Qt.Key_Down)
		compare(host.downPresses, 1)
		verify(host.energyCard.activeFocus)

		keyClick(Qt.Key_Up)
		tryCompare(host.tankSwitch, "activeFocus", true)
		keyClick(Qt.Key_Up)
		tryCompare(host.heaterSwitch, "activeFocus", true)
		keyClick(Qt.Key_Up)
		tryCompare(host.pumpSwitch, "activeFocus", true)
		keyClick(Qt.Key_Up)
		compare(host.upPresses, 1)
		verify(host.pumpSwitch.activeFocus)

		// Left and Right go to the item that holds the list.
		keyClick(Qt.Key_Left)
		keyClick(Qt.Key_Right)
		compare(host.leftPresses, 1)
		compare(host.rightPresses, 1)
		verify(host.pumpSwitch.activeFocus)
	}
}
