/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	readonly property NotificationsModel allNotificationsModel: NotificationsModel {}

	readonly property NotificationSortFilterProxyModel activeModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		// whether active or not
		// all types
		acknowledged: false
		sortByType: false
		sortByTime: true
	}
	readonly property NotificationSortFilterProxyModel historicalModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		// whether active or not
		// all types
		acknowledged: true
		sortByType: false
		sortByTime: true
	}
	readonly property NotificationSortFilterProxyModel unacknowledgedAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		// whether active or not
		acknowledged: false
		// only alarms
		type: VenusOS.Notification_Alarm
	}

	readonly property bool alarm: !!_alarm.value
	readonly property bool alert: !!_alert.value

	signal acknowledgeNotification(notificationId: int)

	function reset() {
		allNotificationsModel.reset()
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
