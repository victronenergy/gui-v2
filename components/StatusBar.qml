/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack
	property string title
	property alias backgroundColor: backgroundRect.color

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None
	readonly property bool notificationButtonsEnabled: Global.mainView.currentPage && !!Global.mainView.currentPage.url && Global.mainView.currentPage.url.endsWith("NotificationsPage.qml")
	readonly property bool notificationButtonVisible: alarmButton.enabled || alarmButton.animating

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()
	signal auxButtonClicked()
	signal popToPage(toPage: Page)

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0

	Rectangle {
		id: backgroundRect
		anchors.fill: parent
	}

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation_statusBar_initialize_delayedStart_duration
		}
		OpacityAnimator {
			target: root
			from: 0.0
			to: 1.0
			duration: Theme.animation_statusBar_initialize_fade_duration
		}
	}

	component StatusBarButton : Button {
		radius: 0
		width: parent.height
		height: parent.height
		backgroundColor: "transparent"  // don't show background when disabled
		display: C.AbstractButton.IconOnly
		color: Theme.color_ok
		opacity: enabled && Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}
	}

	component NotificationButton : Button {
		readonly property bool animating: animator.running

		leftPadding: Theme.geometry_silenceAlarmButton_horizontalPadding
		rightPadding: Theme.geometry_silenceAlarmButton_horizontalPadding
		height: Theme.geometry_notificationsPage_snoozeButton_height
		radius: Theme.geometry_button_radius
		opacity: enabled ? 1 : 0
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_caption
		Behavior on opacity {
			OpacityAnimator {
				id: animator

				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}

	StatusBarButton {
		id: leftButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_statusBar_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_Back ? "qrc:/images/icon_back_32.svg"
			: ""
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_None

		onClicked: root.leftButtonClicked()
	}

	StatusBarButton {
		id: auxButton

		readonly property bool auxCardsOpened: Global.mainView.cardsActive
				&& root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive

		anchors {
			left: leftButton.right
			verticalCenter: parent.verticalCenter
		}
		visible: (root.pageStack.depth === 0 && Global.switches.groups.count > 0)
				|| auxCardsOpened // allow cards to be closed if all switches are disconnected while opened
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
				: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive

		onClicked: root.auxButtonClicked()
	}


	Breadcrumbs {
		id: breadcrumbs

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
			verticalCenter: leftButton.verticalCenter
		}
		height: Theme.geometry_settings_breadcrumb_height
		model: root.pageStack.depth + 1 // '+ 1' because we insert a dummy breadcrumb with the text "Settings"
		visible: count >= 2

		getText: function(index) {
			return index === 0
					? Global.pageManager.navBar.activeButtonText // eg: "Settings"
					: pageStack.get(index - 1).title // eg: "Device list"
		}

		onClicked: function(index) {
			const isTopBreadcrumb = index === breadcrumbs.count - 1
			const isBottomBreadcrumb = index === 0

			if (isBottomBreadcrumb) { // the bottom breadcrumb is a special case, we inserted a dummy breadcrumb with the text "Settings" which doesn't relate to anything in the pageStack
				Global.pageManager.popAllPages()
				return
			}

			if (isTopBreadcrumb) { // ignore clicks on the top of the breadcrumb trail. We don't need to navigate there, we are already there...
				return
			}

			root.popToPage(pageStack.get(index - 1)) // subtract 1, because we inserted a dummy "Settings" breadcrumb at the beginning
		}
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		visible: !breadcrumbs.visible
		text: ClockTime.currentTime
	}

	Row {
		id: connectivityRow

		anchors {
			left: clockLabel.right
			leftMargin: Theme.geometry_statusBar_rightSideRow_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		visible: !breadcrumbs.visible
		spacing: Theme.geometry_statusBar_rightSideRow_horizontalMargin

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

		CP.IconImage {
			id: notificationIcon

			anchors.verticalCenter: parent.verticalCenter
			visible: Global.notifications?.statusBarNotificationIconVisible ?? false
			color: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Alarm
				   ? Theme.color_critical
				   : Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Warning
					 ? Theme.color_warning :
					   Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ? Theme.color_ok : notificationIcon.color
			source: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ?
						"qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		}
	}

	Row {
		id: rightSideRow
		anchors {
			right: rightButtonRow.left
			rightMargin: Theme.geometry_statusBar_rightSideRow_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		width: Math.max(20, implicitWidth)
	}

	NotificationButton {
		id: alarmButton

		anchors {
			right: rightSideRow.right
			verticalCenter: parent.verticalCenter
		}
		enabled: notificationButtonsEnabled && (Global.notifications?.silenceAlarmVisible ?? false)
		backgroundColor: Theme.color_critical_background
		icon.source: "qrc:/images/icon_alarm_snooze_24.svg"

		//% "Silence alarm"
		text: qsTrId("notifications_silence_alarm")

		onClicked: Global.notifications.acknowledgeAll()
	}

	Row {
		id: rightButtonRow

		height: parent.height
		anchors {
			right: parent.right
			rightMargin: Theme.geometry_statusBar_horizontalMargin
		}

		StatusBarButton {
			enabled: root.rightButton != VenusOS.StatusBar_RightButton_None
			visible: enabled

			icon.source: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelActive
						 ? "qrc:/images/icon_sidepanel_on_32.svg"
						 : root.rightButton === VenusOS.StatusBar_RightButton_SidePanelInactive
						   ? "qrc:/images/icon_sidepanel_off_32.svg"
						   : root.rightButton === VenusOS.StatusBar_RightButton_Add
							 ? "qrc:/images/icon_plus.svg"
							 : root.rightButton === VenusOS.StatusBar_RightButton_Refresh
							   ? "qrc:/images/icon_refresh_32.svg"
							   : ""

			onClicked: root.rightButtonClicked()
		}

		StatusBarButton {
			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: !!Global.screenBlanker && Global.screenBlanker.supported && Global.screenBlanker.enabled
			enabled: !!Global.pageManager
					 && Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			onClicked: Global.screenBlanker.setDisplayOff()
		}
	}
}
