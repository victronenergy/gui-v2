/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	property string title

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()

	width: parent.width
	height: Theme.geometry.statusBar.height
	opacity: 0

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation.statusBar.initialize.delayedStart.duration
		}
		NumberAnimation {
			target: root
			property: "opacity"
			to: 1
			duration: Theme.animation.statusBar.initialize.fade.duration
		}
	}

	Button {
		id: leftButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		width: Theme.geometry.statusBar.button.width
		height: Theme.geometry.statusBar.button.height
		icon.width: Theme.geometry.statusBar.button.icon.width
		icon.height: Theme.geometry.statusBar.button.icon.height
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.leftButton != VenusOS.StatusBar_LeftButton_None
		backgroundColor: "transparent"  // don't show background when disabled
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration }
		}

		onClicked: root.leftButtonClicked()
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: root.title.length > 0 ? root.title : ClockTime.currentTimeText
	}

	Button {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.snoozeButton.topMargin
			right: parent.right
			rightMargin: Theme.geometry.notificationsPage.snoozeButton.rightMargin
		}
		enabled: !!Global.pageManager
					&& !!Global.pageManager.navBar
					&& Global.pageManager.navBar.currentUrl === "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
					&& Global.notifications.audibleAlarmActive
					&& !Global.notifications.snoozeAudibleAlarmActive
		opacity: enabled ? 1 : 0
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.toastNotification.fade.duration} }
		border.width: Theme.geometry.button.border.width
		border.color: Theme.color.critical
		width: Theme.geometry.notificationsPage.snoozeButton.width
		height: Theme.geometry.notificationsPage.snoozeButton.height
		backgroundColor: Theme.color.darkCritical
		radius: Theme.geometry.notificationsPage.snoozeButton.radius
		contentItem: Row {
			leftPadding: Theme.geometry.notificationsPage.snoozeButton.image.leftMargin
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.geometry.notificationsPage.snoozeButton.spacing
			CP.IconLabel {
				anchors.verticalCenter: parent.verticalCenter
				icon.source: "qrc:/images/icon_alarm_snooze_24"
			}
			Label {
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.font.size.caption
				//% "Silence alarm"
				text: qsTrId("silence_alarm")
			}
		}
		onClicked: Global.notifications.snoozeAudibleAlarmActive = true
	}

	Button {
		id: rightButtonItem

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.rightButton != VenusOS.StatusBar_RightButton_None
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation.page.idleOpacity.duration
			}
		}

		width: Theme.geometry.statusBar.button.width
		height: Theme.geometry.statusBar.button.height
		icon.width: Theme.geometry.statusBar.button.icon.width
		icon.height: Theme.geometry.statusBar.button.icon.height
		display: C.AbstractButton.IconOnly
		color: Theme.color.ok
		backgroundColor: "transparent"
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
}
