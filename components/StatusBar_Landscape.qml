/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack

	signal controlCardsActivated()
	signal auxCardsActivated()
	signal cardsDeactivated()
	signal sidePanelToggled()

	function updateBreadcrumbsFocusHint() {
		// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
		// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
		if (leftButton.activeFocus || auxButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.LeftEdge
		} else if (rightButton.activeFocus || sleepButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.RightEdge
		} else {
			for (let i = 0; i < pluginRepeater.count; i++) {
				if (pluginRepeater.itemAt(i)?.activeFocus) {
					breadcrumbs.focusEdgeHint = Qt.LeftEdge
					return
				}
			}
			breadcrumbs.focusEdgeHint = -1
		}
	}

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
	// On the main page these are the left-most interactive items.
	// Internal chain: leftButton → auxButton → plugin(0) → … → plugin(n).
	// Zone exit (right): last visible item → wifiButton (zone 3).

	StatusBarButton {
		id: leftButton

		readonly property bool controlsPaneActive: (Global.mainView?.cardsActive ?? false)
				&& Global.mainView.cardsLoader.sourceComponent === Global.mainView.controlCardsComponent

		readonly property int buttonType: {
			if (controlsPaneActive) {
				return VenusOS.StatusBar_LeftButton_ControlsActive
			}
			if (pageStack.opened) {
				return VenusOS.StatusBar_LeftButton_Back
			}
			return Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
		}

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

		visible: !(Global.mainView?.cardsActive ?? false) || controlsPaneActive
				|| pageStack.opened
		icon.source: buttonType === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
			: buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
			: buttonType === VenusOS.StatusBar_LeftButton_Back ? "qrc:/images/icon_back_32.svg"
			: ""
		enabled: buttonType !== VenusOS.StatusBar_LeftButton_None
		KeyNavigation.right: auxButton

		onClicked: {
			switch (buttonType) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				root.controlCardsActivated()
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				root.cardsDeactivated()
				break;
			case VenusOS.StatusBar_LeftButton_Back:
				Global.pageManager.popPage()
				break
			default:
				break
			}
		}

		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}
	}

	StatusBarButton {
		id: auxButton

		readonly property bool auxCardsOpened: (Global.mainView?.cardsActive ?? false)
				&& Global.mainView.cardsLoader.sourceComponent === Global.mainView.auxCardsComponent

		// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
		anchors {
			left: leftButton.right
			leftMargin: -leftInset
		}
		leftInset: leftButton.visible ? 0 : Theme.geometry_statusBar_spacing
		rightInset: pluginPaneButtons.visible ? 0 : Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: (!root.pageStack.opened && Global.switches.groups.count > 0
				&& !(Global.mainView?.cardsActive ?? false))
				|| auxCardsOpened
		icon.source: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"

		Keys.onRightPressed: function(event) {
			if (pluginPaneButtons.visible && pluginRepeater.count > 0) {
				pluginRepeater.itemAt(0).forceActiveFocus()
			} else if (wifiButton.visible && wifiButton.enabled) {
				wifiButton.forceActiveFocus()
			}
			event.accepted = true
		}

		onClicked: {
			if (auxCardsOpened) {
				root.cardsDeactivated()
			} else {
				root.auxCardsActivated()
			}
		}

		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}
	}

	GuiPluginIntegrationModel {
		id: pluginQuickAccessModel
		type: GuiPluginLoader.QuickAccessPane
	}

	Row {
		id: pluginPaneButtons

		anchors.left: auxButton.right
		visible: !root.pageStack.opened && pluginQuickAccessModel.count > 0

		Repeater {
			id: pluginRepeater

			model: pluginQuickAccessModel

			delegate: StatusBarButton {
				id: pluginPaneButton

				required property int index
				required property string pluginName
				required property url url
				readonly property url pluginIcon: pluginQuickAccessModel.integrationAt(index).icon
				readonly property url pluginIconActive: pluginQuickAccessModel.integrationAt(index).iconActive

				readonly property bool paneOpened: Global.mainView.cardsActive
						&& Global.mainView.cardsLoader.sourceComponent === _paneComponent

				activeFocusOnTab: true
				visible: !(Global.mainView?.cardsActive ?? false) || paneOpened
				rightInset: Theme.geometry_statusBar_spacing
				bottomInset: Theme.geometry_statusBar_spacing
				icon.cache: false
				icon.source: (paneOpened && String(pluginIconActive).length > 0)
						? pluginPaneButton.pluginIconActive : pluginPaneButton.pluginIcon

				Keys.onLeftPressed: function(event) {
					if (index > 0) {
						pluginRepeater.itemAt(index - 1).forceActiveFocus()
					} else if (auxButton.visible) {
						auxButton.forceActiveFocus()
					} else if (leftButton.visible && leftButton.enabled) {
						leftButton.forceActiveFocus()
					}
					event.accepted = true
				}
				Keys.onRightPressed: function(event) {
					if (index < pluginRepeater.count - 1) {
						pluginRepeater.itemAt(index + 1).forceActiveFocus()
					} else if (wifiButton.visible && wifiButton.enabled) {
						wifiButton.forceActiveFocus()
					}
					event.accepted = true
				}

				onActiveFocusChanged: {
					if (activeFocus) {
						root.updateBreadcrumbsFocusHint()
					}
				}

				onClicked: {
					if (paneOpened) {
						Global.mainView.cardsLoader.hide()
					} else {
						Global.mainView.cardsLoader.show(_paneComponent)
					}
				}

				Component {
					id: _paneComponent

					Page {
						title: pluginPaneButton.pluginName
						focusPolicy: Qt.TabFocus

						onActiveFocusChanged: {
							if (activeFocus && Global.keyNavigationEnabled && _paneContentLoader.item) {
								_paneContentLoader.item.forceActiveFocus()
							}
						}

						Loader {
							id: _paneContentLoader
							anchors.fill: parent
							source: pluginPaneButton.url
						}
					}
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
			left: pluginPaneButtons.visible ? pluginPaneButtons.right : auxButton.visible ? auxButton.right : leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		pageStack: root.pageStack

		KeyNavigation.left: leftButton
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

			Keys.onLeftPressed: function(event) {
				if (pluginPaneButtons.visible && pluginRepeater.count > 0) {
					pluginRepeater.itemAt(pluginRepeater.count - 1).forceActiveFocus()
				} else if (auxButton.visible) {
					auxButton.forceActiveFocus()
				} else if (leftButton.visible && leftButton.enabled) {
					leftButton.forceActiveFocus()
				}
				event.accepted = true
			}
			KeyNavigation.right: mobileButton

			onClicked: Global.mainView.goToConnectivityPage("wifi")

			VeQuickItem {
				id: signalStrength

				uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/SignalStrength"
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
		visible: !breadcrumbs.visible && (Global.notifications?.statusBarNotificationIconVisible ?? false)

		color: Global.notifications?.statusBarNotificationIconColor ?? "transparent"
		icon.source: Global.notifications?.statusBarNotificationIconSource ?? ""

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
				if (leftButton.visible && leftButton.enabled) { leftButton.focus = true; return }
				if (auxButton.visible && auxButton.enabled) { auxButton.focus = true; return }
				for (let i = 0; i < pluginRepeater.count; i++) {
					let btn = pluginRepeater.itemAt(i)
					if (btn && btn.visible) { btn.focus = true; return }
				}
				for (const button of [breadcrumbs, wifiButton, mobileButton, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.visible && button.enabled) { button.focus = true; return }
				}
			}
		}
	}
}
