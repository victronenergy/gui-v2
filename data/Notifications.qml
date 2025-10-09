/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property int unacknowledgedCount: NotificationModel.unacknowledgedAlarms
			+ NotificationModel.unacknowledgedWarnings
			+ NotificationModel.unacknowledgedInfos

	readonly property bool statusBarNotificationIconVisible: NotificationModel.activeAlarms > 0
			|| NotificationModel.activeWarnings > 0
			|| NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0

	readonly property int statusBarNotificationIconPriority: (NotificationModel.activeAlarms > 0 || NotificationModel.unacknowledgedAlarms > 0) ? VenusOS.Notification_Alarm
			: (NotificationModel.activeWarnings > 0 || NotificationModel.unacknowledgedWarnings > 0) ? VenusOS.Notification_Warning
			: (NotificationModel.activeInfos > 0 || NotificationModel.unacknowledgedInfos > 0) ? VenusOS.Notification_Info
			: -1

	readonly property bool silenceAlarmVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0

	readonly property bool navBarNotificationCounterVisible: NotificationModel.unacknowledgedAlarms > 0
			|| NotificationModel.unacknowledgedWarnings > 0
			|| NotificationModel.unacknowledgedInfos > 0

	property Connections _toastController: Connections {
		id: toastController

		target: NotificationModel

		property ToastNotification toast: null
		property notificationData toastEntry
		property notificationData nullToastEntry
		property notificationData dismissedToastEntry

		function onAdded(modelId) {
			// check to see if we need to replace the existing toast
			let entry = NotificationModel.get(modelId)
			if (!entry.acknowledged && (!toast
					|| (entry.type === VenusOS.Notification_Alarm
					|| (entry.type === VenusOS.Notification_Warning && toastEntry.type !== VenusOS.Notification_Alarm)
					|| (entry.type === toastEntry.type)))) {
				if (toast) {
					let currToast = toast
					toast = null
					currToast.close(true)
				}
				showToast(entry)
			}
		}

		function onChanged(modelId, roles) {
			let entry = NotificationModel.get(modelId)
			if (!toast && !entry.acknowledged && roles.indexOf(NotificationModel.NotificationRoles.Acknowledged) >= 0) {
				showToast(entry)
			} else if (toast && toastEntry.modelId === modelId) {
				toastEntry = entry // update value type data.
				toast.text = "" + toastEntry.deviceName + "\n" + toastEntry.description
				if (toastEntry.acknowledged) {
					closeToast()
				}
			}
		}

		function onRemoved(modelId) {
			if (toast && toastEntry.modelId === modelId) {
				closeToast()
			}
		}

		function closeToast() {
			if (toast) {
				let currToast = toast
				toast = null
				currToast.close(true)
				dismissedToastEntry = toastEntry
				toastEntry = nullToastEntry
				Qt.callLater(openNextToast)
			}
		}

		function openNextToast() {
			let modelId = NotificationModel.toastiest()
			let entry = NotificationModel.get(modelId)
			// don't automatically open info notifications.
			if (!entry.acknowledged && entry.type !== VenusOS.Notification_Info) {
				// Some notifications are not acknowledgeable
				// e.g. firmware update notifications.
				// Only show the toast if we didn't just try to dismiss it.
				if (entry.modelId !== dismissedToastEntry.modelId
						|| entry.dateTime !== dismissedToastEntry.dateTime
						|| entry.type !== dismissedToastEntry.type) {
					showToast(entry)
				}
			}
		}

		function showToast(entry) {
			dismissedToastEntry = nullToastEntry
			toastEntry = entry
			toast = Global.notificationLayer?.showToastNotification(
					toastEntry.type,
					"" + toastEntry.deviceName + "\n" + toastEntry.description)
		}

		property Connections toastConnection: Connections {
			target: toastController.toast
			function onDismissed() {
				NotificationModel.acknowledge(toastController.toastEntry.modelId)
				toastController.closeToast()
			}
		}
	}

	Component.onCompleted: {
		Global.notifications = root
	}
}
