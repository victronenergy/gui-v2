/*
** Copyright (C) 2022 Victron Energy B.V.
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

	property int currentCategory: VenusOS.ToastNotification_Category_Error
	property bool useShortText: false

	property var dummyAlarms: [
		{
			acknowledged: true,
			active: true,
			category: VenusOS.ToastNotification_Category_Warning,
			date: root.date,
			source: "RS 48/6000/100 HQ2050NMMEX",
			description: "Low battery voltage 45V"
		},
		{
			acknowledged: false,
			active: true,
			category: VenusOS.ToastNotification_Category_Error,
			date: root.date,
			source: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: false,
			category: VenusOS.ToastNotification_Category_Error,
			date: root.date,
			source: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: true,
			category: VenusOS.ToastNotification_Category_Informative,
			date: root.date,
			source: "System",
			description: "Software update available"
		}
	]

	function getRandomAlarm() {
		var index = Math.floor(Math.random() * dummyAlarms.length)
		var alarm = dummyAlarms[index]
		alarm.date = new Date()
		return alarm
	}

	function showToastNotification() {
		currentCategory = (currentCategory + 1)
		if (currentCategory > VenusOS.ToastNotification_Category_Error) {
			currentCategory = VenusOS.ToastNotification_Category_None
			useShortText = !useShortText
		}
		dialogManager.showToastNotification(currentCategory, useShortText ? shortText : longText)
	}
}
