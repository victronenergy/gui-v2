pragma ComponentBehavior: Bound

/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import QtQuick.Templates as T
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

	The row has the buttons of the first rows of the model, and the buttons of the other rows are
	in a popup, which is opened by an overflow button at the end of the row. Buttons are moved into
	the popup when:
	- there are more than maximumPluginButtons plugin buttons, in which case all of the plugin
	  buttons are moved, or
	- the row would be wider than maximumWidth, in which case the buttons from the first one that
	  does not fit, along with the overflow button, are moved.
*/
Row {
	id: root

	required property CombinedListModel model

	property real firstLeftInset: 0
	property real lastRightInset: 0
	property real buttonInset: 0
	property real bottomInset: 0

	// If true, a hidden button in the row takes no space, so the shown buttons move together.
	// If false, each button in the row keeps its space while it is hidden.
	property bool collapseHiddenButtons: false

	readonly property bool _cardsActive: Global.mainView?.cardsActive ?? false
	readonly property bool _interactive: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
	readonly property bool _switchesAvailable: Services.ioChannels.groups.count > 0
			|| pluginSwitchCards.count > 0

	// If there are more plugin buttons than this, all of them are moved into the overflow popup.
	// If negative, there is no limit.
	property int maximumPluginButtons: -1

	// If the row would be wider than this, the buttons that do not fit are moved into the overflow
	// popup. Every button takes the default status bar button width in this check, whether or not
	// it is currently shown.
	property real maximumWidth: Infinity

	// The number of rows of the model, from the start, whose buttons are in the row. The buttons of
	// the other rows are in the overflow popup.
	//
	// This only reads the row counts of the model and the sizes given to the view, not the buttons
	// themselves: moving buttons into the popup adds the overflow button, and changes which buttons
	// are shown, so reading any of those here would make a binding loop.
	readonly property int _rowButtonCount: {
		const rowCount = root.model?.count ?? 0
		// The plugin rows are the rows of the model's secondModel, after the built-in rows.
		// rowCount() does not notify, but root.model.count changes when the plugin rows change, so
		// this binding re-runs then.
		const pluginCount = Math.min(root.model?.secondModel?.rowCount() ?? 0, rowCount)

		let count = rowCount
		if (maximumPluginButtons >= 0 && pluginCount > maximumPluginButtons) {
			count -= pluginCount
		}

		if (Number.isFinite(maximumWidth)) {
			const buttonWidth = Theme.geometry_statusBar_button_height + 2 * buttonInset
			const edgeWidth = firstLeftInset + lastRightInset - 2 * buttonInset

			// While the Switches button has nothing to open, it takes no space (see the delegate's
			// available property), so its row does not count towards the width. Its row is found in
			// the built-in rows, rather than from the buttons, as reading the buttons here would
			// make a binding loop.
			const builtInModel = root.model?.firstModel as ListModel
			let spacelessRow = -1
			for (let i = 0; i < (builtInModel?.count ?? 0); ++i) {
				const row = builtInModel.get(i)
				if (row.buttonId === "aux") {
					if (!root._switchesAvailable && !(Global.mainView?.quickAccessOpen(row.url) ?? false)) {
						spacelessRow = i
					}
					break
				}
			}

			// Returns the number of buttons that take space, of the rows from first to before last.
			const buttonCount = (first, last) => (last - first)
					- (spacelessRow >= first && spacelessRow < last ? 1 : 0)
			// The overflow button takes a button's width if any button that takes space is moved
			// into the popup.
			const rowWidth = n => edgeWidth
					+ (buttonCount(0, n) + (buttonCount(n, rowCount) > 0 ? 1 : 0)) * buttonWidth
			while (count > 0 && rowWidth(count) > maximumWidth) {
				--count
			}
		}
		return count
	}

	// Returns the indexes of the buttons in the row that are shown, in order. As with
	// focusableButtons, bindings that call this re-run when a button is added or removed, or when
	// a button is shown or hidden.
	readonly property var shownSlotIndexes: {
		let indexes = []
		for (let i = 0; i < root.children.length; ++i) {
			const button = root.children[i]
			if (button instanceof StatusBarButton && button.shown) {
				indexes.push(button.index)
			}
		}
		return indexes.sort((a, b) => a - b)
	}

	// The slots that get firstLeftInset and lastRightInset. If hidden slots take no space, these
	// are the slots of the first and last shown buttons, so that the outer insets stay at the
	// edges of the row. Otherwise the slots never move, so these are the first and last slots.
	readonly property int _firstEdgeIndex: {
		const indexes = collapseHiddenButtons ? shownSlotIndexes : []
		return indexes.length > 0 ? indexes[0] : 0
	}
	readonly property int _lastEdgeIndex: {
		const indexes = collapseHiddenButtons ? shownSlotIndexes : []
		return indexes.length > 0 ? indexes[indexes.length - 1] : overflowButton.index
	}

	// The buttons in the row that can take focus, i.e. that are visible and enabled, in order,
	// including the overflow button, which is last.
	//
	// Reading root.children makes this re-run when the Repeater adds or removes a button. Reading
	// visible and enabled makes it re-run when a button is shown, hidden, enabled or disabled.
	//
	// The buttons are sorted by index, as the order of the children is the order in which the
	// Repeater created them, which is not always the order of the rows.
	readonly property var focusableButtons: {
		let buttons = []
		for (let i = 0; i < root.children.length; ++i) {
			const button = root.children[i]
			if (button instanceof StatusBarButton && button.visible && button.enabled) {
				buttons.push(button)
			}
		}
		return buttons.sort((a, b) => a.index - b.index)
	}
	readonly property Item firstFocusableButton: focusableButtons[0] ?? null
	readonly property Item lastFocusableButton: focusableButtons[focusableButtons.length - 1] ?? null

	// The buttons in the overflow popup, in the order of their rows. Reading the children of the
	// popup's column makes this re-run when its Repeater adds or removes a button. As with
	// focusableButtons, they are sorted by index, as the children may not be in the order of the
	// rows; otherwise the popup could focus a later button than the first when it opens.
	readonly property var _popupButtons: {
		let buttons = []
		const slots = popupColumn.children
		for (let i = 0; i < slots.length; ++i) {
			if (slots[i] instanceof StatusBarButton) {
				buttons.push(slots[i])
			}
		}
		return buttons.sort((a, b) => a.index - b.index)
	}
	readonly property bool _popupHasShownButtons: _popupButtons.some(button => button.shown)
	readonly property bool _popupPaneOpened: _popupButtons.some(button => button.paneOpened)

	GuiPluginIntegrationModel {
		id: pluginSwitchCards
		type: GuiPluginLoader.QuickAccessPaneCard
		cardType: GuiPluginLoader.SwitchesCard
	}

	// The button of a row of the model, used both in the row and in the overflow popup.
	//
	// In the row, a hidden button keeps its space (unless collapseHiddenButtons is set), so that
	// the buttons stay in the same place when other buttons are shown or hidden: it stays visible,
	// but is transparent and disabled. In the popup, a hidden button is not visible, so it takes no
	// space in the column.
	//
	// Use shown, rather than visible, to check whether the button is shown: a hidden button in the
	// row is visible, and every button in the popup is not visible while the popup is closed.
	Component {
		id: buttonComponent

		StatusBarButton {
			id: button

			required property int index
			// The model the row comes from: root.model's firstModel or secondModel.
			required property var sourceModel
			required property var model

			// The Repeater places each button in its own parent: the row, or the popup's column.
			readonly property bool inRow: parent === root

			readonly property string buttonId: model.buttonId ?? "plugin"
			readonly property bool paneOpened: Global.mainView?.quickAccessOpen(model.url) ?? false

			// Whether the button has anything to open. The Switches button only does if there are
			// switches, or if its pane is open, so that it can be closed if all switches are
			// disconnected while it is open.
			readonly property bool available: buttonId !== "aux" || root._switchesAvailable || paneOpened

			// Whether the button should be shown, in the row or in the popup.
			readonly property bool shown: {
				switch (buttonId) {
				case "control":
					return !root._cardsActive || paneOpened
				case "aux":
					return (available && !root._cardsActive) || paneOpened
				default:
					return Global.allPagesLoaded && (!root._cardsActive || paneOpened)
				}
			}

			// The popup's buttons are below the overflow button, so only the row's buttons are at
			// the edges of the row.
			implicitWidth: Theme.geometry_statusBar_button_height + leftInset + rightInset
			leftInset: inRow && index === root._firstEdgeIndex ? root.firstLeftInset : root.buttonInset
			rightInset: inRow && index === root._lastEdgeIndex ? root.lastRightInset : root.buttonInset
			bottomInset: inRow ? root.bottomInset : 0

			// A hidden button keeps its space unless collapseHiddenButtons is set, so that the
			// other buttons do not move when it is hidden for a while, e.g. while a pane is open. A
			// button with nothing to open is not shown at all, so it takes no space.
			visible: shown || (inRow && !root.collapseHiddenButtons && available)
			enabled: shown && root._interactive
			// This replaces StatusBarButton's opacity binding, which fades the button out when the
			// UI is idle, so it does that too.
			opacity: shown && root._interactive ? 1 : 0

			icon.source: (paneOpened && String(model.iconActive).length > 0) ? model.iconActive : model.icon
			icon.cache: buttonId !== "plugin"

			// In the row, left and right move between the row's buttons. In the popup, up and down
			// move between the popup's buttons, and up from the first one moves back to the overflow
			// button, which closes the popup.
			KeyNavigation.left: {
				if (!inRow) {
					return overflowButton.KeyNavigation.left
				}
				const buttons = root.focusableButtons
				const i = buttons.indexOf(button)
				return i > 0 ? buttons[i - 1] : root.KeyNavigation.left
			}
			KeyNavigation.right: {
				if (!inRow) {
					return root.KeyNavigation.right
				}
				const buttons = root.focusableButtons
				const i = buttons.indexOf(button)
				return i >= 0 && i < buttons.length - 1 ? buttons[i + 1] : root.KeyNavigation.right
			}
			KeyNavigation.up: {
				if (inRow) {
					return root.KeyNavigation.up
				}
				const buttons = root._popupButtons.filter(b => b.visible && b.enabled)
				const i = buttons.indexOf(button)
				return i > 0 ? buttons[i - 1] : overflowButton
			}
			KeyNavigation.down: {
				if (inRow) {
					return root.KeyNavigation.down
				}
				const buttons = root._popupButtons.filter(b => b.visible && b.enabled)
				const i = buttons.indexOf(button)
				return i >= 0 && i < buttons.length - 1 ? buttons[i + 1] : root.KeyNavigation.down
			}

			function activate() {
				if (paneOpened) {
					Global.mainView.cardsLoader.hide()
				} else {
					Global.mainView.showQuickAccess(model.pluginName, model.url)
				}
			}

			onClicked: {
				overflowPopup.close()
				activate()
			}

			// With key navigation, scroll the popup to the button that takes the focus.
			onActiveFocusChanged: {
				if (activeFocus && !inRow) {
					popupFlickable.ensureVisible(button)
				}
			}
		}
	}

	// A DelegateModel of the rows of the model from `from`, up to but not including `to`. The row
	// and the popup each have one, with the same model.
	//
	// The rows in that range are in the "visible" group, which is the group that the view shows.
	// _updateGroups() sets that group for every row of items, which has every row of the model in
	// order. A row is only added to or removed from the group when that changes, so the view keeps
	// the buttons of the rows that stay in the range, and those buttons keep the focus.
	//
	// It runs when the range changes, and when rows are inserted or removed. Note that count is
	// the number of rows in "visible", not in the model. The model inserts its rows before its
	// count (and so `to` and _rowButtonCount) changes, so the range can change after the rows do.
	component QuickAccessDelegateModel : DelegateModel {
		id: delegateModel

		property int from: 0
		property int to: 0

		function _updateGroups() {
			const rows = delegateModel.items
			for (let i = 0; i < rows.count; ++i) {
				const row = rows.get(i)
				const inRange = i >= delegateModel.from && i < delegateModel.to
				if (row.inVisible !== inRange) {
					row.inVisible = inRange
				}
			}
		}

		model: root.model
		delegate: buttonComponent
		groups: [
			// Every row is in this group, so its changed signal tells when rows are inserted or
			// removed.
			DelegateModelGroup {
				name: "all"
				includeByDefault: true
				onChanged: delegateModel._updateGroups()
			},
			DelegateModelGroup { name: "visible" }
		]
		filterOnGroup: "visible"

		onToChanged: _updateGroups()
		onFromChanged: _updateGroups()
		Component.onCompleted: _updateGroups()
	}

	Repeater {
		id: buttonRepeater

		model: QuickAccessDelegateModel {
			from: 0
			to: _rowButtonCount
		}
	}

	// Opens the popup with the buttons that are not in the row. It is shown while the popup has
	// any buttons to show. While the pane of one of the popup's buttons is open, the popup's
	// buttons are hidden like the row's, so this shows that button's icon instead, and closes the
	// pane when clicked.
	StatusBarButton {
		id: overflowButton

		readonly property int index: buttonRepeater.count
		// The button in the popup whose pane is open, if any. This is a var, as the properties
		// and functions it is used for are declared by the delegate, not StatusBarButton.
		readonly property var openedPopupButton: root._popupButtons.find(b => b.paneOpened) ?? null

		implicitWidth: Theme.geometry_statusBar_button_height + leftInset + rightInset
		leftInset: index === root._firstEdgeIndex ? root.firstLeftInset : root.buttonInset
		rightInset: index === root._lastEdgeIndex ? root.lastRightInset : root.buttonInset
		bottomInset: root.bottomInset

		enabled: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
		// Like the delegate's shown, so that shownSlotIndexes finds this button.
		readonly property bool shown: root._popupHasShownButtons

		visible: shown

		icon.source: openedPopupButton ? openedPopupButton.icon.source : "qrc:/images/icon_more_dots.svg"
		icon.cache: openedPopupButton ? openedPopupButton.buttonId !== "plugin" : true

		KeyNavigation.left: {
			const buttons = root.focusableButtons
			const i = buttons.indexOf(overflowButton)
			return i > 0 ? buttons[i - 1] : null
		}
		KeyNavigation.right: root.KeyNavigation.right
		KeyNavigation.down: overflowPopup.opened ? overflowPopup.firstFocusableButton : root.KeyNavigation.down

		Keys.onEscapePressed: (event) => {
			if (Global.keyNavigationEnabled && overflowPopup.opened) {
				event.accepted = true
				overflowPopup.close()
			} else {
				event.accepted = false
			}
		}

		onClicked: {
			if (openedPopupButton) {
				openedPopupButton.activate()
			} else if (overflowPopup.opened) {
				overflowPopup.close()
			} else {
				overflowPopup.open()
			}
		}
	}

	// A column of the buttons that are not in the row, shown below the overflow button. If the
	// column is taller than the space below the overflow button, it scrolls.
	T.Popup {
		id: overflowPopup

		// Whether to give the focus back to the overflow button when the popup is closed.
		property bool _restoreFocus: false

		property StatusBarButton firstFocusableButton: root._popupButtons.find(b => b.visible && b.enabled) ?? null

		parent: overflowButton
		x: overflowButton.leftInset
		y: overflowButton.height
		implicitWidth: implicitContentWidth + leftPadding + rightPadding
		implicitHeight: implicitContentHeight + topPadding + bottomPadding
		padding: Theme.geometry_button_border_width
		focus: true
		// Clicking the overflow button closes the popup, so do not also close it on that press.
		closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent

		// The y of the bottom of the window in the coordinates of the overflow button (the popup's
		// parent), set when the popup opens. The popup is no taller than the space from its top to
		// the bottom of the window; if its buttons need more, they scroll. The window is mapped
		// into local coordinates, rather than comparing window coordinates with local ones,
		// because the window content may be scaled and rotated (see Main.qml).
		property real _windowBottom: 0

		height: Math.min(implicitHeight,
				Math.max(0, _windowBottom - overflowButton.height - Theme.geometry_comboBox_verticalPadding))

		contentItem: Flickable {
			id: popupFlickable

			// Scrolls so that the item, a button in the column, is within the visible area.
			function ensureVisible(item) {
				if (item.y < contentY) {
					contentY = item.y
				} else if (item.y + item.height > contentY + height) {
					contentY = item.y + item.height - height
				}
			}

			implicitWidth: popupColumn.implicitWidth
			implicitHeight: popupColumn.implicitHeight
			contentWidth: popupColumn.implicitWidth
			contentHeight: popupColumn.implicitHeight
			flickableDirection: Flickable.VerticalFlick
			boundsBehavior: Flickable.StopAtBounds
			clip: true

			ScrollBar.vertical: ScrollBar {}

			Column {
				id: popupColumn

				Repeater {
					// The buttons of the other rows of the model.
					model: QuickAccessDelegateModel {
						from: _rowButtonCount
						to: root.model?.count ?? 0
					}

					// The removed button may have the focus, so close the popup, which gives the focus
					// back to the overflow button.
					onItemRemoved: overflowPopup.close()
				}
			}
		}

		background: Rectangle {
			color: Theme.color_background_secondary
		}

		onAboutToShow: {
			// The popup is placed at the bottom of the overflow button, so use the button's height
			// as the popup's top, rather than the popup's y, which may not yet be set.
			const windowRect = overflowButton.mapFromItem(null,
					Qt.rect(0, 0, overflowButton.Window.width, overflowButton.Window.height))
			_windowBottom = windowRect.y + windowRect.height
			popupFlickable.contentY = 0
		}
		onOpened: {
			if (Global.keyNavigationEnabled) {
				firstFocusableButton?.forceActiveFocus()
			}
		}
		onAboutToHide: _restoreFocus = Global.keyNavigationEnabled && activeFocus
		onClosed: {
			if (_restoreFocus && overflowButton.visible && overflowButton.enabled) {
				overflowButton.forceActiveFocus()
			}
			_restoreFocus = false
		}

		// Clicking a button in the popup opens or closes its pane, which hides the popup's buttons,
		// so close the popup then. Also close it when the overflow button is hidden or disabled,
		// e.g. when the UI goes idle.
		Connections {
			target: Global.mainView
			enabled: overflowPopup.opened
			function onCardsActiveChanged() {
				overflowPopup.close()
			}
		}
		Connections {
			target: overflowButton
			enabled: overflowPopup.opened
			function onVisibleChanged() {
				if (!overflowButton.visible) {
					overflowPopup.close()
				}
			}
			function onEnabledChanged() {
				if (!overflowButton.enabled) {
					overflowPopup.close()
				}
			}
		}
	}
}
