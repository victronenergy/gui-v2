/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack

	signal sidePanelToggled()

	function updateBreadcrumbsFocusHint() {
		// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
		// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
		if (backButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.LeftEdge
		} else if (rightButton.activeFocus || sleepButton.activeFocus) {
			breadcrumbs.focusEdgeHint = Qt.RightEdge
		} else {
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

	// ── Zone 1: Back button (sub-pages) and Quick Access (control, aux, plugin buttons) ──
	// On sub-pages, only the back button is shown. On the main page, the quick access buttons are
	// the left-most interactive items.
	// Internal chain: control → aux → plugin(0) → … → plugin(n).
	// Zone exit (right): back button or last visible quick access button → breadcrumbs (zone 2)
	// or wifiButton (zone 3).

	StatusBarButton {
		id: backButton

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

		visible: root.pageStack.opened
		enabled: visible
		icon.source: "qrc:/images/icon_back_32.svg"

		KeyNavigation.right: breadcrumbs

		onClicked: Global.pageManager.popPage()
		onActiveFocusChanged: {
			if (activeFocus) {
				root.updateBreadcrumbsFocusHint()
			}
		}
	}

	QuickAccessView {
		id: quickAccessView

		anchors.left: parent.left
		firstLeftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing
		visible: !root.pageStack.opened

		model: Global.mainView?.cardsLoader.quickAccessModel ?? null
		KeyNavigation.right: wifiButton
	}

	// ── Zone 2: Breadcrumbs (sub-pages only) ──
	// Visible only when pageStack.opened (sub-page navigation).
	// On sub-pages, quick-access and connectivity zones are hidden,
	// so breadcrumbs links only to backButton and rightButtonRow.

	Breadcrumbs {
		id: breadcrumbs

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			// On sub-pages the quick access buttons are hidden, so place the breadcrumbs directly after
			// backButton instead of after the empty quick access slots.
			left: backButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		pageStack: root.pageStack

		KeyNavigation.left: backButton
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

			KeyNavigation.left: root.pageStack.opened ? breadcrumbs
							: quickAccessView.lastFocusableButton
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

			KeyNavigation.left: wifiButton
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
				if (backButton.visible && backButton.enabled) { backButton.focus = true; return }
				const quickAccessButton = quickAccessView.firstFocusableButton
				if (quickAccessButton) { quickAccessButton.focus = true; return }
				for (const button of [breadcrumbs, wifiButton, mobileButton, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.visible && button.enabled) { button.focus = true; return }
				}
			}
		}
	}
}
