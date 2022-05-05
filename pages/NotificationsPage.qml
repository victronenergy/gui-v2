/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	readonly property var _locale: Qt.locale()

	//readonly property string date1: Date.fromLocaleString(Qt.locale(), "Tue 2022-03-27 10:56:06", "MM-dd hh:mm")
	readonly property string date1: "Mar 27 10:20"
	function formatDateString(date) {
		return date.toLocaleDateString(_locale, "MMMM d  ") + date.toLocaleTimeString(_locale, "hh:mm") // Mar 27  10:20
	}

	ListModel {
		id: activeNotifications // either active or not acknowledged
	}

	NotificationsView {
		id: activeNotificationsView

		onCountChanged: console.log("activeNotificationsView: count:", count)
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
		}
		model: Global.notifications.model
	}
	Column {
		id: column

		anchors {
			top: activeNotificationsView.bottom
			topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
		}
		Row {
			id: noCurrentAlerts

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
		Spacer {
			height: Theme.geometry.notificationsPage.history.topMargin
			visible: noCurrentAlerts.visible
		}
		Label {
			color: Theme.color.notificationsPage.text.color1
			//% "History"
			text: qsTrId("notifications_history")
		}
		Spacer {
			height: Theme.geometry.notificationsPage.history.spacing
		}
	}
	NotificationsView {
		anchors {
			top: column.bottom
			left: column.left
		}
		model: Global.notifications.historyModel
		onCountChanged: console.log("historyNotificationsView: count:", count)
	}
}
