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

	// We should show the status bar icon if there are any active or any unacknowledged
	// Warning or Alarm type notifications, ignoring Information type notifications.
	readonly property int activeOrUnAcknowledgedWarningsAndAlarms: Math.max(alarms.activeCount, alarms.unAcknowledgedCount)
			+ Math.max(warnings.activeCount, warnings.unAcknowledgedCount)

	// The "silence alarms" button simply acknowledges all,
	// so we can assume that acknowledged alarms are silent.
	// The dot should display the number of unsilenced alarms+warnings,
	// plus the number of unacknowledged informations,
	// and so this is equivalent to the unAcknowledged count.
	readonly property int unAcknowledgedCount: alarms.unAcknowledgedCount
			+ warnings.unAcknowledgedCount
			+ informations.unAcknowledgedCount

	readonly property NotificationsModel allNotificationsModel: NotificationsModel {
		onNotificationInserted: (notification) => toastedNotification.queueNotification(notification)
		onNotificationUpdated: (notification) => toastedNotification.queueNotification(notification)
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

		function queueNotification(notif: BaseNotification) {
			if (!toastedNotif.pendingNotification || notif.dateTime >= toastedNotif.pendingNotification.dateTime) {
				toastedNotif.pendingNotification = notif;
				pendingNotificationTimer.restart();
			}
		}

		function requestToastForNotification(notif: BaseNotification) {
			// the notification must be acknowledged: false at the point of being updated
			// (this is because injected notifications' active is always false)
			// for a toast to be considered for raising (and preempting existing ones)
			if (!notif.acknowledged) {
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

	readonly property bool statusBarNotificationIconVisible: activeOrUnAcknowledgedWarningsAndAlarms > 0
	readonly property int statusBarNotificationIconPriority: (alarms.hasActive || alarms.hasUnAcknowledged) ? VenusOS.Notification_Alarm
			: (warnings.hasActive || warnings.hasUnAcknowledged) ? VenusOS.Notification_Warning
			: (informations.hasActive || informations.hasUnAcknowledged) ? VenusOS.Notification_Info
			: -1
	readonly property bool silenceAlarmVisible: alarms.hasUnAcknowledged ||
												warnings.hasUnAcknowledged ||
												informations.hasUnAcknowledged
	readonly property bool navBarNotificationCounterVisible: unAcknowledgedCount > 0

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

	readonly property Instantiator _notificationObjects: Instantiator {
		model: root._modelLoader.item
		delegate: Notification {
			id: notification

			required property string id
			readonly property bool _canInitialize: _acknowledged.value !== undefined
				   && _active.valid
				   && _type.valid
				   && _dateTime.valid
			notificationId: id
			on_CanInitializeChanged: _init()

			function _init() {
				if (!_canInitialize) {
					return
				}
				root.allNotificationsModel.insertNotification(notification)
			}

			Component.onDestruction: {
				root.allNotificationsModel.removeNotification(notification)
			}
		}
	}

	readonly property Loader _modelLoader: Loader {
		sourceComponent: BackendConnection.type === BackendConnection.MqttSource ? mqttModelComponent : dbusOrMockModelComponent

		Component {
			id: dbusOrMockModelComponent
			VeQItemSortTableModel {
				dynamicSortFilter: true
				filterRole: VeQItemTableModel.UniqueIdRole
				filterRegExp: "^%1\/com\.victronenergy\.platform\/Notifications\/\\d+$".arg(BackendConnection.uidPrefix())
				model: VeQItemTableModel {
					uids: ["%1/com.victronenergy.platform/Notifications".arg(BackendConnection.uidPrefix())]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
			}
		}
		Component {
			id: mqttModelComponent
			VeQItemSortTableModel {
				dynamicSortFilter: true
				filterRole: VeQItemTableModel.UniqueIdRole
				filterRegExp: "^mqtt\/platform\/0\/Notifications\/\\d+$"
				model: VeQItemTableModel {
					uids: ["mqtt/platform/0/Notifications"]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
			}
		}
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
