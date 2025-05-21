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

		// ensure that the injected notifications are also acknowledged in this case
		for (let i = 0 ; i < _injectedNotifications.length; ++i) {
			const notif = _injectedNotifications[i]
			notif.updateAcknowledged(true)
			// since injected notifications don't have the idea
			// of being active or not, we set it active: false
			// when it is acknowledged for now.
			notif.updateActive(false)
		}
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: root.serviceUid + "/AcknowledgeAll"
	}

	readonly property int activeOrUnAcknowledgedCount: activeOrUnAcknowledged.count
	readonly property bool hasActiveOrUnAcknowledged: activeOrUnAcknowledgedCount > 0
	readonly property bool hasActiveAlarms: activeAlarms.count > 0
	readonly property bool hasUnAcknowledged: unAcknowledged.count > 0
	readonly property int notificationPriority: activeOrUnAcknowledgedAlarms.count > 0 ? VenusOS.Notification_Alarm :
																						 activeOrUnAcknowledgedWarnings.count > 0 ? VenusOS.Notification_Warning :
																																	activeOrUnAcknowledgedInformations.count > 0 ? VenusOS.Notification_Info : -1

	property NotificationSortFilterProxyModel unAcknowledged: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return !notification.acknowledged }
	}
	property NotificationSortFilterProxyModel activeOrUnAcknowledged: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.active || !notification.acknowledged }
	}
	property NotificationSortFilterProxyModel activeAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.type === VenusOS.Notification_Alarm && notification.active }
	}
	property NotificationSortFilterProxyModel activeOrUnAcknowledgedAlarms: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.type === VenusOS.Notification_Alarm && (notification.active || !notification.acknowledged) }
	}
	property NotificationSortFilterProxyModel activeOrUnAcknowledgedWarnings: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.type === VenusOS.Notification_Warning && (notification.active || !notification.acknowledged) }
	}
	property NotificationSortFilterProxyModel activeOrUnAcknowledgedInformations: NotificationSortFilterProxyModel {
		sourceModel: allNotificationsModel
		filterFunction: (notification) => { return notification.type === VenusOS.Notification_Info && (notification.active || !notification.acknowledged) }
	}

	property Component injectedNotificationComponent: Component {
		InjectedNotification {
			id: injectedNotification

			// This is an injected Notification.
			// All active/unacknowledged counters are driven by the sorted/filtered models
			// and include injected and non-injected notifications
		}
	}

	property list<InjectedNotification> _injectedNotifications: []

	readonly property VeQuickItem _injected: VeQuickItem {
		uid: root.serviceUid + "/Inject"
		onValueChanged: if (value !== undefined) {
							// Note: injected notifications don't have an id
							let notif = injectedNotificationComponent.createObject(root, { text: value })
							_injectedNotifications.push(notif)
						}
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
