/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	property NotificationsModel activeModel: NotificationsModel {}
	property NotificationsModel historicalModel: NotificationsModel {}

	readonly property bool alarm: !!_alarm.value
	readonly property bool alert: !!_alert.value

	signal acknowledgeNotification(notificationId: int)

	function reset() {
		activeModel.reset()
		historicalModel.reset()
	}

	function acknowledgeAll() {
		_acknowledgeAll.setValue(1)
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: root.serviceUid + "/AcknowledgeAll"
	}

	readonly property VeQuickItem _alarm: VeQuickItem {
		uid: root.serviceUid + "/Alarm"
	}

	readonly property VeQuickItem _alert: VeQuickItem {
		uid: root.serviceUid + "/Alert"
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
