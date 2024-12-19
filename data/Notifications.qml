/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	readonly property NotificationsModel activeModel: NotificationsModel {}
	readonly property NotificationsModel historicalModel: NotificationsModel {}

	readonly property AllNotificationsModel allNotificationsModel: AllNotificationsModel {}

	readonly property NotificationSortFilterProxyModel newActiveModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		// whether active or not
		// all types
		acknowledged: false
		sortByType: true
		sortByTime: true
	}
	readonly property NotificationSortFilterProxyModel newHistoricalModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		// all types
		acknowledged: true
		active: false
		sortByType: true
		sortByTime: true
	}
	readonly property NotificationSortFilterProxyModel activeAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		active: true
		// whether acknowledged or not
		type: VenusOS.Notification_Alarm
	}
	readonly property NotificationSortFilterProxyModel unacknowledgedAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		acknowledged: false
		// whether active or not
		type: VenusOS.Notification_Alarm
	}
	readonly property NotificationSortFilterProxyModel activeUnacknowledgedAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		active: true
		acknowledged: false
		type: VenusOS.Notification_Alarm
	}
	readonly property NotificationSortFilterProxyModel inactiveAcknowledgedAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		active: false
		acknowledged: true
		type: VenusOS.Notification_Alarm
	}

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
