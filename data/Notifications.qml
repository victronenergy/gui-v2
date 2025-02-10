/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	readonly property NotificationsModel allNotificationsModel: NotificationsModel {
		onNotificationInserted: (notification) => toastedNotification.onNotificationInserted(notification)
		onNotificationRemoved: (notification) => toastedNotification.onNotificationRemoved(notification)
	}

	component ToastedNotification : QtObject {
		id: toastedNotif

		property ToastNotification toast: null
		property BaseNotification notification: null

		function onNotificationInserted(notif: BaseNotification) {
			toastedNotif.checkAndRemoveExistingToast(notif)
			if(!toastedNotif.toast) {
				let createdToast = Global.notificationLayer?.showToastNotification(notif.type, "")
				if(createdToast) {
					createdToast.text = Qt.binding(function() { return `${notif.deviceName}\n${notif.description}`})
					toastedNotif.toast = createdToast
					toastedNotif.notification = notif
				}
			}
		}

		function onNotificationRemoved(notif: BaseNotification) {
			if(toastedNotif.notification === notif) {
				close()
			}
			// else the toast was already closed (or never created)
		}

		function close() {
			toastedNotif.toast?.close(true)
			toastedNotif.toast = null
			toastedNotif.notification = null
		}

		function checkAndRemoveExistingToast(notif: BaseNotification) {
			if(toast && (notif.type === VenusOS.Notification_Alarm ||
						 (notif.type === VenusOS.Notification_Warning && toast.category !== VenusOS.Notification_Alarm) ||
						 toast.category === VenusOS.Notification_Info)) {
				close()
			}
		}

		property Connections _toastConnection: Connections {
			target: toastedNotif.toast
			function onDismissed() {
				toastedNotif.toast = null
			}
		}

		property Connections _notificationConnection: Connections {
			target: toastedNotif.notification
			function onSilencedChanged() {
				if(toastedNotif.notification.silenced) {
					close()
				}
			}
		}
	}

	property ToastedNotification _toastedNotification: ToastedNotification {
		id: toastedNotification
	}

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

	readonly property int activeNotificationCount: alarms.activeCount +
												   warnings.activeCount +
												   informations.activeCount

	readonly property int unsilencedNotificationCount: alarms.unsilencedCount +
													   warnings.unsilencedCount +
													   informations.unsilencedCount

	readonly property bool hasActiveNotifications: alarms.hasActive ||
												   warnings.hasActive ||
												   informations.hasActive

	readonly property bool hasUnsilencedNotifications: alarms.hasUnsilenced ||
													   warnings.hasUnsilenced ||
													   informations.hasUnsilenced

	readonly property int statusBarNotifcationIconPriority: alarms.hasUnsilenced ? VenusOS.Notification_Alarm :
																				   warnings.hasUnsilenced ? VenusOS.Notification_Warning : -1

	readonly property bool statusBarNotifcationIconVisible: (alarms.hasActive || !alarms.hasActive && alarms.hasUnsilenced) ||
															(warnings.hasActive || !warnings.hasActive && warnings.hasUnsilenced)

	component NotificationData: QtObject {
		property int activeCount: 0
		property int unsilencedCount: 0

		readonly property bool hasActive: activeCount > 0
		readonly property bool hasUnsilenced: unsilencedCount > 0

		default property list<VeQuickItem> dataItems
	}

	readonly property NotificationData alarms: NotificationData {
		activeCount: numberOfActiveAlarms.isValid ? numberOfActiveAlarms.value : 0
		unsilencedCount: numberOfUnsilencedAlarms.isValid ? numberOfUnsilencedAlarms.value : 0

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
		activeCount: numberOfActiveWarnings.isValid ? numberOfActiveWarnings.value : 0
		unsilencedCount: numberOfUnsilencedWarnings.isValid ? numberOfUnsilencedWarnings.value : 0

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
		activeCount: numberOfActiveInformations.isValid ? numberOfActiveInformations.value : 0
		unsilencedCount: numberOfUnsilencedInformations.isValid ? numberOfUnsilencedInformations.value : 0

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
