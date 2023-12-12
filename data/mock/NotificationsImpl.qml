/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
	property var dummyNotifications: [
		{
			acknowledged: true,
			active: true,
			type: Enums.Notification_Warning,
			dateTime: root.date8dAgo,
			deviceName: "RS 48/6000/100 HQ2050NMMEX",
			description: "Low battery voltage 45V"
		},
		{
			acknowledged: false,
			active: false,
			type: Enums.Notification_Alarm,
			dateTime: root.date1dAgo,
			deviceName: "Fuel tank custom name",
			description: "Fuel level low 15%",
		},
		{
			acknowledged: false,
			active: true,
			type: Enums.Notification_Info,
			dateTime: root.date2h10mAgo,
			deviceName: "System",
			description: "Software update available",
		},
		{
			acknowledged: false,
			active: true,
			type: Enums.Notification_Info,
			dateTime: root.date26MinutesAgo,
			deviceName: "System",
			description: "Software update available"
		}
	]

	function populate() {
		for (var i = 0; i < dummyNotifications.length; ++i) {
			var n = dummyNotifications[i]
			Global.notifications.activeModel.insertByDate(n.acknowledged, n.active, n.type, n.deviceName, n.dateTime, n.description)
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
