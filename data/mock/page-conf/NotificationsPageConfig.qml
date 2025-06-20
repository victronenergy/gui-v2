/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	//% "Mollitia quis est quas deleniti quibusdam explicabo quasi."
	property string shortText: qsTrId("notifications_toast_short_text")

	//% "Mollitia quis est quas deleniti quibusdam explicabo quasi. Voluptatem qui quia et consequuntur."
	property string longText: qsTrId("notifications_toast_long_text")

	property bool useShortText: false

	function showToastNotification(notifType) {
		if (notifType > VenusOS.Notification_Info) {
			useShortText = !useShortText
		}
		Global.showToastNotification(notifType, useShortText ? shortText : longText)
	}
}
