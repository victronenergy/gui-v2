/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import QtQuick.Templates as T
import Victron.VenusOS

Item { // Doesn't need to be a FocusScope, as we don't need key navigation in portrait layout.
	id: root

	required property PageStack pageStack

	// Repeater count changes before delegates exist. itemAt() is not a binding
	// dependency, so key chains must also read this counter (bumped by the repeater).
	property int quickAccessButtonReady: 0

	// ListModel.get() is not a binding dependency, so bindings that read
	// quickAccessOverflowModel entries also read this counter (bumped on rebuild).
	property int quickAccessOverflowRevision: 0

	// The number of fixed (controls/aux) entries at the start of quickAccessModel.
	readonly property int quickAccessFixedCount: 2

	// The number of plugin (or "more") buttons shown in quickAccessRow. If there are more plugins
	// than this, a single "more" button is shown instead, which lists them in a popup.
	readonly property int quickAccessPluginCapacity: 1

	// Index of the right-most visible quick access slot, or -1 if none are visible.
	readonly property int lastVisibleQuickAccessSlotIndex: {
		void quickAccessButtonReady
		for (let i = quickAccessRepeater.count - 1; i >= 0; --i) {
			const slot = quickAccessRepeater.itemAt(i)
			if (slot && slot.visible)
				return i
		}
		return -1
	}

	// Index of the right-most visible quick access button, or -1 if none are visible.
	readonly property int lastVisibleQuickAccessIndex: {
		for (let i = quickAccessRepeater.count - 1; i >= 0; --i) {
			const item = quickAccessItem(i)
			if (item && item.visible)
				return i
		}
		return -1
	}

	signal sidePanelToggled()

	// Returns the button of the quick access slot at the given index.
	function quickAccessItem(index) {
		void quickAccessButtonReady
		return quickAccessRepeater.itemAt(index)?.button ?? null
	}

	// Returns the first visible and enabled quick access button, searching from startIndex in the
	// given direction (1 = rightwards, -1 = leftwards), or null if there is none.
	function nextFocusableQuickAccessItem(startIndex, step) {
		for (let i = startIndex; i >= 0 && i < quickAccessRepeater.count; i += step) {
			const item = quickAccessItem(i)
			if (item && item.visible && item.enabled)
				return item
		}
		return null
	}

	// Returns the index in quickAccessOverflowModel of the plugin pane that is currently open, or
	// -1 if no overflow plugin pane is open.
	function openOverflowIndex() {
		void quickAccessOverflowRevision
		for (let i = 0; i < quickAccessOverflowModel.count; ++i) {
			if (Global.mainView.quickAccessOpen(quickAccessOverflowModel.get(i).pluginUrl)) {
				return i
			}
		}
		return -1
	}

	// Keeps the fixed controls/aux entries in place (so their delegates survive) and replaces the
	// plugin entries after them with the current QuickAccessPane integrations.
	// If there is only one plugin, its button is shown in the row. If there are more, a single
	// "more" button is shown instead, which lists the plugins in quickAccessOverflowModel.
	function rebuildQuickAccessModel() {
		const fixedCount = quickAccessFixedCount
		const needsOverflow = pluginQuickAccessModel.count > quickAccessPluginCapacity
		const maxQuickAccessPlugins = needsOverflow ? quickAccessPluginCapacity - 1 : quickAccessPluginCapacity
		if (quickAccessModel.count > fixedCount) {
			quickAccessModel.remove(fixedCount, quickAccessModel.count - fixedCount)
		}
		quickAccessOverflowModel.clear()

		for (let i = 0; i < pluginQuickAccessModel.count; ++i) {
			const integration = pluginQuickAccessModel.integrationAt(i)
			const entry = {
				buttonKind: "plugin",
				pluginName: integration.pluginName,
				pluginUrl: String(integration.url),
				pluginIcon: String(integration.icon),
				pluginIconActive: String(integration.iconActive)
			}
			if (needsOverflow && i >= maxQuickAccessPlugins) {
				quickAccessOverflowModel.append(entry)
			} else {
				quickAccessModel.append(entry)
			}
		}
		if (needsOverflow) {
			quickAccessModel.append({
				buttonKind: "more",
				pluginName: "",
				pluginUrl: "",
				pluginIcon: "qrc:/images/icon_more_dots.svg",
				pluginIconActive: ""
			})
		}
		quickAccessOverflowRevision++
	}

	Component.onCompleted: rebuildQuickAccessModel()

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_statusBar_height

	// Plugin cards for the Switches pane. The pane can be opened when it shows only these.
	GuiPluginIntegrationModel {
		id: pluginSwitchCards
		type: GuiPluginLoader.QuickAccessPaneCard
		cardType: GuiPluginLoader.SwitchesCard
	}

	RowLayout {
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: parent.bottom
		}
		spacing: 0

		StatusBarButton {
			id: backButton

			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing
			icon.source: "qrc:/images/icon_back_32.svg"
			enabled: breadcrumbs.enabled
			visible: breadcrumbs.visible
			opacity: breadcrumbs.opacity

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: root.nextFocusableQuickAccessItem(0, 1)
			onClicked: Global.pageManager.popPage()
		}

		Breadcrumbs {
			id: breadcrumbs

			pageStack: root.pageStack
			Layout.fillWidth: true
			Layout.topMargin: ((backButton.height - height) / 2) - Theme.geometry_statusBar_spacing/2
			Layout.alignment: Qt.AlignTop
		}

		Label {
			leftPadding: Theme.geometry_statusBar_horizontalMargin
			rightPadding: Theme.geometry_statusBar_spacing
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_body2
			fontSizeMode: Text.HorizontalFit
			text: Global.mainView?.currentPage?.title ?? ""
			visible: !breadcrumbs.visible

			Layout.fillWidth: true
			Layout.alignment: Qt.AlignTop
			Layout.preferredHeight: Theme.geometry_statusBar_button_height
		}

		StatusBarButton {
			id: notificationButton

			enabled: Services.notifications.statusBarNotificationIconVisible
			visible: !breadcrumbs.visible && enabled
			leftInset: Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_spacing / 2
			bottomInset: Theme.geometry_statusBar_spacing
			color: Services.notifications.statusBarNotificationIconColor
			icon.source: Services.notifications.statusBarNotificationIconSource

			Layout.alignment: Qt.AlignTop
			KeyNavigation.right: root.nextFocusableQuickAccessItem(0, 1)

			onClicked: Global.mainView.goToNotificationsPage()
		}

		// ── Quick Access (controls button, aux button, plugin buttons) ──
		// These are all delegates of quickAccessRepeater, populated from quickAccessModel.
		// Each button links to the previous/next visible and enabled button.
		GuiPluginIntegrationModel {
			id: pluginQuickAccessModel
			type: GuiPluginLoader.QuickAccessPane
			onModelReset: root.rebuildQuickAccessModel()
		}

		ListModel {
			id: quickAccessModel

			// Fixed entries. Plugin entries are appended by rebuildQuickAccessModel().
			ListElement { buttonKind: "controls"; pluginName: ""; pluginUrl: "ControlCardsPage.qml"; pluginIcon: "qrc:/images/icon_controls_off_32.svg"; pluginIconActive: "qrc:/images/icon_controls_on_32.svg" }
			ListElement { buttonKind: "aux"; pluginName: ""; pluginUrl: "AuxCardsPage.qml"; pluginIcon: "qrc:/images/icon_smartswitch_off_32.svg"; pluginIconActive: "qrc:/images/icon_smartswitch_on_32.svg" }
		}

		// Plugin entries that are not shown in quickAccessRow. These are listed in the popup
		// opened by the "more" button.
		ListModel {
			id: quickAccessOverflowModel
		}

		Row {
			id: quickAccessRow

			Layout.alignment: Qt.AlignTop

			Repeater {
				id: quickAccessRepeater

				model: quickAccessModel

				onItemAdded: root.quickAccessButtonReady++
				onItemRemoved: root.quickAccessButtonReady++

				// Each entry is a slot holding its button. The slot reserves the button's space in the
				// row whenever the button is available, even while it is hidden because a pane is open,
				// so that the button that opened the pane stays in place.
				delegate: Item {
					id: quickAccessSlot

					readonly property alias button: quickAccessButton

					required property int index
					required property string buttonKind
					required property string pluginName
					required property string pluginUrl
					required property string pluginIcon
					required property string pluginIconActive

					readonly property bool isControlsButton: buttonKind === "controls"
					readonly property bool isAuxButton: buttonKind === "aux"
					readonly property bool isPluginButton: buttonKind === "plugin"
					readonly property bool isMoreButton: buttonKind === "more"

					readonly property bool cardsActive: Global.mainView?.cardsActive ?? false

					// For the "more" button: the overflow plugin whose pane is open, or -1.
					readonly property int openOverflowIndex: isMoreButton ? root.openOverflowIndex() : -1
					readonly property var openOverflowEntry: {
						void root.quickAccessOverflowRevision
						return openOverflowIndex >= 0 ? quickAccessOverflowModel.get(openOverflowIndex) : null
					}

					readonly property int controlsButtonType: {
						if (!isControlsButton) {
							return VenusOS.StatusBar_LeftButton_None
						}
						return Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
					}

					// Whether this pane (controls, aux or plugin) is the one currently open. For the
					// "more" button, whether any of the overflow plugin panes is open.
					readonly property bool paneOpened: isMoreButton ? openOverflowIndex >= 0
							: Global.mainView.quickAccessOpen(pluginUrl)

					// The right inset reserved within the slot. The right-most slot reserves the
					// screen margin; a button in any other slot that becomes the right-most visible
					// button extends over the next (hidden) slot instead, so its icon does not move.
					readonly property real slotRightInset: root.lastVisibleQuickAccessSlotIndex === index
							? Theme.geometry_statusBar_horizontalMargin
							: Theme.geometry_statusBar_spacing / 2

					// Whether the button is available in the current context, regardless of whether
					// any pane is open. This decides whether the slot takes up space in the row.
					visible: {
						if (index === 0) { // Controls button
							return !breadcrumbs.enabled && controlsButtonType !== VenusOS.StatusBar_LeftButton_None
						}
						if (index === 1) { // Aux button
							return (!root.pageStack.opened
									&& (Services.ioChannels.groups.count > 0 || pluginSwitchCards.count > 0))
								|| paneOpened // allow cards to be closed if all switches are disconnected while opened
						}
						return Global.allPagesLoaded && !root.pageStack.opened
					}

					width: quickAccessButton.width - (quickAccessButton.rightInset - slotRightInset)
					height: quickAccessButton.height

					StatusBarButton {
						id: quickAccessButton

						// Expand clickable area on the bottom edge, and on the right edge for the
						// right-most visible button.
						leftInset: Theme.geometry_statusBar_spacing / 2
						rightInset: root.lastVisibleQuickAccessIndex === quickAccessSlot.index
								? Theme.geometry_statusBar_horizontalMargin
								: Theme.geometry_statusBar_spacing / 2
						bottomInset: Theme.geometry_statusBar_spacing

						// While a pane is open, only the button for that pane is shown.
						visible: !quickAccessSlot.cardsActive || quickAccessSlot.paneOpened
						enabled: {
							if (breadcrumbs.enabled) {
								return false
							}
							if (quickAccessSlot.isPluginButton || quickAccessSlot.isMoreButton) {
								return Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
							}
							return true
						}

						icon.cache: true
						icon.source: {
							// While an overflow plugin pane is open, the "more" button shows that
							// plugin's icon, and closes the pane when clicked.
							const entry = quickAccessSlot.openOverflowEntry
							if (entry) {
								return entry.pluginIconActive.length > 0 ? entry.pluginIconActive : entry.pluginIcon
							}
							return (quickAccessSlot.paneOpened && quickAccessSlot.pluginIconActive.length > 0) ? quickAccessSlot.pluginIconActive : quickAccessSlot.pluginIcon
						}

						KeyNavigation.left: root.nextFocusableQuickAccessItem(quickAccessSlot.index - 1, -1)
						KeyNavigation.right: root.nextFocusableQuickAccessItem(quickAccessSlot.index + 1, 1)

						onClicked: {
							if (quickAccessSlot.paneOpened) {
								Global.mainView.cardsLoader.hide()
							} else if (quickAccessSlot.isMoreButton) {
								overflowPopup.openFrom(quickAccessButton)
							} else {
								Global.mainView.showQuickAccess(quickAccessSlot.pluginName, quickAccessSlot.pluginUrl)
							}
						}
					}
				}
			}
		}
	}

	// Vertical list of the plugins that are not shown in quickAccessRow, dropped down from the
	// bottom of the "more" button.
	T.Popup {
		id: overflowPopup

		property StatusBarButton anchorButton

		function openFrom(button) {
			if (opened) {
				close()
				return
			}
			anchorButton = button
			parent = button
			open()
		}

		function focusEntry(index) {
			const item = overflowRepeater.itemAt(index)
			if (item) {
				item.focus = true
			}
		}

		x: anchorButton ? anchorButton.leftInset : 0
		y: anchorButton ? anchorButton.height - anchorButton.bottomInset : 0
		width: anchorButton ? anchorButton.width - anchorButton.leftInset - anchorButton.rightInset : 0
		padding: Theme.geometry_button_border_width
		focus: true

		contentItem: Column {
			Repeater {
				id: overflowRepeater

				model: quickAccessOverflowModel
				delegate: StatusBarButton {
					required property int index
					required property string pluginName
					required property string pluginUrl
					required property string pluginIcon

					width: overflowPopup.availableWidth
					icon.cache: true
					icon.source: pluginIcon
					enabled: Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive

					Keys.enabled: Global.keyNavigationEnabled
					Keys.onUpPressed: overflowPopup.focusEntry(index - 1)
					Keys.onDownPressed: overflowPopup.focusEntry(index + 1)

					onClicked: {
						overflowPopup.close()
						Global.mainView.showQuickAccess(pluginName, pluginUrl)
					}
				}
			}
		}

		background: Rectangle {
			width: Theme.geometry_statusBar_button_height
			height: quickAccessOverflowModel.count * Theme.geometry_statusBar_button_height
			color: Theme.color_background_secondary
		}

		onOpened: focusEntry(0)
		onClosed: {
			if (Global.keyNavigationEnabled && anchorButton && anchorButton.visible) {
				anchorButton.focus = true
			}
		}

		Connections {
			// Close the list if the "more" button is hidden, e.g. when a sub-page is opened.
			target: overflowPopup.anchorButton?.parent ?? null
			function onVisibleChanged() {
				if (!target.visible) {
					overflowPopup.close()
				}
			}
		}
	}
}
