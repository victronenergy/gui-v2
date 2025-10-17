/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string notificationsServiceUid: "" + BackendConnection.serviceUidForType("platform") + "/Notifications"

	property Connections _mockConn: Connections {
		target: MockManager
		function onAddDummyNotification(isAlarm) {
			if (notificationRateLimitTimer.running) {
				return
			}

			notificationRateLimitTimer.start();
			const notifType = isAlarm
							? VenusOS.Notification_Alarm
							: Math.random() < 0.5 ? VenusOS.Notification_Info : VenusOS.Notification_Warning
			const val = Math.round(Math.random() * 100) + "%"
			const props = {
				service: "mockService",
				dateTime: new Date(),
				trigger: val,
				alarmValue: val,
				deviceName: "Mock data simulator",
				value: val,
				type: notifType,
				active: 1,
				acknowledged: 0,
				silenced: 0,
				description: "NotificationId [%1]".arg(nextNotificationId)
			}
			addNotification(props)
		}

		property Timer rateLimitTimer: Timer {
			id: notificationRateLimitTimer
			interval: 500
			repeat: false
			running: false
		}
	}

	property Component notifComponent: Component {
		MockNotification {
			id: notification

			onActiveChanged: root.updateNotifications()
			onAcknowledgedChanged: root.updateNotifications()

			property Timer activeTimer: Timer {
				interval: 1000 + (9000 * Math.random())
				onTriggered: notification._active.setValue(0)
			}
		}
	}

	property list<MockNotification> notifications: []
	readonly property int maxNotificationCount: 20
	property int nextNotificationId: 0

	property VeQuickItem _numberOfNotifications: VeQuickItem {
		uid: notificationsServiceUid + "/NumberOfNotifications"
	}

	property VeQuickItem _numberOfActiveNotifications: VeQuickItem {
		uid: notificationsServiceUid + "/NumberOfActiveNotifications"
	}

	property VeQuickItem _numberOfActiveAlarms: VeQuickItem {
		// including both acknowledged or unAcknowledged alarms
		uid: notificationsServiceUid + "/NumberOfActiveAlarms"
	}

	property VeQuickItem _numberOfActiveWarnings: VeQuickItem {
		// including both acknowledged or unAcknowledged warnings
		uid: notificationsServiceUid + "/NumberOfActiveWarnings"
	}

	property VeQuickItem _numberOfActiveInformations: VeQuickItem {
		// including both acknowledged or unAcknowledged informations
		uid: notificationsServiceUid + "/NumberOfActiveInformations"
	}

	property VeQuickItem _numberOfUnAcknowledgedAlarms: VeQuickItem {
		// including both active or inactive alarms
		uid: notificationsServiceUid + "/NumberOfUnAcknowledgedAlarms"
	}

	property VeQuickItem _numberOfUnAcknowledgedWarnings: VeQuickItem {
		// including both active or inactive warnings
		uid: notificationsServiceUid + "/NumberOfUnAcknowledgedWarnings"
	}

	property VeQuickItem _numberOfUnAcknowledgedInformations: VeQuickItem {
		// including both active or inactive informations
		uid: notificationsServiceUid + "/NumberOfUnAcknowledgedInformations"
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: notificationsServiceUid + "/AcknowledgeAll"
		onValueChanged: {
			if (!isNaN(value) && value === 1) {
				const model = NotificationModel
				for (let i = 0 ; i < model.count; ++i) {
					model.acknowledgeRow(i)
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

			// venus-platform first "removes" the old notification,
			// which sets active=false then acknowledged=true.
			// emulate this behaviour.
			notif._active.setValue(0)
			notif._acknowledged.setValue(1)
		}

		// Update the VeQuickItem's values for the Notification.
		// Note that we must update them in the same order as venus-platform Notification ctor does.
		notif._service.setValue(params.service)
		notif._dateTime.setValue(params.dateTime / 1000)
		notif._trigger.setValue(params.trigger)
		notif._alarmValue.setValue(params.alarmValue)
		notif._deviceName.setValue(params.deviceName)
		notif._value.setValue(params.value)
		notif._type.setValue(params.type)
		notif._active.setValue(params.active)
		notif._acknowledged.setValue(params.acknowledged)
		notif._silenced.setValue(params.silenced)
		notif._description.setValue(params.description)

		// (re)start the mock notification active timer since notifications can be recycled.
		// this will set the notification active to false after some time.
		if (MockManager.timersActive) {
			notif.activeTimer.restart()
		}

		// Whether we created a new Notification or recycled an existing one,
		// we increment (or wrap) the nextNotificationId.
		nextNotificationId = ((nextNotificationId + 1) === maxNotificationCount) ? 0 : (nextNotificationId + 1)

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

	// in case some notifications were pre-instantiated via the config,
	// we need to initialise our in-memory array of notification slots.
	Component.onCompleted: {
		let i = 0
		let notif
		for (i = 0; i < NotificationModel.count; ++i) {
			if (notifications.length < maxNotificationCount) {
				notif = notifComponent.createObject(root, { notificationId: nextNotificationId })
				notifications.push(notif)
			} else {
				notif = notifications[i]
			}
			++nextNotificationId
			if (nextNotificationId >= maxNotificationCount) {
				nextNotificationId = 0
			}
		}
	}
}
