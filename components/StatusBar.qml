/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Rectangle {
	id: root

	property string title

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None
	readonly property bool notificationButtonsEnabled: Global.mainView.currentPage && Global.mainView.currentPage.url.endsWith("NotificationsPage.qml")
	readonly property bool notificationButtonVisible: alertButton.enabled || alertButton.animating || alarmButton.enabled || alarmButton.animating

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0

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
		opacity: enabled ? 1.0 : 0.0
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
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.leftButton != VenusOS.StatusBar_LeftButton_None

		onClicked: root.leftButtonClicked()
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: root.title.length > 0 ? root.title : ClockTime.currentTime
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
		id: alertButton

		anchors {
			right: rightSideRow.right
			verticalCenter: parent.verticalCenter
		}
		enabled: notificationButtonsEnabled && !!Global.notifications && Global.notifications.alert && !alarmButton.enabled
		backgroundColor: Theme.color_warning
		//% "Acknowledge alerts"
		text: qsTrId("notifications_acknowledge_alerts")
		onClicked: Global.notifications.acknowledgeAll()
	}

	NotificationButton {
		id: alarmButton

		anchors {
			right: rightSideRow.right
			verticalCenter: parent.verticalCenter
		}
		enabled: notificationButtonsEnabled && !!Global.notifications && Global.notifications.alarm
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
			enabled: !!Global.pageManager
					&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
					&& root.rightButton != VenusOS.StatusBar_RightButton_None

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
