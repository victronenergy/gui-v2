/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Connections _mockConn: Connections {
		target: MockManager
		function onAddDummyNotification(isAlarm) {
			const notifType = isAlarm
							? VenusOS.Notification_Alarm
							: Math.random() < 0.5 ? VenusOS.Notification_Info : VenusOS.Notification_Warning
			const props = {
				acknowledged: 0,
				active: 1,
				type: notifType,
				dateTime: new Date(),
				deviceName: "Mock data simulator",
				description: "NotificationId [%1]".arg(nextNotificationId),
				value: Math.round(Math.random() * 100) + "%"
			}
			addNotification(props)
		}
	}

	property Component notifComponent: Component {
		Notification {
			id: notification
			onActiveChanged: root.updateNotifications()
			onAcknowledgedChanged: root.updateNotifications()

			property Timer inactiveTimer: Timer {
				interval: 10000 * Math.random()
				onTriggered: notification.updateActive(false)
			}
		}
	}

	property list<Notification> notifications: []
	readonly property int maxNotificationCount: 20
	property int nextNotificationId: 0

	property VeQuickItem _numberOfNotifications: VeQuickItem {
		uid: Global.notifications.serviceUid + "/NumberOfNotifications"
	}

	property VeQuickItem _numberOfActiveNotifications: VeQuickItem {
		uid: Global.notifications.serviceUid + "/NumberOfActiveNotifications"
	}

	property VeQuickItem _numberOfActiveAlarms: VeQuickItem {
		// including both acknowledged or unAcknowledged alarms
		uid: Global.notifications.serviceUid + "/NumberOfActiveAlarms"
	}

	property VeQuickItem _numberOfActiveWarnings: VeQuickItem {
		// including both acknowledged or unAcknowledged warnings
		uid: Global.notifications.serviceUid + "/NumberOfActiveWarnings"
	}

	property VeQuickItem _numberOfActiveInformations: VeQuickItem {
		// including both acknowledged or unAcknowledged informations
		uid: Global.notifications.serviceUid + "/NumberOfActiveInformations"
	}

	property VeQuickItem _numberOfUnAcknowledgedAlarms: VeQuickItem {
		// including both active or inactive alarms
		uid: Global.notifications.serviceUid + "/NumberOfUnAcknowledgedAlarms"
	}

	property VeQuickItem _numberOfUnAcknowledgedWarnings: VeQuickItem {
		// including both active or inactive warnings
		uid: Global.notifications.serviceUid + "/NumberOfUnAcknowledgedWarnings"
	}

	property VeQuickItem _numberOfUnAcknowledgedInformations: VeQuickItem {
		// including both active or inactive informations
		uid: Global.notifications.serviceUid + "/NumberOfUnAcknowledgedInformations"
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: Global.notifications.serviceUid + "/AcknowledgeAll"
		onValueChanged: {
			if (!isNaN(value) && value === 1) {
				const model = Global.notifications.allNotificationsModel
				for (let i = 0 ; i < model.count; ++i) {
					const notif = model.data(model.index(i, 0), NotificationsModel.Notification)
					notif.updateAcknowledged(true)
				}
				_acknowledgeAll.setValue(0)
				updateNotifications()
			}
		}
	}

	function addNotification(params) {

		let notif = null

		if (notifications.length < maxNotificationCount) {
			// Add a new Notification object
			notif = notifComponent.createObject(root, { notificationId: nextNotificationId })
			notifications.push(notif)
		} else {
			// Get an existing Notification from the notifications list to recycle.
			// The recycled notification is going to re-use the same notificationId
			notif = notifications[nextNotificationId]
		}

		// Update the VeQuickItem's values of the new or recycled Notification
		// which updates the BaseNotification properties.
		for (const p in params) {
			const value = p === "dateTime" ? params[p].valueOf() / 1000 : params[p]
			notif["_" + p].setValue(value)
		}

		// Whether we created a new Notification or recycled an existing one,
		// we increment (or wrap) the nextNotificationId.
		nextNotificationId = ((nextNotificationId + 1) === maxNotificationCount) ? 0 : (nextNotificationId + 1)

		// (re)start the mock notification inactive timer since notifications can be recycled
		if (MockManager.timersActive) {
			notif.inactiveTimer.restart()
		}

		updateNotifications()
	}

	function updateNotifications() {

		// Note: since the notifications array is capped at 20,
		// these counters will never exceed 20.

		let activeCount = 0
		let activeAlarmCount = 0
		let activeWarningCount = 0
		let activeInformationCount = 0
		let unAcknowledgedAlarmCount = 0
		let unAcknowledgedWarningCount = 0
		let unAcknowledgedInformationCount = 0

		for (let i = 0 ; i < notifications.length; ++i) {
			const notif = notifications[i]
			if (notif.active) {
				activeCount++

				if (notif.type === VenusOS.Notification_Alarm) {
					activeAlarmCount++
				} else if (notif.type === VenusOS.Notification_Warning) {
					activeWarningCount++
				} else if (notif.type === VenusOS.Notification_Info) {
					activeInformationCount++
				}
			}
			if (!notif.acknowledged) {
				if (notif.type === VenusOS.Notification_Alarm) {
					unAcknowledgedAlarmCount++
				} else if (notif.type === VenusOS.Notification_Warning) {
					unAcknowledgedWarningCount++
				} else if (notif.type === VenusOS.Notification_Info) {
					unAcknowledgedInformationCount++
				}
			}
		}
		_numberOfActiveNotifications.setValue(activeCount)
		_numberOfNotifications.setValue(notifications.length)
		_numberOfActiveAlarms.setValue(activeAlarmCount)
		_numberOfUnAcknowledgedAlarms.setValue(unAcknowledgedAlarmCount)
		_numberOfActiveWarnings.setValue(activeWarningCount)
		_numberOfUnAcknowledgedWarnings.setValue(unAcknowledgedWarningCount)
		_numberOfActiveInformations.setValue(activeInformationCount)
		_numberOfUnAcknowledgedInformations.setValue(unAcknowledgedInformationCount)
	}
}
