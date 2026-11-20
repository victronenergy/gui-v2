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

	// If true, the slot of a hidden button takes no space, so the visible buttons move together.
	// If false, each slot keeps its button's width while the button is hidden.
	property bool collapseHiddenButtons: false

	// The slots that get firstLeftInset and lastRightInset. If hidden slots take no space, these
	// are the slots of the first and last shown buttons, so that the outer insets stay at the
	// edges of the row. Otherwise the slots never move, so these are the first and last slots.
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
	// a slot. Reading visible and enabled makes them re-run when a button is shown, hidden,
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

	// Returns the indexes of the slots whose buttons are shown, in order. As with
	// focusableButtons(), bindings that call this re-run when a slot is added or removed, or when
	// a button is shown or hidden.
	function shownSlotIndexes() {
		let indexes = []
		for (let i = 0; i < root.children.length; ++i) {
			const slot = root.children[i]
			if (slot.statusBarButton?.visible) {
				indexes.push(slot.index)
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

		// Each button is placed in a slot that keeps the button's width while it is hidden (unless
		// collapseHiddenButtons is set), so that the buttons stay in the same place when other
		// buttons are shown or hidden.
		delegate: Item {
			id: slot

			required property int index
			required property bool fromSecondModel
			required property var model

			readonly property StatusBarButton statusBarButton: button

			width: button.visible || !root.collapseHiddenButtons ? button.implicitWidth : 0
			height: button.implicitHeight

			StatusBarButton {
				id: button

				anchors.fill: parent

				readonly property string buttonId: slot.fromSecondModel ? "plugin" : (slot.model.buttonId ?? "")
				readonly property url paneUrl: slot.model.url ?? ""
				readonly property url inactiveIcon: slot.model.icon ?? ""
				readonly property url activeIcon: slot.model.iconActive ?? ""
				readonly property bool cardsActive: Global.mainView?.cardsActive ?? false
				readonly property bool paneOpened: Global.mainView?.quickAccessOpen(paneUrl) ?? false

				leftInset: slot.index === root._firstEdgeIndex ? root.firstLeftInset : root.buttonInset
				rightInset: slot.index === root._lastEdgeIndex ? root.lastRightInset : root.buttonInset
				bottomInset: root.bottomInset

				enabled: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				visible: {
					switch (buttonId) {
					case "aux":
						return ((Services.ioChannels.groups.count > 0 || pluginSwitchCards.count > 0)
								&& !cardsActive)
								|| paneOpened // allow cards to be closed if all switches are disconnected while opened
					default:
						return Global.allPagesLoaded && (!cardsActive || paneOpened)
					}
				}

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
									  : Global.mainView.showQuickAccess(slot.model.pluginName, paneUrl)
			}
		}
	}
}
