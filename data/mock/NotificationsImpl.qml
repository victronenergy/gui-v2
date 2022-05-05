/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var _locale: Qt.locale()

	function formatDateString(date) {
		return date.toLocaleDateString(_locale, "MMMM d  ") + date.toLocaleTimeString(_locale, "hh:mm") // Mar 27  10:20
	}

	function populate() {
		var date = new Date()
		Global.notifications.add({
									 acknowledged: true,
									 active: true,
									 category: VenusOS.ToastNotification_Category_Warning,
									 date: formatDateString(date),
									 source: "RS 48/6000/100 HQ2050NMMEX",
									 description: "Low battery voltage 45V"
								 })
		Global.notifications.add({
									 acknowledged: false,
									 active: false,
									 category: VenusOS.ToastNotification_Category_Error,
									 date: formatDateString(date),
									 source: "Fuel tank custom name",
									 description: "Fuel level low 15%"
								 })
		Global.notifications.add({
									 acknowledged: true,
									 active: false,
									 category: VenusOS.ToastNotification_Category_Error,
									 date: formatDateString(date),
									 source: "Fuel tank custom name",
									 description: "Fuel level low 15%"
								 })
		Global.notifications.add({
									 acknowledged: false,
									 active: true,
									 category: VenusOS.ToastNotification_Category_Informative,
									 date: formatDateString(date),
									 source: "System",
									 description: "Software update available"
								 })
	}

	Component.onCompleted: {
		populate()
	}
}
