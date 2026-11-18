/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack

	// Repeater count changes before delegates exist. itemAt() is not a binding
	// dependency, so key chains must also read this counter (bumped by the repeater).
	property int quickAccessButtonReady: 0

	// ListModel.get() is not a binding dependency, so bindings that read
	// quickAccessOverflowModel entries also read this counter (bumped on rebuild).
	property int quickAccessOverflowRevision: 0

	// The left button is always the first entry in quickAccessModel.
	readonly property Item leftButton: quickAccessItem(0)

	// Index of the left-most visible quick access button, or -1 if none are visible.
	readonly property int firstVisibleQuickAccessIndex: nextVisibleQuickAccessIndex(0)

	// The number of plugin (or "more") buttons that fit in quickAccessRow, after the fixed
	// left/aux buttons, without overlapping the clock label. Always at least 1, so that the
	// "more" button can be shown if no plugin buttons fit.
	readonly property int quickAccessPluginCapacity: {
		void quickAccessButtonReady
		let fixedWidth = 0
		for (let i = 0; i < quickAccessFixedCount; ++i) {
			const slot = quickAccessRepeater.itemAt(i)
			if (slot && slot.visible) {
				fixedWidth += slot.width
			}
		}
		const availableWidth = clockLabel.x - Theme.geometry_statusBar_spacing - fixedWidth
		return Math.max(1, Math.floor(availableWidth / Theme.geometry_statusBar_button_height))
	}

	// The number of fixed (left/aux) entries at the start of quickAccessModel.
	readonly property int quickAccessFixedCount: 2

	onQuickAccessPluginCapacityChanged: rebuildQuickAccessModel()

	signal sidePanelToggled()

	function firstFocusable(candidates) {
		for (let i = 0; i < candidates.length; ++i) {
			const b = candidates[i]
			if (b && b.visible && b.enabled)
				return b
		}
		return null
	}

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

	function nextVisibleQuickAccessIndex(startIndex) {
		for (let i = startIndex; i < quickAccessRepeater.count; ++i) {
			const item = quickAccessItem(i)
			if (item && item.visible)
				return i
		}
		return -1
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

	// Keeps the fixed left/aux entries in place (so their delegates and focus survive) and
	// replaces the plugin entries after them with the current QuickAccessPane integrations.
	// As many plugin buttons are shown in the row as fit in the space to the left of the clock
	// (quickAccessPluginCapacity); if not all of them fit, the last slot is used for a "more"
	// button instead, which lists the remaining plugins in quickAccessOverflowModel.
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

	function updateBreadcrumbsFocusHint() {
		// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
		// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
		if (rightButton.activeFocus || sleepButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.RightEdge
			return
		}
		for (let i = 0; i < quickAccessRepeater.count; i++) {
			if (quickAccessItem(i)?.activeFocus) {
				breadcrumbs.focusEdgeHint = Qt.LeftEdge
				return
			}
		}
		breadcrumbs.focusEdgeHint = -1
	}

	Component.onCompleted: rebuildQuickAccessModel()

	implicitWidth: Theme.geometry_screen_width
	implicitHeight: Theme.geometry_statusBar_height

	component NotificationButton : Button {
		readonly property bool animating: animator.running

		opacity: enabled ? 1 : 0
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_caption
		Behavior on opacity {
			enabled: Global.animationEnabled
			OpacityAnimator {
				id: animator
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}

	// ── Zone 1: Quick Access (leftButton, auxButton, plugin buttons) ──
	// On the main page these are the left-most interactive items. They are all delegates of
	// quickAccessRepeater, populated from quickAccessModel.
	// Internal chain: each button links to the previous/next visible and enabled button.
	// Zone exit (right): last visible item → wifiButton (zone 3).

	GuiPluginIntegrationModel {
		id: pluginQuickAccessModel
		type: GuiPluginLoader.QuickAccessPane
		onModelReset: root.rebuildQuickAccessModel()
	}

	ListModel {
		id: quickAccessModel

		// Fixed entries. Plugin entries are appended by rebuildQuickAccessModel().
		ListElement { buttonKind: "left"; pluginName: ""; pluginUrl: "ControlCardsPage.qml"; pluginIcon: "qrc:/images/icon_controls_off_32.svg"; pluginIconActive: "qrc:/images/icon_controls_on_32.svg" }
		ListElement { buttonKind: "aux"; pluginName: ""; pluginUrl: "AuxCardsPage.qml"; pluginIcon: "qrc:/images/icon_smartswitch_off_32.svg"; pluginIconActive: "qrc:/images/icon_smartswitch_on_32.svg" }
	}

	// Plugin entries that do not fit in quickAccessRow. These are listed in the popup opened by
	// the "more" button.
	ListModel {
		id: quickAccessOverflowModel
	}

	Row {
		id: quickAccessRow

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

				readonly property bool isLeftButton: buttonKind === "left"
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

				readonly property int leftButtonType: {
					if (!isLeftButton) {
						return VenusOS.StatusBar_LeftButton_None
					}
					if (root.pageStack.opened) {
						return VenusOS.StatusBar_LeftButton_Back
					}
					return Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
				}

				// Whether this pane (controls, aux or plugin) is the one currently open. For the
				// "more" button, whether any of the overflow plugin panes is open.
				readonly property bool paneOpened: isMoreButton ? openOverflowIndex >= 0
						: Global.mainView.quickAccessOpen(pluginUrl)

				// Whether the button is available in the current context, regardless of whether
				// any pane is open. This decides whether the slot takes up space in the row.
				visible: {
					if (isLeftButton) {
						return true
					}
					if (isAuxButton) {
						return (!root.pageStack.opened && Services.ioChannels.groups.count > 0)
							|| paneOpened // allow cards to be closed if all switches are disconnected while opened
					}
					return Global.allPagesLoaded && !root.pageStack.opened
				}
				// The button may extend to the left of the slot to expand its clickable area.
				width: quickAccessButton.width + quickAccessButton.x
				height: quickAccessButton.height

				StatusBarButton {
					id: quickAccessButton

					// Expand clickable area on the bottom edge, and on the left edge for the left-most
					// button (or for the first visible button, if the left button is hidden). The left
					// button reserves its margin within its slot; other buttons extend over the
					// previous (hidden) slot, so that their icons do not move.
					x: quickAccessSlot.isLeftButton ? 0 : -leftInset
					leftInset: quickAccessSlot.isLeftButton ? Theme.geometry_statusBar_horizontalMargin
							: root.firstVisibleQuickAccessIndex === quickAccessSlot.index ? Theme.geometry_statusBar_spacing
							: 0
					bottomInset: Theme.geometry_statusBar_spacing

					// While a pane is open, only the button for that pane is shown (and the
					// back button, when a sub-page is open).
					visible: !quickAccessSlot.cardsActive || quickAccessSlot.paneOpened
							|| (quickAccessSlot.isLeftButton && root.pageStack.opened)
					enabled: quickAccessSlot.isLeftButton ? quickAccessSlot.leftButtonType !== VenusOS.StatusBar_LeftButton_None
							: (quickAccessSlot.isPluginButton || quickAccessSlot.isMoreButton) ? Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
							: true

					icon.cache: true
					icon.source: {
						if (quickAccessSlot.leftButtonType === VenusOS.StatusBar_LeftButton_Back) {
							return "qrc:/images/icon_back_32.svg"
						}
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
							?? root.firstFocusable([wifiButton, mobileButton, notificationButton, alarmButton, rightButton, sleepButton])

					onClicked: {
						if (quickAccessSlot.leftButtonType === VenusOS.StatusBar_LeftButton_Back) {
							Global.pageManager.popPage()
						} else if (quickAccessSlot.paneOpened) {
							Global.mainView.cardsLoader.hide()
						} else if (quickAccessSlot.isMoreButton) {
							overflowPopup.openFrom(quickAccessButton)
						} else {
							Global.mainView.showQuickAccess(quickAccessSlot.pluginName, quickAccessSlot.pluginUrl)
						}
					}

					onActiveFocusChanged: {
						if (activeFocus) {
							root.updateBreadcrumbsFocusHint()
						}
					}
				}
			}
		}
	}

	// Vertical list of the plugins that do not fit in quickAccessRow, dropped down from the
	// bottom of the "more" button.
	T.Popup {
		id: overflowPopup

		property StatusBarButton anchorButton

		function openFrom(button) {
			if (opened) {
				console.log("opened")
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
			border.color: Theme.color_brand
			border.width: Theme.geometry_button_border_width
			radius: Theme.geometry_button_radius
			// Use an opaque colour so the page content below does not show through the list.
			// (color_page_background comes from branding and may be transparent.)
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

	// ── Zone 2: Breadcrumbs (sub-pages only) ──
	// Visible only when pageStack.opened (sub-page navigation).
	// On sub-pages, quick-access and connectivity zones are hidden,
	// so breadcrumbs links only to leftButton (back) and rightButtonRow.

	Breadcrumbs {
		id: breadcrumbs

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: quickAccessRow.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		pageStack: root.pageStack

		KeyNavigation.left: root.leftButton
		KeyNavigation.right: rightButton

		Rectangle { // fade out the breadcrumbs RHS when overflowing
			width: parent.width
			height: Theme.geometry_settings_breadcrumb_height
			visible: !parent.atXEnd

			gradient: Gradient {
				orientation: Gradient.Horizontal

				GradientStop {
					position: 1 - Theme.geometry_breadcrumbs_viewGradient_width
					color: Theme.color_viewGradient_color1
				}
				GradientStop {
					position: 1 - Theme.geometry_breadcrumbs_viewGradient_width / 2
					color: Theme.color_viewGradient_color2
				}
				GradientStop {
					position: 1
					color: Theme.color_viewGradient_color3
				}
			}
		}
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: Theme.font_size_body2
		visible: !breadcrumbs.visible
		text: ClockTime.currentTime
	}

	// ── Zone 3: Connectivity (wifi, mobile, notification, alarm) ──
	// Visible only on the main page (!breadcrumbs.visible).
	// Internal chain: wifiButton → mobileButton → notificationButton → alarmButton.
	// Zone entry (left): wifiButton ← last item of zone 1.
	// Zone exit (right): alarmButton → rightButton (zone 4).

	Row {
		id: connectivityRow

		anchors {
			left: clockLabel.right
			leftMargin: Theme.geometry_statusBar_spacing
			verticalCenter: parent.verticalCenter
		}
		visible: !breadcrumbs.visible

		StatusBarButton {
			id: wifiButton

			opacity: enabled ? 1.0 : 0.0 //  Override fading icon on unit inactivity
			color: Theme.color_font_primary // Override base button color
			enabled: signalStrength.valid

			icon.source: !signalStrength.valid ? ""
				: signalStrength.value > 75 ? "qrc:/images/icon_WiFi_4_32.svg"
				: signalStrength.value > 50 ? "qrc:/images/icon_WiFi_3_32.svg"
				: signalStrength.value > 25 ? "qrc:/images/icon_WiFi_2_32.svg"
				: signalStrength.value > 0 ? "qrc:/images/icon_WiFi_1_32.svg"
				: "qrc:/images/icon_WiFi_noconnection_32.svg"

			KeyNavigation.left: root.nextFocusableQuickAccessItem(quickAccessRepeater.count - 1, -1)
			KeyNavigation.right: mobileButton

			onClicked: Global.mainView.goToConnectivityPage("wifi")

			VeQuickItem {
				id: signalStrength

				uid: Services.platform.serviceUid +  "/Network/Wifi/SignalStrength"
			}
		}

		StatusBarButton {
			id: mobileButton

			opacity: enabled ? 1.0 : 0.0 //  Override fading icon on unit inactivity
			visible: mobileIcon.valid

			KeyNavigation.right: notificationButton

			onClicked: Global.mainView.goToConnectivityPage("mobile")

			GsmStatusIcon {
				id: mobileIcon
				height: Theme.geometry_status_bar_gsmModem_icon_height
				anchors.centerIn: parent
			}
		}
	}

	StatusBarButton {
		id: notificationButton

		anchors {
			left: connectivityRow.right
			verticalCenter: parent.verticalCenter
		}
		// Expand clickable area on vertical and bottom edges.
		rightInset: Theme.geometry_statusBar_spacing / 2
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		// The notificationButton should always be shown, even when the page is not interactive
		opacity: 1
		visible: !breadcrumbs.visible && Services.notifications.statusBarNotificationIconVisible

		color: Services.notifications.statusBarNotificationIconColor
		icon.source: Services.notifications.statusBarNotificationIconSource

		onClicked: Global.mainView.goToNotificationsPage()
		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}

		KeyNavigation.right: alarmButton
	}

	SilenceAlarmButton {
		id: alarmButton

		anchors {
			left: notificationButton.right
			verticalCenter: parent.verticalCenter
		}
		width: Math.min(parent.width - x - rightButtonRow.width, implicitWidth)
		// Expand clickable area on horizontal and bottom edges.
		leftInset: Theme.geometry_statusBar_spacing / 2
		rightInset: Theme.geometry_statusBar_spacing / 2
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing
		enabled: Global.mainView?.notificationButtonsEnabled
		visible: enabled
		KeyNavigation.right: rightButton.visible && rightButton.enabled ? rightButton : sleepButton

		onClicked: NotificationModel.acknowledgeAll()
	}

	// ── Zone 4: Right buttons (side panel, sleep) ──

	Row {
		id: rightButtonRow

		height: parent.height
		anchors.right: parent.right

		StatusBarButton {
			id: rightButton

			readonly property int buttonType: Global.mainView?.currentPage?.topRightButton ?? VenusOS.StatusBar_RightButton_None

			// Expand clickable area on left and bottom edges.
			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing

			enabled: buttonType != VenusOS.StatusBar_RightButton_None
			visible: enabled
			icon.source: buttonType === VenusOS.StatusBar_RightButton_SidePanelActive
						 ? "qrc:/images/icon_sidepanel_on_32.svg"
						 : buttonType === VenusOS.StatusBar_RightButton_SidePanelInactive
						   ? "qrc:/images/icon_sidepanel_off_32.svg"
						   : buttonType === VenusOS.StatusBar_RightButton_Add
							 ? "qrc:/images/icon_plus.svg"
							 : buttonType === VenusOS.StatusBar_RightButton_Refresh
							   ? "qrc:/images/icon_refresh_32.svg"
							   : ""
			KeyNavigation.left: alarmButton
			KeyNavigation.right: sleepButton

			onClicked: root.sidePanelToggled()
			onActiveFocusChanged: {
				if (activeFocus) {
					root.updateBreadcrumbsFocusHint()
				}
			}
		}

		StatusBarButton {
			id: sleepButton

			// Expand clickable area on right and bottom edges, and on left edge if right button is
			// hidden. This is the right-most button in the row, so on the right edge, use
			// Theme.geometry_statusBar_horizontalMargin instead of Theme.geometry_statusBar_spacing.
			leftInset: rightButton.visible ? 0 : Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: ScreenBlanker.supported && ScreenBlanker.enabled
			KeyNavigation.left: rightButton.visible && rightButton.enabled ? rightButton : alarmButton

			onClicked: ScreenBlanker.setDisplayOff()
			onActiveFocusChanged: {
				if (activeFocus) {
					root.updateBreadcrumbsFocusHint()
				}
			}
		}
	}

	// The status bar should never become the focused item; if it does, it means there was no
	// previously focused button in the status bar, or the last focused button is now disabled and
	// not focusable. So, find the first available button and focus that instead.
	Connections {
		target: Global.main
		enabled: Global.keyNavigationEnabled
		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem === root) {
				const quickAccessButton = root.nextFocusableQuickAccessItem(0, 1)
				if (quickAccessButton) { quickAccessButton.focus = true; return }
				for (const button of [breadcrumbs, wifiButton, mobileButton, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.visible && button.enabled) { button.focus = true; return }
				}
			}
		}
	}
}
