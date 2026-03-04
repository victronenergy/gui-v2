/*
** Copyright (C) 2025 Victron Energy B.V.
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
			// Focus is coming elsewhere, so do not change the current index
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

	StatusBarButton {
		id: leftButton

		readonly property int buttonType: {
			const customButton = Global.mainView.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
			if (customButton === VenusOS.StatusBar_LeftButton_None && pageStack.opened) {
				return VenusOS.StatusBar_LeftButton_Back
			}
			return customButton
		}

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

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

		readonly property bool auxCardsOpened: Global.mainView.cardsActive
				&& leftButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive

		// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
		anchors {
			left: leftButton.right
			leftMargin: -leftInset
		}
		leftInset: leftButton.enabled ? 0 : Theme.geometry_statusBar_spacing
		rightInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: (!root.pageStack.opened && Global.switches.groups.count > 0)
				|| auxCardsOpened // allow cards to be closed if all switches are disconnected while opened
		icon.source: leftButton.buttonType === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
				: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"
		enabled: leftButton.buttonType !== VenusOS.StatusBar_LeftButton_ControlsActive
		KeyNavigation.right: breadcrumbs

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

	Breadcrumbs {
		id: breadcrumbs

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		pageStack: root.pageStack

		KeyNavigation.right: notificationButton

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

	Row {
		id: connectivityRow

		anchors {
			left: clockLabel.right
			leftMargin: Theme.geometry_statusBar_spacing
			verticalCenter: parent.verticalCenter
		}
		visible: !breadcrumbs.visible
		spacing: Theme.geometry_statusBar_spacing

		CP.IconImage {
			anchors.verticalCenter: parent.verticalCenter
			color: Theme.color_font_primary
			source: {
				if (!signalStrength.valid) {
					return ""
				} else if (signalStrength.value > 75) {
					return "qrc:/images/icon_WiFi_4_32.svg"
				} else if (signalStrength.value > 50) {
					return "qrc:/images/icon_WiFi_3_32.svg"
				} else if (signalStrength.value > 25) {
					return "qrc:/images/icon_WiFi_2_32.svg"
				} else if (signalStrength.value > 0) {
					return "qrc:/images/icon_WiFi_1_32.svg"
				} else {
					return "qrc:/images/icon_WiFi_noconnection_32.svg"
				}
			}

			VeQuickItem {
				id: signalStrength

				uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/SignalStrength"
			}
		}

		GsmStatusIcon {
			height: Theme.geometry_status_bar_gsmModem_icon_height
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	StatusBarButton {
		id: notificationButton

		anchors {
			left: connectivityRow.right
			leftMargin: Theme.geometry_statusBar_spacing
		}
		// Expand clickable area on right and bottom edges.
		rightInset: Theme.geometry_statusBar_spacing / 2
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

	NotificationButton {
		id: alarmButton

		anchors {
			left: notificationButton.right
			verticalCenter: parent.verticalCenter
		}
		// Expand clickable area on horizontal and bottom edges.
		leftInset: Theme.geometry_statusBar_spacing / 2
		leftPadding: leftInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		rightInset: Theme.geometry_statusBar_spacing / 2
		rightPadding: rightInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		enabled: Global.mainView?.notificationButtonsEnabled
		flat: false
		backgroundColor: down ? Theme.color_critical : Theme.color_critical_background
		borderWidth: 0
		// ensure highlight border can be seen against critical backgroundColor
		KeyNavigationHighlight.margins: -(4 * Theme.geometry_button_border_width)
		icon.source: "qrc:/images/icon_alarm_snooze_24.svg"
		text: CommonWords.silence_alarm

		onClicked: NotificationModel.acknowledgeAll()

		Binding {
			target: Global.notifications ?? null
			property: "notificationButtonVisible"
			value: alarmButton.enabled || alarmButton.animating
		}
	}

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
			visible: enabled
			enabled: ScreenBlanker.supported
					&& ScreenBlanker.enabled
					&& Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive

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
				for (const button of [leftButton, auxButton, breadcrumbs, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.enabled) {
						button.focus = true
						break
					}
				}
			}
		}
	}
}
