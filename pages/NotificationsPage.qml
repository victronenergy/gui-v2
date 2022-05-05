/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	readonly property var _locale: Qt.locale()

	Row {
		id: noCurrentAlerts

		visible: activeNotifications.count === 0
		anchors {
			top: parent.top
			topMargin: Theme.geometry.notificationsPage.checkmark.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.checkmark.leftMargin
		}
		spacing: Theme.geometry.notificationsPage.checkmark.spacing
		height: childrenRect.height

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
		id: label
		anchors {
			top: noCurrentAlerts.bottom
			topMargin: Theme.geometry.notificationsPage.history.topMargin
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.history.leftMargin
		}
		color: Theme.color.notificationsPage.text.color1

		//% "History"
		text: qsTrId("notifications_history")
	}
	//readonly property string date1: Date.fromLocaleString(Qt.locale(), "Tue 2022-03-27 10:56:06", "MM-dd hh:mm")
	readonly property string date1: "Mar 27 10:20"
	function formatDateString(date) {
		return date.toLocaleDateString(_locale, "MMMM d  ") + date.toLocaleTimeString(_locale, "hh:mm") // Mar 27  10:20
	}

	ListView {
		anchors {
			top: label.bottom
			topMargin: Theme.geometry.notificationsPage.history.spacing
			left: parent.left
			leftMargin: Theme.geometry.notificationsPage.history.leftMargin
		}
		spacing: Theme.geometry.notificationsPage.historyView.spacing
		height: childrenRect.height
		model: historicalNotifications
		delegate: NotificationDelegate {}
	}
	ListModel {
		id: activeNotifications // either active or acknowledged
	}
	ListModel {
		id: historicalNotifications // inactive and acknowledged
		Component.onCompleted: {
			var date = new Date()
			append({acknowledged: true,
					active: false,
					category: VenusOS.ToastNotification_Category_Error,
					date: formatDateString(date),
					source: "Fuel tank custom name",
					description: "Fuel level low 15%"
					})
			append({acknowledged: true,
					active: false,
					category: VenusOS.ToastNotification_Category_Warning,
					date: formatDateString(date),
					source: "RS 48/6000/100 HQ2050NMMEX",
					description: "Low battery voltage 46.69V"
					})
			append({acknowledged: true,
					active: false,
					category: VenusOS.ToastNotification_Category_Informative,
					date: formatDateString(date),
					source: "System",
					description: "Software update available"
					})
		}
	}
}
