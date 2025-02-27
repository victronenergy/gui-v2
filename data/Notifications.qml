/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	readonly property NotificationsModel allNotificationsModel: NotificationsModel {
		onNotificationUpdated: (notification) => toastedNotification.onNotificationUpdated(notification)
		onNotificationRemoved: (notification) => toastedNotification.onNotificationRemoved(notification)
	}

	component ToastedNotification : QtObject {
		id: toastedNotif

		property ToastNotification toast: null
		property BaseNotification notification: null
		property BaseNotification pendingNotification: null

		property Timer timer: Timer {
			id: pendingNotificationTimer

			repeat: false
			interval: 100
			onTriggered: toastedNotif.requestToastForNotification(toastedNotif.pendingNotification)
		}

		function onNotificationUpdated(notif: BaseNotification) {
			if (!toastedNotif.pendingNotification || notif.dateTime >= toastedNotif.pendingNotification.dateTime) {
				toastedNotif.pendingNotification = notif;
				pendingNotificationTimer.restart();
			}
		}

		function requestToastForNotification(notif: BaseNotification) {

			// the notification must be active and unsilenced at the point of being updated
			// for a toast to be considered for raising (and preempting existing ones)
			if (notif.active && !notif.silenced) {
				toastedNotif.checkAndRemoveExistingToast(notif)
				if (!toastedNotif.toast) {
					let createdToast = Global.notificationLayer?.showToastNotification(notif.type, "")
					if (createdToast) {
						createdToast.text = Qt.binding(function() { return `${notif.deviceName}\n${notif.description}`})
						toastedNotif.toast = createdToast
						toastedNotif.notification = notif
					}
				}
			}
		}

		function onNotificationRemoved(notif: BaseNotification) {
			if (toastedNotif.notification === notif) {
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
			if (toast) {
				// Since it is easier to express the negative logic here, we write:
				// "don't remove an existing toast if its toast.category has a higher priority than the notif.type"
				if (!((toast.category === VenusOS.Notification_Warning && notif.type === VenusOS.Notification_Info)
					  || (toast.category === VenusOS.Notification_Alarm && (notif.type === VenusOS.Notification_Warning || notif.type === VenusOS.Notification_Info)))) {
					close()
				}
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
				// the connection might still fire if the notification object is
				// destined for garbage collection and hasn't yet been destroyed
				// so we must check for null here.
				if (toastedNotif.notification?.silenced) {
					close()
				}
			}
		}
	}

	property ToastedNotification _toastedNotification: ToastedNotification {
		id: toastedNotification
	}

	function _notificationSortFunction(leftNotification: BaseNotification, rightNotification: BaseNotification) : bool {

		if (leftNotification.active !== rightNotification.active) {
			return leftNotification.active && !rightNotification.active
		}

		if (leftNotification.type !== rightNotification.type) {

			if(leftNotification.type === VenusOS.Notification_Alarm && rightNotification.type !== VenusOS.Notification_Alarm) {
				return true
			}
			if(leftNotification.type === VenusOS.Notification_Warning && rightNotification.type === VenusOS.Notification_Info) {
				return true
			}
			return false
		}

		return leftNotification.dateTime > rightNotification.dateTime
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

	readonly property bool navBarNotificationCounterVisible: unsilencedModel.count > 0

	readonly property int statusBarNotifcationIconPriority: alarms.hasActive || !alarms.hasActive && alarms.hasUnsilenced ? VenusOS.Notification_Alarm :
																															warnings.hasActive || !warnings.hasActive && warnings.hasUnsilenced ? VenusOS.Notification_Warning :
																																																  informations.hasActive || !informations.hasActive && informations.hasUnsilenced ? VenusOS.Notification_Info : -1

	readonly property bool statusBarNotifcationIconVisible: statusBarNotifcationIconPriority > -1

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
