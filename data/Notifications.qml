/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: "%1/Notifications".arg(BackendConnection.serviceUidForType("platform"))

	readonly property int activeOrUnAcknowledgedCount: Math.max(alarms.activeCount, alarms.unAcknowledgedCount)
			+ Math.max(warnings.activeCount, warnings.unAcknowledgedCount)
			+ Math.max(informations.activeCount, informations.unAcknowledgedCount)

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

			// the notification must be active and unAcknowledged at the point of being updated
			// for a toast to be considered for raising (and preempting existing ones)
			if (notif.active && !notif.acknowledged) {
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
			function onAcknowledgedChanged() {
				// the connection might still fire if the notification object is
				// destined for garbage collection and hasn't yet been destroyed
				// so we must check for null here.
				if (toastedNotif.notification?.acknowledged) {
					close()
				}
			}
		}
	}

	property ToastedNotification _toastedNotification: ToastedNotification {
		id: toastedNotification
	}

	readonly property NotificationSortFilterProxyModel sortedModel: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
	}

	function reset() {
		allNotificationsModel.reset()
	}

	function acknowledgeAll() {
		_acknowledgeAll.setValue(1)
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: root.serviceUid + "/AcknowledgeAll"
	}

	readonly property bool statusBarNotificationIconVisible: activeOrUnAcknowledgedCount > 0
	readonly property int statusBarNotificationIconPriority: alarms.hasActive || !alarms.hasActive && alarms.hasUnAcknowledged ? VenusOS.Notification_Alarm :
																																warnings.hasActive || !warnings.hasActive && warnings.hasUnAcknowledged ? VenusOS.Notification_Warning :
																																																		  informations.hasActive || !informations.hasActive && informations.hasUnAcknowledged ? VenusOS.Notification_Info : -1
	readonly property bool silenceAlarmVisible: alarms.hasUnAcknowledged ||
												warnings.hasUnAcknowledged ||
												informations.hasUnAcknowledged
	readonly property bool navBarNotificationCounterVisible: activeOrUnAcknowledgedCount > 0

	component NotificationData: QtObject {
		property int activeCount: 0
		property int unAcknowledgedCount: 0

		readonly property bool hasActive: activeCount > 0
		readonly property bool hasUnAcknowledged: unAcknowledgedCount > 0

		default property list<VeQuickItem> dataItems
	}

	readonly property NotificationData alarms: NotificationData {
		activeCount: numberOfActiveAlarms.valid ? numberOfActiveAlarms.value : 0
		unAcknowledgedCount: numberOfUnAcknowledgedAlarms.valid ? numberOfUnAcknowledgedAlarms.value : 0

		VeQuickItem {
			id: numberOfActiveAlarms
			// including both acknowledged or unAcknowledged alarms
			uid: root.serviceUid + "/NumberOfActiveAlarms"
		}

		VeQuickItem {
			id: numberOfUnAcknowledgedAlarms
			// including both active or inactive alarms
			uid: root.serviceUid + "/NumberOfUnAcknowledgedAlarms"
		}
	}

	readonly property NotificationData warnings: NotificationData {
		activeCount: numberOfActiveWarnings.valid ? numberOfActiveWarnings.value : 0
		unAcknowledgedCount: numberOfUnAcknowledgedWarnings.valid ? numberOfUnAcknowledgedWarnings.value : 0

		VeQuickItem {
			id: numberOfActiveWarnings
			// including both acknowledged or unAcknowledged warnings
			uid: root.serviceUid + "/NumberOfActiveWarnings"
		}

		VeQuickItem {
			id: numberOfUnAcknowledgedWarnings
			// including both active or inactive warnings
			uid: root.serviceUid + "/NumberOfUnAcknowledgedWarnings"
		}
	}

	readonly property NotificationData informations: NotificationData {
		activeCount: numberOfActiveInformations.valid ? numberOfActiveInformations.value : 0
		unAcknowledgedCount: numberOfUnAcknowledgedInformations.valid ? numberOfUnAcknowledgedInformations.value : 0

		VeQuickItem {
			id: numberOfActiveInformations
			// including both acknowledged or unAcknowledged informations
			uid: root.serviceUid + "/NumberOfActiveInformations"
		}

		VeQuickItem {
			id: numberOfUnAcknowledgedInformations
			// including both active or inactive informations
			uid: root.serviceUid + "/NumberOfUnAcknowledgedInformations"
		}
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
