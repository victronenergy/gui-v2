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
	readonly property NotificationSortFilterProxyModel unsilencedModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.active || !notification.silenced }
		sortFunction: root._notificationSortFunction
	}
	readonly property NotificationSortFilterProxyModel silencedModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return !notification.active && notification.silenced }
		sortFunction: root._notificationSortFunction
	}

	function reset() {
		allNotificationsModel.reset()
	}

	function silenceAll() {
		_silenceAll.setValue(1)
	}

	readonly property VeQuickItem _silenceAll: VeQuickItem {
		uid: root.serviceUid + "/SilenceAll"
	}

	readonly property bool hasActiveNotifications: alarms.hasActive ||
												   warnings.hasActive ||
												   informations.hasActive

	readonly property bool hasUnsilencedNotifications: alarms.hasUnsilenced ||
													   warnings.hasUnsilenced ||
													   informations.hasUnsilenced

	readonly property int highestPriortyUnsilenced: alarms.hasUnsilenced ? VenusOS.Notification_Alarm :
																		   warnings.hasUnsilenced ? VenusOS.Notification_Warning :
																									informations.hasUnsilenced ? VenusOS.Notification_Info
																															   : -1

	readonly property bool showNotificationBar: alarms.hasUnsilenced ||
												warnings.hasUnsilenced ||
												(informations.hasUnsilenced && informations.hasActive)

	readonly property bool showNotificationBell: (alarms.hasActive ||
												  !alarms.hasActive && alarms.hasUnsilenced) ||
												 (warnings.hasActive ||
												  !warnings.hasActive && warnings.hasUnsilenced) ||
												 (informations.hasActive && informations.hasUnsilenced)
	component NotificationData: QtObject {
		property int activeCount: 0
		property int unsilencedCount: 0

		readonly property bool hasActive: activeCount > 0
		readonly property bool hasUnsilenced: unsilencedCount > 0

		default property list<VeQuickItem> dataItems
	}

	readonly property NotificationData alarms: NotificationData {
		activeCount: !!numberOfActiveAlarms.value
		unsilencedCount: !!numberOfUnsilencedAlarms.value

		VeQuickItem {
			id: numberOfActiveAlarms
			// including both silenced or unsilenced alarms
			uid: root.serviceUid + "/NumberOfActiveAlarms"
		}

		VeQuickItem {
			id: numberOfUnsilencedAlarms
			// including both active or inactive alarms
			uid: root.serviceUid + "/NumberOfUnsilencedAlarms"
		}
	}

	readonly property NotificationData warnings: NotificationData {
		activeCount: !!numberOfActiveWarnings.value
		unsilencedCount: !!numberOfUnsilencedWarnings.value

		VeQuickItem {
			id: numberOfActiveWarnings
			// including both silenced or unsilenced warnings
			uid: root.serviceUid + "/NumberOfActiveWarnings"
		}

		VeQuickItem {
			id: numberOfUnsilencedWarnings
			// including both active or inactive warnings
			uid: root.serviceUid + "/NumberOfUnsilencedWarnings"
		}
	}

	readonly property NotificationData informations: NotificationData {
		activeCount: !!numberOfActiveInformations.value
		unsilencedCount: !!numberOfUnsilencedInformations.value

		VeQuickItem {
			id: numberOfActiveInformations
			// including both silenced or unsilenced informations
			uid: root.serviceUid + "/NumberOfActiveInformations"
		}

		VeQuickItem {
			id: numberOfUnsilencedInformations
			// including both active or inactive informations
			uid: root.serviceUid + "/NumberOfUnsilencedInformations"
		}
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
