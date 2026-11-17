/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item { // Doesn't need to be a FocusScope, as we don't need key navigation in portrait layout.
	id: root

	required property PageStack pageStack

	// Repeater count changes before delegates exist. itemAt() is not a binding
	// dependency, so key chains must also read this counter (bumped by the repeater).
	property int quickAccessButtonReady: 0

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

	// Keeps the fixed controls/aux entries in place (so their delegates survive) and replaces the
	// plugin entries after them with the current QuickAccessPane integrations.
	function rebuildQuickAccessModel() {
		const fixedCount = 2
		if (quickAccessModel.count > fixedCount) {
			quickAccessModel.remove(fixedCount, quickAccessModel.count - fixedCount)
		}
		for (let i = 0; i < pluginQuickAccessModel.count; ++i) {
			const integration = pluginQuickAccessModel.integrationAt(i)
			quickAccessModel.append({
				buttonKind: "plugin",
				pluginName: integration.pluginName,
				pluginUrl: String(integration.url),
				pluginIcon: String(integration.icon),
				pluginIconActive: String(integration.iconActive)
			})
		}
	}

	Component.onCompleted: rebuildQuickAccessModel()

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_statusBar_height

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

					readonly property bool cardsActive: Global.mainView?.cardsActive ?? false

					readonly property int controlsButtonType: {
						if (!isControlsButton) {
							return VenusOS.StatusBar_LeftButton_None
						}
						return Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
					}

					// Whether this pane (controls, aux or plugin) is the one currently open.
					readonly property bool paneOpened: Global.mainView.quickAccessOpen(pluginUrl)

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
							return (!root.pageStack.opened && Services.ioChannels.groups.count > 0)
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
							if (quickAccessSlot.isPluginButton) {
								return Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
							}
							return true
						}

						icon.cache: true
						icon.source: (quickAccessSlot.paneOpened && quickAccessSlot.pluginIconActive.length > 0) ? quickAccessSlot.pluginIconActive : quickAccessSlot.pluginIcon

						KeyNavigation.left: root.nextFocusableQuickAccessItem(quickAccessSlot.index - 1, -1)
						KeyNavigation.right: root.nextFocusableQuickAccessItem(quickAccessSlot.index + 1, 1)

						onClicked: {
							if (quickAccessSlot.paneOpened) {
								Global.mainView.cardsLoader.hide()
							} else {
								Global.mainView.showQuickAccess(quickAccessSlot.pluginName, quickAccessSlot.pluginUrl)
							}
						}
					}
				}
			}
		}
	}
}
