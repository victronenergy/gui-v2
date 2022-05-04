/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var date26MinutesAgo: new Date()
	property var date2h10mAgo: new Date()
	property var date1dAgo: new Date()
	property var date8dAgo: new Date()
	readonly property var _locale: Qt.locale()
	readonly property var dummyNotifications: [
		{
			acknowledged: true,
			active: true,
			category: VenusOS.ToastNotification_Category_Warning,
			date: root.date8dAgo,
			source: "RS 48/6000/100 HQ2050NMMEX",
			description: "Low battery voltage 45V"
		},
		{
			acknowledged: false,
			active: false,
			category: VenusOS.ToastNotification_Category_Error,
			date: root.date1dAgo,
			source: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: true,
			category: VenusOS.ToastNotification_Category_Informative,
			date: root.date2h10mAgo,
			source: "System",
			description: "Software update available"
		},
		{
			acknowledged: false,
			active: true,
			category: VenusOS.ToastNotification_Category_Informative,
			date: root.date26MinutesAgo,
			source: "System",
			description: "Software update available"
		}
	]
	property Connections demoConnections: Connections {
		target: Global.demoManager || null

		function onDeactivateSingleAlarm() {
			for (var i = 0; i < Global.notifications.model.count; ++i) {
				let notification = Global.notifications.model.get(i)
				if (notification.active) {
					notification.active = false
					Global.notifications.updateNotification(i, notification)
					break
				}
			}
		}
	}

	function populate() {
		for (var i = 0; i < dummyNotifications.length; ++i) {
			Global.notifications.addNotification(dummyNotifications[i])
		}
	}

	Component.onCompleted: {
		root.date26MinutesAgo.setMinutes(root.date26MinutesAgo.getMinutes() - 26)
		root.date2h10mAgo.setMinutes(root.date2h10mAgo.getMinutes() - 130)
		root.date1dAgo.setHours(root.date1dAgo.getHours() - 24)
		root.date8dAgo.setDate(root.date8dAgo.getDate() - 8)
		populate()
	}
}
