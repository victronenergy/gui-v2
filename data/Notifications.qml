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

	function _notificationSortFunction(leftNotification: var, rightNotification: var) : bool {
		return leftNotification.type < rightNotification.type &&
				leftNotification.dateTime > rightNotification.dateTime
	}
	readonly property NotificationSortFilterProxyModel unacknowledgedModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.active || !notification.acknowledged }
		sortFunction: root._notificationSortFunction
	}
	readonly property NotificationSortFilterProxyModel acknowledgedModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return !notification.active && notification.acknowledged }
		sortFunction: root._notificationSortFunction
	}
	readonly property NotificationSortFilterProxyModel activeAlarmsAndWarningsModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return (notification.type === VenusOS.Notification_Alarm ||
													notification.type === VenusOS.Notification_Warning) && notification.active }
		sortFunction: root._notificationSortFunction
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
