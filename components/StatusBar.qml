/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property string title
	property int navigationButton: VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
	property alias navigationButtonEnabled: navigationButton.enabled
	property bool sidePanelActive
	property alias sidePanelButtonEnabled: sidePanelButton.enabled
	property bool animationEnabled: true

	signal navigationButtonClicked()

	width: parent.width
	height: Theme.geometry.statusBar.height

	Button {
		id: navigationButton

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
		icon.source: root.navigationButton === VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.navigationButton === VenusOS.StatusBar_NavigationButtonStyle_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator { duration: Theme.animation.page.idleOpacity.duration }
		}

		onClicked: root.navigationButtonClicked()
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
		enabled: !!Global.pageManager.navBar
					&& Global.pageManager.navBar.currentUrl === "qrc:/pages/NotificationsPage.qml"
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
				font.pixelSize: Theme.font.size.xs
				//% "Silence alarm"
				text: qsTrId("silence_alarm")
			}
		}
		onClicked: Global.notifications.snoozeAudibleAlarmActive = true
	}

	Button {
		id: sidePanelButton

		anchors {
			right: parent.right
			rightMargin: Theme.geometry.statusBar.horizontalMargin
			verticalCenter: parent.verticalCenter
		}

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
		icon.source: root.sidePanelActive
					 ? "qrc:/images/icon_sidepanel_on_32.svg"
					 : "qrc:/images/icon_sidepanel_off_32.svg"
		onClicked: root.sidePanelActive = !root.sidePanelActive
	}
}
