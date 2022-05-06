/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var date: new Date()
	readonly property var _locale: Qt.locale()
	readonly property var dummyNotifications: [
		{
			acknowledged: true,
			active: true,
			category: VenusOS.ToastNotification_Category_Warning,
			date: formatDateString(date),
			source: "RS 48/6000/100 HQ2050NMMEX",
			description: "Low battery voltage 45V"
		},
		{
			acknowledged: false,
			active: false,
			category: VenusOS.ToastNotification_Category_Error,
			date: formatDateString(date),
			source: "Fuel tank custom name",
			description: "Fuel level low 15%"
		},
		{
			acknowledged: false,
			active: true,
			category: VenusOS.ToastNotification_Category_Informative,
			date: formatDateString(date),
			source: "System",
			description: "Software update available"
		}
	]

	function formatDateString(date) {
		return date.toLocaleDateString(_locale, "MMMM d  ") + date.toLocaleTimeString(_locale, "hh:mm") // Mar 27  10:20
	}

	function populate() {
		for (var i = 0; i < dummyNotifications.length; ++i) {
			Global.notifications.add(dummyNotifications[i])
		}
	}

	Component.onCompleted: {
		populate()
	}
}
