/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS

// Tests the quick access buttons in the status bar (QuickAccessView), with the TestQuickAccess
// plugin that tests/plugins compiles. The plugin adds three QuickAccessPane integrations: panes A
// and B have an active icon, and pane C does not. The TestCards plugin, which is also compiled
// there, adds switches cards, so that the Switches button has something to open.
//
// The view is created as the status bars create it, with the same model as MainView. Stand-ins
// for MainView and PageManager record which pane is open.
TestCase {
	id: root

	property var initialMainView
	property var initialPageManager
	property bool initialAllPagesLoaded
	property string initialPluginsJson

	readonly property real buttonWidth: Theme.geometry_statusBar_button_height
	readonly property string pluginName: "TestQuickAccess"

	name: "QuickAccessPaneTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The key tests need that.
	visible: true
	width: 1100
	height: 900

	// Stands in for MainView: the functions and properties that QuickAccessView uses.
	QtObject {
		id: mockMainView

		property bool cardsActive
		property string openUrl
		property string openName
		property int showCount

		readonly property QtObject cardsLoader: QtObject {
			function hide() {
				mockMainView.cardsActive = false
			}
		}

		function showQuickAccess(name, url) {
			openName = name ?? ""
			openUrl = String(url)
			cardsActive = true
			++showCount
		}

		function quickAccessOpen(url) {
			return cardsActive && openUrl === String(url)
		}
	}

	QtObject {
		id: mockPageManager

		property int interactivity: VenusOS.PageManager_InteractionMode_Interactive
	}

	// The same model as MainView.cardsLoader.quickAccessModel.
	CombinedListModel {
		id: quickAccessModel

		firstModel: ListModel {
			ListElement { buttonId: "control"; url: "ControlCardsPage.qml"; icon: "qrc:/images/icon_controls_off_32.svg"; iconActive: "qrc:/images/icon_controls_on_32.svg" }
			ListElement { buttonId: "aux"; url: "AuxCardsPage.qml"; icon: "qrc:/images/icon_smartswitch_off_32.svg"; iconActive: "qrc:/images/icon_smartswitch_on_32.svg" }
		}
		secondModel: GuiPluginIntegrationModel {
			type: GuiPluginLoader.QuickAccessPane
		}
	}

	GuiPluginIntegrationModel {
		id: paneIntegrations

		type: GuiPluginLoader.QuickAccessPane
	}

	GuiPluginIntegrationModel {
		id: switchCards

		type: GuiPluginLoader.QuickAccessPaneCard
		cardType: GuiPluginLoader.SwitchesCard
	}

	Component {
		id: viewComponent

		QuickAccessView {
			model: quickAccessModel
		}
	}

	function initTestCase() {
		root.initialMainView = Global.mainView
		root.initialPageManager = Global.pageManager
		root.initialAllPagesLoaded = Global.allPagesLoaded
		Global.mainView = mockMainView
		Global.pageManager = mockPageManager
		// The plugin buttons are only shown once the pages are loaded.
		Global.allPagesLoaded = true

		tryVerify(function() { return Services.ready }, 20000)

		root.initialPluginsJson = GuiPluginLoader.pluginsJson
		compare(paneIntegrations.count, 3, "The TestQuickAccess plugin, which tests/plugins compiles, was not loaded")
		verify(switchCards.count > 0, "The TestCards plugin, which tests/plugins compiles, was not loaded")
		// Without the TestCards plugin, the Switches button must have nothing to open.
		compare(Services.ioChannels.groups.count, 0)
	}

	function cleanupTestCase() {
		Global.mainView = root.initialMainView
		Global.pageManager = root.initialPageManager
		Global.allPagesLoaded = root.initialAllPagesLoaded
	}

	function init() {
		mockMainView.cardsActive = false
		mockMainView.openUrl = ""
		mockMainView.openName = ""
		mockMainView.showCount = 0
		mockPageManager.interactivity = VenusOS.PageManager_InteractionMode_Interactive
		Global.keyNavigationEnabled = false
	}

	function cleanup() {
		Global.keyNavigationEnabled = false
		if (GuiPluginLoader.pluginsJson !== root.initialPluginsJson) {
			GuiPluginLoader.pluginsJson = root.initialPluginsJson
		}
		tryCompare(paneIntegrations, "count", 3)
	}

	// Loads the plugins with only the given panes ("PaneA", "PaneB", "PaneC") of the
	// TestQuickAccess plugin, and the TestCards plugin only if withSwitchCards is true.
	function usePlugins(paneNames, withSwitchCards) {
		let plugins = JSON.parse(root.initialPluginsJson)
		const plugin = plugins.find(p => p.name === root.pluginName)
		plugin.integrations = plugin.integrations.filter(
				integration => paneNames.some(name => integration.url.endsWith("_" + name + ".qml")))
		// A plugin without integrations is not loaded, with a warning, so leave it out.
		if (plugin.integrations.length === 0) {
			plugins = plugins.filter(p => p !== plugin)
		}
		if (!withSwitchCards) {
			plugins = plugins.filter(p => p.name !== "TestCards")
		}
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)
		tryCompare(paneIntegrations, "count", paneNames.length)
		tryCompare(switchCards, "count", withSwitchCards ? 2 : 0)
	}

	// The properties that StatusBar_Landscape and StatusBar_Portrait give the view.
	function viewProperties(layout) {
		if (layout === "landscape") {
			return {
				firstLeftInset: Theme.geometry_statusBar_horizontalMargin,
				bottomInset: Theme.geometry_statusBar_spacing,
			}
		}
		return {
			firstLeftInset: Theme.geometry_statusBar_spacing / 2,
			lastRightInset: Theme.geometry_statusBar_horizontalMargin,
			buttonInset: Theme.geometry_statusBar_spacing / 2,
			bottomInset: Theme.geometry_statusBar_spacing,
			collapseHiddenButtons: true,
			maximumPluginButtons: 1,
		}
	}

	function createView(properties) {
		const view = createTemporaryObject(viewComponent, root, properties)
		verify(view !== null)
		return view
	}

	// The buttons in the row, in order, not including the overflow button.
	function rowButtons(view) {
		const buttons = []
		for (let i = 0; i < view.children.length; ++i) {
			const child = view.children[i]
			if (child instanceof StatusBarButton && child.buttonId !== undefined) {
				buttons.push(child)
			}
		}
		return buttons.sort((a, b) => a.index - b.index)
	}

	// Waits until the row has placed its visible buttons side by side, from its left edge. A Row
	// places its children on its next polish, so a button that was just shown may not be in place.
	function waitForRowLayout(view) {
		tryVerify(function() {
			const buttons = rowButtons(view).filter(b => b.visible)
			const overflow = overflowButton(view)
			if (overflow.visible) {
				buttons.push(overflow)
			}
			let x = 0
			for (const button of buttons) {
				if (Math.abs(button.x - x) > 0.5) {
					return false
				}
				x += button.width
			}
			return true
		}, 5000, "The row did not place its buttons")
	}

	function popupButtons(view) {
		return view._popupButtons
	}

	function overflowButton(view) {
		for (let i = 0; i < view.children.length; ++i) {
			const child = view.children[i]
			if (child instanceof StatusBarButton && child.openedPopupButton !== undefined) {
				return child
			}
		}
		return null
	}

	// "control", "aux", or the name of the plugin pane, e.g. "PaneA".
	function buttonName(button) {
		return button.buttonId === "plugin"
				? String(button.paneUrl).replace(/^.*_(\w+)\.qml$/, "$1")
				: button.buttonId
	}

	function findButton(buttons, name) {
		const button = buttons.find(b => buttonName(b) === name) ?? null
		verify(button !== null, "Cannot find the %1 button".arg(name))
		return button
	}

	function rowNames(view) {
		return rowButtons(view).map(buttonName)
	}

	function popupNames(view) {
		return popupButtons(view).map(buttonName)
	}

	function shownRowNames(view) {
		return rowButtons(view).filter(b => b.shown).map(buttonName)
	}

	// The popup's buttons are only visible while it is open.
	function popupOpened(view) {
		return popupButtons(view).some(b => b.visible)
	}

	// The icons of the button with the given name, when its pane is closed and open, from the
	// quick access model and the compiled plugin.
	function expectedIcons(name) {
		if (name === "control") {
			return [ "qrc:/images/icon_controls_off_32.svg", "qrc:/images/icon_controls_on_32.svg" ]
		} else if (name === "aux") {
			return [ "qrc:/images/icon_smartswitch_off_32.svg", "qrc:/images/icon_smartswitch_on_32.svg" ]
		}
		const plugin = JSON.parse(root.initialPluginsJson).find(p => p.name === root.pluginName)
		const integration = plugin.integrations.find(i => i.url.endsWith("_" + name + ".qml"))
		// Without an active icon, the button keeps its icon while its pane is open.
		return [ integration.icon, integration.iconActive ?? integration.icon ]
	}

	function test_buttons_data() {
		return [
			{ tag: "landscape, three panes", layout: "landscape", panes: [ "PaneA", "PaneB", "PaneC" ],
				row: [ "control", "aux", "PaneA", "PaneB", "PaneC" ], popup: [] },
			{ tag: "landscape, no panes", layout: "landscape", panes: [],
				row: [ "control", "aux" ], popup: [] },
			{ tag: "portrait, one pane", layout: "portrait", panes: [ "PaneA" ],
				row: [ "control", "aux", "PaneA" ], popup: [] },
			// Portrait shows a single plugin button. With more, all of them are in the popup.
			{ tag: "portrait, two panes", layout: "portrait", panes: [ "PaneA", "PaneB" ],
				row: [ "control", "aux" ], popup: [ "PaneA", "PaneB" ] },
			{ tag: "portrait, three panes", layout: "portrait", panes: [ "PaneA", "PaneB", "PaneC" ],
				row: [ "control", "aux" ], popup: [ "PaneA", "PaneB", "PaneC" ] },
			{ tag: "portrait, no panes", layout: "portrait", panes: [],
				row: [ "control", "aux" ], popup: [] },
		]
	}

	// The built-in Controls and Switches buttons come first, then a button for each QuickAccessPane
	// integration, in the row or in the overflow popup. The overflow button is only shown while
	// the popup has buttons.
	function test_buttons(data) {
		usePlugins(data.panes, true)
		const view = createView(viewProperties(data.layout))

		compare(rowNames(view), data.row)
		compare(shownRowNames(view), data.row)
		compare(popupNames(view), data.popup)
		compare(overflowButton(view).visible, data.popup.length > 0)
		verify(!popupOpened(view))

		for (const button of rowButtons(view).concat(popupButtons(view))) {
			const name = buttonName(button)
			compare(String(button.icon.source), expectedIcons(name)[0], "Icon of the %1 button".arg(name))
		}
	}

	function test_openAndClosePane_data() {
		const rows = []
		for (const layout of [ "landscape", "portrait" ]) {
			for (const name of [ "control", "aux", "PaneA", "PaneC" ]) {
				rows.push({ tag: "%1, %2".arg(layout).arg(name), layout: layout, name: name })
			}
		}
		return rows
	}

	// A button opens its pane, by url, with the plugin's name for a plugin pane. While the pane is
	// open, the button shows its active icon, and the other buttons are hidden. In landscape,
	// hidden buttons keep their space, so the button does not move. In portrait, hidden buttons
	// take no space, so the button gets the outer insets of the row. Clicking the button again
	// closes the pane.
	function test_openAndClosePane(data) {
		// One pane, so that portrait shows its button in the row.
		usePlugins([ data.name.startsWith("Pane") ? data.name : "PaneA" ], true)
		const properties = viewProperties(data.layout)
		const view = createView(properties)
		const landscape = data.layout === "landscape"

		let button = findButton(rowButtons(view), data.name)
		const closedX = button.x
		const others = rowButtons(view).filter(b => b !== button)
		verify(others.length > 0)

		mouseClick(button)
		compare(mockMainView.showCount, 1)
		compare(mockMainView.openUrl, String(button.paneUrl))
		compare(mockMainView.openName, data.name.startsWith("Pane") ? root.pluginName : "")
		verify(button.paneOpened)
		verify(button.shown)
		verify(button.enabled)
		compare(String(button.icon.source), expectedIcons(data.name)[1])

		for (const other of others) {
			const name = buttonName(other)
			verify(!other.shown, "%1 is shown while %2 is open".arg(name).arg(data.name))
			verify(!other.enabled, "%1 is enabled while %2 is open".arg(name).arg(data.name))
			compare(other.visible, landscape, "Whether %1 keeps its space".arg(name))
		}
		if (landscape) {
			compare(button.x, closedX)
		} else {
			compare(button.leftInset, properties.firstLeftInset)
			compare(button.rightInset, properties.lastRightInset)
		}

		mouseClick(button)
		compare(mockMainView.showCount, 1)
		verify(!mockMainView.cardsActive)
		verify(!button.paneOpened)
		compare(String(button.icon.source), expectedIcons(data.name)[0])
		compare(shownRowNames(view), rowNames(view))
		compare(button.x, closedX)
	}

	function test_noSwitches_data() {
		return [
			{ tag: "landscape", layout: "landscape" },
			{ tag: "portrait", layout: "portrait" },
		]
	}

	// Without switches, the Switches button is not shown, and takes no space, in either layout.
	// If the switches go away while its pane is open, it stays, so that the pane can be closed.
	function test_noSwitches(data) {
		usePlugins([ "PaneA" ], false)
		const view = createView(viewProperties(data.layout))

		let aux = findButton(rowButtons(view), "aux")
		const control = findButton(rowButtons(view), "control")
		const pane = findButton(rowButtons(view), "PaneA")
		verify(!aux.shown)
		verify(!aux.visible)
		compare(shownRowNames(view), [ "control", "PaneA" ])
		compare(pane.x, control.x + control.width)

		// The switches come back.
		usePlugins([ "PaneA" ], true)
		aux = findButton(rowButtons(view), "aux")
		tryVerify(function() { return aux.shown && aux.visible })
		compare(shownRowNames(view), [ "control", "aux", "PaneA" ])
		// The row places the button on its next polish, so wait for that before clicking it.
		waitForRowLayout(view)

		// They go away while the Switches pane is open.
		mouseClick(aux)
		verify(aux.paneOpened)
		usePlugins([ "PaneA" ], false)
		aux = findButton(rowButtons(view), "aux")
		verify(aux.paneOpened)
		verify(aux.shown)
		verify(aux.visible)
		verify(aux.enabled)

		mouseClick(aux)
		verify(!mockMainView.cardsActive)
		tryVerify(function() { return !aux.visible })
		compare(shownRowNames(view), [ "control", "PaneA" ])
	}

	function test_maximumWidth_data() {
		// The row has the buttons of the model's first rows, and then the overflow button if any
		// button that takes space is in the popup. Each button is buttonWidth wide, as the insets
		// are 0.
		return [
			{ tag: "all fit", buttons: 5, switches: true,
				row: [ "control", "aux", "PaneA", "PaneB", "PaneC" ], popup: [] },
			{ tag: "two move", buttons: 4.5, switches: true,
				row: [ "control", "aux", "PaneA" ], popup: [ "PaneB", "PaneC" ] },
			{ tag: "all plugin buttons move", buttons: 3.5, switches: true,
				row: [ "control", "aux" ], popup: [ "PaneA", "PaneB", "PaneC" ] },
			{ tag: "built-in button moves", buttons: 2, switches: true,
				row: [ "control" ], popup: [ "aux", "PaneA", "PaneB", "PaneC" ] },
			// The Switches button takes no space without switches, so it is not counted.
			{ tag: "all fit, no switches", buttons: 4, switches: false,
				row: [ "control", "aux", "PaneA", "PaneB", "PaneC" ], popup: [] },
			{ tag: "two move, no switches", buttons: 3, switches: false,
				row: [ "control", "aux", "PaneA" ], popup: [ "PaneB", "PaneC" ] },
		]
	}

	// Buttons that would make the row wider than maximumWidth move into the overflow popup, along
	// with the buttons after them, and come back when the row is wide enough.
	function test_maximumWidth(data) {
		usePlugins([ "PaneA", "PaneB", "PaneC" ], data.switches)
		const view = createView({})
		const all = [ "control", "aux", "PaneA", "PaneB", "PaneC" ]
		compare(rowNames(view), all)
		verify(!overflowButton(view).visible)

		view.maximumWidth = data.buttons * root.buttonWidth
		compare(rowNames(view), data.row)
		compare(popupNames(view), data.popup)
		compare(overflowButton(view).visible, data.popup.length > 0)
		// The row positions its buttons on the next polish.
		tryVerify(function() { return view.width <= view.maximumWidth + 0.5 }, 5000,
				"The row is %1 wide, more than %2".arg(view.width).arg(view.maximumWidth))

		view.maximumWidth = Infinity
		compare(rowNames(view), all)
		compare(popupNames(view), [])
		verify(!overflowButton(view).visible)
	}

	// Clicking the overflow button opens the popup, and clicking it again closes it. Clicking a
	// button in the popup opens its pane and closes the popup. While that pane is open, the
	// overflow button shows the pane's active icon, and clicking it closes the pane.
	function test_overflowPopup() {
		usePlugins([ "PaneA", "PaneB" ], true)
		const view = createView(viewProperties("portrait"))
		const overflow = overflowButton(view)
		const moreIcon = "qrc:/images/icon_more_dots.svg"
		verify(overflow.visible)
		compare(String(overflow.icon.source), moreIcon)

		mouseClick(overflow)
		tryVerify(function() { return popupOpened(view) })
		mouseClick(overflow)
		tryVerify(function() { return !popupOpened(view) })

		mouseClick(overflow)
		tryVerify(function() { return popupOpened(view) })
		const paneB = findButton(popupButtons(view), "PaneB")
		mouseClick(paneB)
		compare(mockMainView.showCount, 1)
		compare(mockMainView.openUrl, String(paneB.paneUrl))
		compare(mockMainView.openName, root.pluginName)
		tryVerify(function() { return !popupOpened(view) })

		verify(overflow.visible)
		verify(overflow.enabled)
		compare(String(overflow.icon.source), expectedIcons("PaneB")[1])
		compare(shownRowNames(view), [])

		mouseClick(overflow)
		verify(!mockMainView.cardsActive)
		verify(!popupOpened(view))
		compare(String(overflow.icon.source), moreIcon)
		compare(shownRowNames(view), [ "control", "aux" ])
	}

	// The popup closes when a pane opens, e.g. from elsewhere in the UI, when the overflow button is
	// disabled, e.g. when the UI goes idle, and when its buttons move into the row.
	function test_overflowPopupCloses_data() {
		return [
			{ tag: "pane opens" },
			{ tag: "idle" },
			{ tag: "buttons move into the row" },
		]
	}

	function test_overflowPopupCloses(data) {
		usePlugins([ "PaneA", "PaneB" ], true)
		const view = createView(viewProperties("portrait"))
		const overflow = overflowButton(view)

		mouseClick(overflow)
		tryVerify(function() { return popupOpened(view) })

		if (data.tag === "pane opens") {
			mockMainView.showQuickAccess("", "ControlCardsPage.qml")
		} else if (data.tag === "idle") {
			mockPageManager.interactivity = VenusOS.PageManager_InteractionMode_Idle
			verify(!overflow.enabled)
		} else {
			usePlugins([ "PaneA" ], true)
			tryVerify(function() { return JSON.stringify(rowNames(view)) === JSON.stringify([ "control", "aux", "PaneA" ]) })
			verify(!overflow.visible)
		}
		tryVerify(function() { return !popupOpened(view) })
	}

	function test_rowKeyNavigation_data() {
		return [
			{ tag: "with switches", switches: true, names: [ "control", "aux", "PaneA", "PaneB", "PaneC" ] },
			{ tag: "no switches", switches: false, names: [ "control", "PaneA", "PaneB", "PaneC" ] },
		]
	}

	// Right and left move between the shown buttons of the row.
	function test_rowKeyNavigation(data) {
		usePlugins([ "PaneA", "PaneB", "PaneC" ], data.switches)
		Global.keyNavigationEnabled = true
		const view = createView(viewProperties("landscape"))
		const buttons = data.names.map(name => findButton(rowButtons(view), name))
		compare(view.focusableButtons.map(buttonName), data.names)
		compare(view.firstFocusableButton, buttons[0])
		compare(view.lastFocusableButton, buttons[buttons.length - 1])

		buttons[0].forceActiveFocus()
		for (let i = 1; i < buttons.length; ++i) {
			keyClick(Qt.Key_Right)
			tryVerify(function() { return buttons[i].activeFocus }, 5000, "Focus did not move to " + data.names[i])
		}
		for (let i = buttons.length - 2; i >= 0; --i) {
			keyClick(Qt.Key_Left)
			tryVerify(function() { return buttons[i].activeFocus }, 5000, "Focus did not move to " + data.names[i])
		}
	}

	// Opening the popup moves the focus to its first button. Down and up move between its buttons,
	// and up from the first one moves back to the overflow button, which closes the popup. Escape
	// also closes the popup, and gives the focus back to the overflow button.
	function test_popupKeyNavigation() {
		usePlugins([ "PaneA", "PaneB", "PaneC" ], true)
		Global.keyNavigationEnabled = true
		const view = createView(viewProperties("portrait"))
		const overflow = overflowButton(view)
		compare(view.lastFocusableButton, overflow)

		overflow.forceActiveFocus()
		mouseClick(overflow)
		tryVerify(function() { return popupOpened(view) })
		const buttons = [ "PaneA", "PaneB", "PaneC" ].map(name => findButton(popupButtons(view), name))
		tryVerify(function() { return buttons[0].activeFocus }, 5000, "Focus did not move into the popup")

		keyClick(Qt.Key_Down)
		tryVerify(function() { return buttons[1].activeFocus }, 5000, "Focus did not move to PaneB")
		keyClick(Qt.Key_Down)
		tryVerify(function() { return buttons[2].activeFocus }, 5000, "Focus did not move to PaneC")
		keyClick(Qt.Key_Up)
		tryVerify(function() { return buttons[1].activeFocus }, 5000, "Focus did not move back to PaneB")
		keyClick(Qt.Key_Up)
		tryVerify(function() { return buttons[0].activeFocus }, 5000, "Focus did not move back to PaneA")
		keyClick(Qt.Key_Up)
		tryVerify(function() { return overflow.activeFocus }, 5000, "Focus did not move back to the overflow button")
		tryVerify(function() { return !popupOpened(view) })

		mouseClick(overflow)
		tryVerify(function() { return buttons[0].activeFocus }, 5000, "Focus did not move into the popup")
		keyClick(Qt.Key_Escape)
		tryVerify(function() { return !popupOpened(view) })
		tryVerify(function() { return overflow.activeFocus }, 5000, "Focus did not return to the overflow button")
	}

	// A QuickAccessPane integration without an icon is left out, with a warning. The plugin's
	// other panes are kept.
	function test_integrationWithoutIcon() {
		const plugins = JSON.parse(root.initialPluginsJson)
		plugins.find(p => p.name === root.pluginName).integrations.push({
			type: GuiPluginLoader.QuickAccessPane,
			url: "qrc:/TestQuickAccess/TestQuickAccess_PaneA.qml",
		})
		ignoreWarning(/^Ignoring invalid integration at index 3 in plugin TestQuickAccess .*- missing icon$/)
		GuiPluginLoader.pluginsJson = JSON.stringify(plugins)
		compare(paneIntegrations.count, 3)
	}
}
