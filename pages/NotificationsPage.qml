/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	onHeightChanged: console.log("NotificationsPage: height:", height)
	NotificationsView {
		id: activeNotificationsView // these notifications are active and/or not acknowledged

		onCountChanged: console.log("activeNotificationsView: count:", count)
		onHeightChanged: console.log("activeNotificationsView: height:", height)
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.active.topMargin // 83 56
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.leftMargin
		}
		model: Global.notifications.model
	}
	Row {
		id: noCurrentAlerts

		anchors {
			top: activeNotificationsView.bottom
			topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
		}
		visible: Global.notifications.model.count === 0
		spacing: Theme.geometry.notificationsPage.checkmark.spacing

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			source: "qrc:/images/icon_checkmark_48"
			fillMode: Image.PreserveAspectFit
			smooth: true
		}
		Label {
			anchors.verticalCenter: parent.verticalCenter
			color: Theme.color.notificationsPage.text.color1
			font.pixelSize: Theme.font.size.l

			//% "No current alerts"
			text: qsTrId("notifications_no_current_alerts")
		}
	}
	Label {
		id: history
		anchors {
			top: noCurrentAlerts.visible ? noCurrentAlerts.bottom : activeNotificationsView.bottom
			topMargin: noCurrentAlerts.visible ? Theme.geometry.notificationsPage.history.topMargin : Theme.geometry.notificationsPage.delegate.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.leftMargin
		}
		visible: historicalNotificationsView.count !== 0
		color: Theme.color.notificationsPage.text.color1
		//% "History"
		text: qsTrId("notifications_history")
	}
	NotificationsView { // these notifications are inactive and have been acknowledged
		id: historicalNotificationsView
		anchors {
			top: history.bottom
			topMargin: Theme.geometry.notificationsPage.history.spacing
			left: history.left
		}
		model: Global.notifications.historyModel
		onCountChanged: console.log("historyNotificationsView: count:", count)
	}
}
