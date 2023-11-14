/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var _locale: Qt.locale()
	property date date: new Date()
	//% "Inverter temperature"
	property string warningNotificationTitle: qsTrId("notifications_warning_title_inverter_temperature")
	//% "Suggest user an action or inaction, inform about status.  This text can be long and should wrap."
	property string warningNotificationDescription: qsTrId("notifications_warning_description_inverter_temperature")


	//% "Mollitia quis est quas deleniti quibusdam explicabo quasi."
	property string shortText: qsTrId("notifications_toast_short_text")

	//% "Mollitia quis est quas deleniti quibusdam explicabo quasi. Voluptatem qui quia et consequuntur."
	property string longText: qsTrId("notifications_toast_long_text")

	property bool useShortText: false

	property var dummyAlarms: [
		{
			acknowledged: true,
			active: true,
			type: VenusOS.Notification_Warning,
			dateTime: root.date,
			deviceName: "RS 48/6000/100 HQ2050NMMEX",
			description: "Low battery voltage 45V"
		},
		{
			acknowledged: false,
			active: true,
			type: VenusOS.Notification_Alarm,
			dateTime: root.date,
			deviceName: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: false,
			type: VenusOS.Notification_Alarm,
			dateTime: root.date,
			deviceName: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: true,
			type: VenusOS.Notification_Info,
			dateTime: root.date,
			deviceName: "System",
			description: "Software update available"
		}
	]

	function getRandomAlarm() {
		var index = Math.floor(Math.random() * dummyAlarms.length)
		var alarm = dummyAlarms[index]
		alarm.dateTime = new Date()
		return alarm
	}

	function showToastNotification(notifType) {
		if (notifType > VenusOS.Notification_Info) {
			useShortText = !useShortText
		}
		Global.showToastNotification(notifType, useShortText ? shortText : longText)
	}
}
