pragma ComponentBehavior: Bound

/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A row of status bar buttons that open the Quick Access panes.

	The model is a CombinedListModel (see MainView.cardsLoader.quickAccessModel), where:
	- firstModel has a row for each built-in button, with the roles:
	    buttonId: "control" (the Controls button) or "aux" (the Switches button)
	    url: the url of the button's pane
	    icon, iconActive: the icons for when the pane is closed and open
	- secondModel is the GuiPluginIntegrationModel of the QuickAccessPane plugin integrations,
	  which has the same url, icon and iconActive roles.
*/
Row {
	id: root

	required property CombinedListModel model

	property real firstLeftInset: 0
	property real lastRightInset: 0
	property real buttonInset: 0
	property real bottomInset: 0

	// If true, a hidden button takes no space, so the shown buttons move together.
	// If false, each button keeps its space while it is hidden.
	property bool collapseHiddenButtons: false

	// Whether there are any switches for the Switches button to open.
	readonly property bool _switchesAvailable: Services.ioChannels.groups.count > 0
			|| pluginSwitchCards.count > 0

	// The indexes of the buttons that get firstLeftInset and lastRightInset. If hidden buttons take
	// no space, these are the first and last shown buttons, so that the outer insets stay at the
	// edges of the row. Otherwise the buttons never move, so these are the first and last buttons.
	readonly property int _firstEdgeIndex: {
		const indexes = collapseHiddenButtons ? shownSlotIndexes() : []
		return indexes.length > 0 ? indexes[0] : 0
	}
	readonly property int _lastEdgeIndex: {
		const indexes = collapseHiddenButtons ? shownSlotIndexes() : []
		return indexes.length > 0 ? indexes[indexes.length - 1] : buttonRepeater.count - 1
	}

	readonly property Item firstFocusableButton: focusableButtons()[0] ?? null
	readonly property Item lastFocusableButton: {
		const buttons = focusableButtons()
		return buttons.length > 0 ? buttons[buttons.length - 1] : null
	}

	// Reading root.children makes bindings that call this re-run when the Repeater adds or removes
	// a button. Reading visible and enabled makes them re-run when a button is shown, hidden,
	// enabled or disabled.
	function focusableButtons() {
		let buttons = []
		for (let i = 0; i < root.children.length; ++i) {
			const button = root.children[i].statusBarButton
			if (button && button.visible && button.enabled) {
				buttons.push(button)
			}
		}
		return buttons
	}

	// Returns the indexes of the buttons that are shown, in order. As with focusableButtons(),
	// bindings that call this re-run when a button is added or removed, or when a button is shown
	// or hidden.
	function shownSlotIndexes() {
		let indexes = []
		for (let i = 0; i < root.children.length; ++i) {
			const button = root.children[i].statusBarButton
			if (button?.shown) {
				indexes.push(button.index)
			}
		}
		return indexes.sort((a, b) => a - b)
	}

	GuiPluginIntegrationModel {
		id: pluginSwitchCards
		type: GuiPluginLoader.QuickAccessPaneCard
		cardType: GuiPluginLoader.SwitchesCard
	}

	Repeater {
		id: buttonRepeater

		model: root.model

		// A hidden button keeps its space (unless collapseHiddenButtons is set, or it has nothing to
		// open), so that the buttons stay in the same place when other buttons are shown or hidden:
		// it stays visible, but is transparent and disabled. Use shown, rather than visible, to
		// check whether the button is shown.
		delegate: StatusBarButton {
			id: button

			required property int index
			required property bool fromSecondModel
			required property var model

			// So that the button is found by focusableButtons() and shownSlotIndexes().
			readonly property StatusBarButton statusBarButton: button

			readonly property string buttonId: fromSecondModel ? "plugin" : (model.buttonId ?? "")
			readonly property url paneUrl: model.url ?? ""
			readonly property url inactiveIcon: model.icon ?? ""
			readonly property url activeIcon: model.iconActive ?? ""
			readonly property bool cardsActive: Global.mainView?.cardsActive ?? false
			readonly property bool paneOpened: Global.mainView?.quickAccessOpen(paneUrl) ?? false
			readonly property bool interactive: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive

			// Whether the button has anything to open. The Switches button only does if there are
			// switches, or if its pane is open, so that it can be closed if all switches are
			// disconnected while it is open.
			readonly property bool available: buttonId !== "aux" || root._switchesAvailable || paneOpened

			// Whether the button should be shown.
			readonly property bool shown: {
				switch (buttonId) {
				case "aux":
					return (available && !cardsActive) || paneOpened
				default:
					return Global.allPagesLoaded && (!cardsActive || paneOpened)
				}
			}

			leftInset: index === root._firstEdgeIndex ? root.firstLeftInset : root.buttonInset
			rightInset: index === root._lastEdgeIndex ? root.lastRightInset : root.buttonInset
			bottomInset: root.bottomInset

			// A hidden button keeps its space unless collapseHiddenButtons is set, so that the
			// other buttons do not move when it is hidden for a while, e.g. while a pane is open. A
			// button with nothing to open is not shown at all, so it takes no space.
			visible: shown || (!root.collapseHiddenButtons && available)
			enabled: shown && interactive
			// This replaces StatusBarButton's opacity binding, which fades the button out when the
			// UI is idle, so it does that too.
			opacity: shown && interactive ? 1 : 0

			icon.source: (paneOpened && String(activeIcon).length > 0) ? activeIcon : inactiveIcon
			icon.cache: buttonId !== "plugin"

			KeyNavigation.left: {
				const buttons = root.focusableButtons()
				const i = buttons.indexOf(button)
				return i > 0 ? buttons[i - 1] : null
			}
			KeyNavigation.right: {
				const buttons = root.focusableButtons()
				const i = buttons.indexOf(button)
				return i >= 0 && i < buttons.length - 1 ? buttons[i + 1] : root.KeyNavigation.right
			}

			onClicked: paneOpened ? Global.mainView.cardsLoader.hide()
								  : Global.mainView.showQuickAccess(model.pluginName, paneUrl)
		}
	}
}
