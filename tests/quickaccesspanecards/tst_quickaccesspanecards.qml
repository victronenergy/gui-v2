/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS

// Tests the cards in the Controls and Switches panes, with the TestCards plugin that tests/plugins
// compiles. The plugin adds a card that is taller than the screen, then a short card, to each pane.
TestCase {
	id: root

	property int initialScreenSize
	property string initialPluginsJson
	property var mockServiceUids: []

	name: "QuickAccessPaneCardsTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The key tests need that.
	visible: true
	width: 1100
	height: 900

	Component {
		id: controlsPaneComponent

		ControlCardsPage {
			width: Theme.geometry_screen_width
			height: Theme.geometry_screen_height - Theme.geometry_statusBar_height
		}
	}

	Component {
		id: switchesPaneComponent

		AuxCardsPage {
			width: Theme.geometry_screen_width
			height: Theme.geometry_screen_height - Theme.geometry_statusBar_height
		}
	}

	GuiPluginIntegrationModel {
		id: pluginCards

		type: GuiPluginLoader.QuickAccessPaneCard
	}

	function initTestCase() {
		root.initialScreenSize = Theme.screenSize
		// Unit tests do not load a mock configuration, so the access level is unset and
		// canAccess() is false, which hides the controls. User is enough to show them.
		MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel",
				VenusOS.User_AccessType_User)
		tryVerify(function() {
			return Services.ready && Services.settings.canAccess(VenusOS.User_AccessType_User)
		}, 20000)

		root.initialPluginsJson = GuiPluginLoader.pluginsJson
		compare(pluginCards.count, 4, "The TestCards plugin, which tests/plugins compiles, was not loaded")
	}

	function init() {
		Global.keyNavigationEnabled = false
	}

	function cleanup() {
		Global.keyNavigationEnabled = false
		Theme.screenSize = root.initialScreenSize
		if (GuiPluginLoader.pluginsJson !== root.initialPluginsJson) {
			GuiPluginLoader.pluginsJson = root.initialPluginsJson
		}
		for (const uid of root.mockServiceUids) {
			MockManager.removeValue(uid)
		}
		root.mockServiceUids = []
	}

	function addMockService(uid, values) {
		for (const path in values) {
			MockManager.setValue(uid + "/" + path, values[path])
		}
		root.mockServiceUids.push(uid)
	}

	// Adds two devices with one card each, called "<name> A" and "<name> B", to the pane.
	function addBuiltInCards(pane) {
		const names = [ "A", "B" ]
		for (let i = 0; i < names.length; ++i) {
			if (pane === "controls") {
				// An inverter/charger card, which has a Mode button.
				addMockService("mock/com.victronenergy.vebus." + names[i], {
					DeviceInstance: 280 + i,
					ProductName: "Inverter " + names[i],
				})
			} else {
				// A card for a switch device with one output.
				addMockService("mock/com.victronenergy.switch." + names[i], {
					DeviceInstance: 100 + i,
					ProductName: "Switch " + names[i],
					"SwitchableOutput/0/Name": "Output",
					"SwitchableOutput/0/State": 0,
					"SwitchableOutput/0/Settings/ValidTypes": (1 << VenusOS.SwitchableOutput_Type_Toggle),
					"SwitchableOutput/0/Settings/Type": VenusOS.SwitchableOutput_Type_Toggle,
				})
			}
		}
	}

	function builtInCardNames(pane) {
		return pane === "controls" ? [ "Inverter A", "Inverter B" ] : [ "Switch A", "Switch B" ]
	}

	function failedCardText(pluginName) {
		const text = qsTrId("plugin_card_load_failed")
		return text.indexOf("%1") >= 0 ? text.arg(pluginName) : text
	}

	function pluginCardNames(pane) {
		return pane === "controls" ? [ "Tall controls", "Controls" ] : [ "Tall switches", "Switches" ]
	}

	function createPane(pane) {
		const page = createTemporaryObject(pane === "controls" ? controlsPaneComponent : switchesPaneComponent, root)
		verify(page !== null)
		return page
	}

	// The card that the delegate shows.
	function cardInDelegate(delegate) {
		return delegate.item
	}

	function cardName(delegate) {
		if (delegate.sourceModel === delegate.ListView.view.model.secondModel) {
			return cardInDelegate(delegate).title
		}
		return delegate.model.device ? delegate.model.device.name : delegate.model.group.name
	}

	function cardNames(view) {
		const names = []
		for (let i = 0; i < view.count; ++i) {
			let delegate = view.itemAtIndex(i)
			if (!delegate) {
				view.positionViewAtIndex(i, ListView.Contain)
				delegate = view.itemAtIndex(i)
			}
			names.push(delegate ? cardName(delegate) : null)
		}
		return names
	}

	function findEmptyPageItem(item) {
		for (let i = 0; i < item.children.length; ++i) {
			const child = item.children[i]
			if (child.titleText !== undefined && child.primaryText !== undefined) {
				return child
			}
			const found = findEmptyPageItem(child)
			if (found) {
				return found
			}
		}
		return null
	}

	function test_cards_data() {
		const rows = []
		for (const pane of [ "controls", "switches" ]) {
			for (const builtIn of [ false, true ]) {
				for (const plugins of [ false, true ]) {
					rows.push({
						tag: "%1, %2 built-in cards, %3 plugin cards"
								.arg(pane).arg(builtIn ? "with" : "no").arg(plugins ? "with" : "no"),
						pane: pane,
						builtIn: builtIn,
						plugins: plugins,
					})
				}
			}
		}
		return rows
	}

	// Each pane shows its own built-in cards, then the plugin cards of its type, in order.
	function test_cards(data) {
		if (!data.plugins) {
			GuiPluginLoader.pluginsJson = "[]"
			compare(pluginCards.count, 0)
		}
		if (data.builtIn) {
			addBuiltInCards(data.pane)
		}
		const page = createPane(data.pane)
		const view = page.flickableView
		const expected = (data.builtIn ? builtInCardNames(data.pane) : [])
				.concat(data.plugins ? pluginCardNames(data.pane) : [])

		tryCompare(view, "count", expected.length)
		compare(cardNames(view), expected)
		if (view.count > 0) {
			// cardNames() may have scrolled the first delegate out of the cache.
			view.positionViewAtIndex(0, ListView.Contain)
			const firstDelegate = view.itemAtIndex(0)
			verify(firstDelegate !== null)
			verify(firstDelegate.sourceModel === (data.builtIn ? view.model.firstModel : view.model.secondModel))
		}

		// Only the Controls pane says when it has no cards.
		const emptyPageItem = findEmptyPageItem(page)
		compare(!!emptyPageItem && emptyPageItem.visible, data.pane === "controls" && expected.length === 0)
	}

	function test_keyNavigation_data() {
		const rows = []
		for (const pane of [ "controls", "switches" ]) {
			for (const screenSize of [ Theme.FiveInch, Theme.SevenInch, Theme.Portrait ]) {
				rows.push({
					tag: "%1, %2".arg(pane).arg(screenSize === Theme.FiveInch ? "FiveInch"
							: screenSize === Theme.SevenInch ? "SevenInch" : "Portrait"),
					pane: pane,
					screenSize: screenSize,
				})
			}
		}
		return rows
	}

	// The keys move the focus through the built-in cards, then through the plugin cards. The pane
	// scrolls to show each control that takes the focus, even in a card that is taller than the
	// pane.
	function test_keyNavigation(data) {
		Theme.screenSize = data.screenSize
		Global.keyNavigationEnabled = true
		addBuiltInCards(data.pane)
		const page = createPane(data.pane)
		const view = page.flickableView
		tryCompare(view, "count", 4)

		// Each built-in card has one control. A control in a plugin card is named by its
		// objectName.
		const portrait = data.screenSize === Theme.Portrait
		const forwardKey = portrait ? Qt.Key_Down : Qt.Key_Right
		const backKey = portrait ? Qt.Key_Up : Qt.Key_Left
		const forward = portrait
				? [
					{ card: 0 },
					{ card: 1 },
					{ card: 2, control: "firstSwitch" },
					{ card: 2, control: "middleSwitch" },
					{ card: 2, control: "lastSwitch" },
					{ card: 3, control: "firstSwitch" },
					{ card: 3, control: "lastSwitch" },
				]
				: [
					{ card: 0 },
					{ card: 1 },
					{ card: 2, control: "firstSwitch" },
					{ card: 3, control: "firstSwitch" },
				]
		// A card keeps its last focused control when the focus comes back to it, so in portrait,
		// the focus comes back to the bottom of the tall card.
		const back = portrait
				? [
					{ card: 3, control: "firstSwitch" },
					{ card: 2, control: "lastSwitch" },
					{ card: 2, control: "middleSwitch" },
					{ card: 2, control: "firstSwitch" },
					{ card: 1 },
					{ card: 0 },
				]
				: [
					{ card: 2, control: "firstSwitch" },
					{ card: 1 },
					{ card: 0 },
				]

		// The pane must scroll to show every card, and in portrait, every control in the tall card.
		if (portrait) {
			view.positionViewAtIndex(2, ListView.Contain)
			verify(view.itemAtIndex(2).height > view.height)
			view.positionViewAtBeginning()
		} else {
			verify(view.contentWidth > view.width)
		}

		page.forceActiveFocus()
		checkFocus(view, forward[0])
		for (let i = 1; i < forward.length; ++i) {
			keyClick(forwardKey)
			checkFocus(view, forward[i])
		}
		for (let i = 0; i < back.length; ++i) {
			keyClick(backKey)
			checkFocus(view, back[i])
		}
	}

	function test_cardThatFailsToLoad_data() {
		const rows = []
		for (const pane of [ "controls", "switches" ]) {
			for (const portrait of [ false, true ]) {
				rows.push({
					tag: "%1, %2".arg(pane).arg(portrait ? "portrait" : "landscape"),
					pane: pane,
					portrait: portrait,
				})
			}
		}
		return rows
	}

	// A plugin card that compiles, but cannot be created, stays in the pane. It says the plugin's
	// card failed. The cards on either side are one spacing away from it.
	function test_cardThatFailsToLoad(data) {
		Theme.screenSize = data.portrait ? Theme.Portrait : Theme.SevenInch
		Global.keyNavigationEnabled = true

		// Add the card after the tall card, so that it is between the two plugin cards.
		const cardUrl = "qrc:/TestCards/TestCards_CardThatCannotBeCreated.qml"
		const cardType = data.pane === "controls" ? GuiPluginLoader.ControlsCard : GuiPluginLoader.SwitchesCard
		const plugins = JSON.parse(root.initialPluginsJson)
		const integrations = plugins.find(plugin => plugin.name === "TestCards").integrations
		integrations.splice(integrations.findIndex(integration => integration.cardType === cardType) + 1, 0, {
			type: GuiPluginLoader.QuickAccessPaneCard,
			cardType: cardType,
			url: cardUrl,
		})
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)

		ignoreWarning(/Required property cardTitle was not initialized/)
		const page = createPane(data.pane)
		const view = page.flickableView
		view.cacheBuffer = 100000
		tryCompare(view, "count", 3)
		const failedText = failedCardText("TestCards")
		let gaps = []
		tryVerify(function() {
			view.positionViewAtIndex(0, ListView.Beginning)
			const first = view.itemAtIndex(0)
			view.positionViewAtIndex(1, ListView.Contain)
			const failed = view.itemAtIndex(1)
			view.positionViewAtIndex(2, ListView.Contain)
			const third = view.itemAtIndex(2)
			if (!first || !failed || !third || !first.item || !failed.item || !third.item
					|| first.model.index !== 0 || failed.model.index !== 1 || third.model.index !== 2
					|| !failed.item.failed || failed.item.errorText !== failedText) {
				return false
			}
			const errorCard = findChild(failed.item, "pluginCardLoadError")
			if (!errorCard || !errorCard.visible || errorCard.status.text !== failedText) {
				return false
			}
			const between = function(before, after) {
				return view.orientation === ListView.Vertical
						? after.y - (before.y + before.height)
						: after.x - (before.x + before.width)
			}
			gaps = [between(first, failed), between(failed, third)]
			return gaps[0] === view.spacing && gaps[1] === view.spacing
		})
		compare(gaps[0], view.spacing)
		compare(gaps[1], view.spacing)
		compare(cardName(view.itemAtIndex(0)), pluginCardNames(data.pane)[0])
		compare(cardName(view.itemAtIndex(2)), pluginCardNames(data.pane)[1])

		const forwardKey = data.portrait ? Qt.Key_Down : Qt.Key_Right
		const backKey = data.portrait ? Qt.Key_Up : Qt.Key_Left
		page.forceActiveFocus()
		checkFocus(view, { card: 0, control: "firstSwitch" })
		if (data.portrait) {
			// Move to the bottom of the tall card.
			keyClick(forwardKey)
			keyClick(forwardKey)
			checkFocus(view, { card: 0, control: "lastSwitch" })
		}
		keyClick(forwardKey)
		checkFocus(view, { card: 1 })
		keyClick(forwardKey)
		checkFocus(view, { card: 2, control: "firstSwitch" })
		keyClick(backKey)
		checkFocus(view, { card: 1 })
		keyClick(backKey)
		checkFocus(view, { card: 0, control: data.portrait ? "lastSwitch" : "firstSwitch" })
	}

	// A Controls pane whose only card cannot be created shows that failure, rather than saying
	// that it has no cards.
	function test_onlyCardCannotBeCreated() {
		const cardUrl = "qrc:/TestCards/TestCards_CardThatCannotBeCreated.qml"
		const plugins = JSON.parse(root.initialPluginsJson)
		plugins.find(plugin => plugin.name === "TestCards").integrations = [{
			type: GuiPluginLoader.QuickAccessPaneCard,
			cardType: GuiPluginLoader.ControlsCard,
			url: cardUrl,
		}]
		ignoreWarning(/Required property cardTitle was not initialized/)
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)

		const page = createPane("controls")
		const failedText = failedCardText("TestCards")
		tryCompare(page.flickableView, "count", 1)
		tryVerify(function() {
			const delegate = page.flickableView.itemAtIndex(0)
			const errorCard = delegate && delegate.item ? findChild(delegate.item, "pluginCardLoadError") : null
			return !!delegate && !!delegate.item && delegate.item.failed
					&& delegate.item.errorText === failedText
					&& !!errorCard && errorCard.visible && errorCard.status.text === failedText
		})
		const emptyPageItem = findEmptyPageItem(page)
		verify(!emptyPageItem || !emptyPageItem.visible)
	}

	// A plugin card whose file cannot be compiled is left out when the plugins are loaded, with a
	// warning. The plugin's other cards are kept.
	function test_cardThatCannotBeCompiled() {
		const plugins = JSON.parse(root.initialPluginsJson)
		plugins.find(plugin => plugin.name === "TestCards").integrations.push({
			type: GuiPluginLoader.QuickAccessPaneCard,
			cardType: GuiPluginLoader.ControlsCard,
			url: "qrc:/TestCards/TestCards_MissingCard.qml",
		})
		ignoreWarning(/^Ignoring card that cannot be compiled in plugin TestCards: qrc:\/TestCards\/TestCards_MissingCard\.qml/)
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)
		compare(pluginCards.count, 4)
	}

	// A plugin whose only card cannot be compiled is not loaded, so the Controls pane, with no
	// cards of its own, says that it has no cards.
	function test_onlyCardCannotBeCompiled() {
		const plugins = JSON.parse(root.initialPluginsJson)
		plugins.find(plugin => plugin.name === "TestCards").integrations = [{
			type: GuiPluginLoader.QuickAccessPaneCard,
			cardType: GuiPluginLoader.ControlsCard,
			url: "qrc:/TestCards/TestCards_MissingCard.qml",
		}]
		ignoreWarning(/^Ignoring card that cannot be compiled in plugin TestCards: qrc:\/TestCards\/TestCards_MissingCard\.qml/)
		ignoreWarning('Ignoring plugin without valid integrations: "TestCards"')
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)
		compare(pluginCards.count, 0)

		const page = createPane("controls")
		compare(page.flickableView.count, 0)
		const emptyPageItem = findEmptyPageItem(page)
		verify(!!emptyPageItem && emptyPageItem.visible)
	}

	// Checks that the control in the step has the key focus, and that the pane scrolls to show it.
	function checkFocus(view, step) {
		const description = "card %1%2".arg(step.card).arg(step.control ? ", " + step.control : "")
		let delegate = null
		tryVerify(function() {
			delegate = view.itemAtIndex(step.card)
			return !!delegate && delegate.activeFocus
		}, 5000, "Focus did not move to " + description)

		const item = step.control ? findChild(cardInDelegate(delegate), step.control) : delegate
		verify(item !== null, "Cannot find " + description)
		tryVerify(function() { return item.activeFocus }, 5000, "Focus did not move to " + description)
		tryVerify(function() {
			const pos = item.mapToItem(view, 0, 0)
			return view.orientation === ListView.Vertical
					? pos.y >= -1 && pos.y + item.height <= view.height + 1
					: pos.x >= -1 && pos.x + item.width <= view.width + 1
		}, 5000, "The pane did not scroll to show " + description)
	}
}
