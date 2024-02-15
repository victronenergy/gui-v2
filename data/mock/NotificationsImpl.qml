/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property date date26MinutesAgo: new Date()
	property date date2h10mAgo: new Date()
	property date date1dAgo: new Date()
	property date date8dAgo: new Date()

	readonly property var dummyNotifications: [
		{
			acknowledged: 0,
			active: 0,
			type: VenusOS.Notification_Warning,
			dateTime: root.date1dAgo,
			deviceName: "Fuel tank custom name",
			description: "Fuel level low",
			value: "15%",
		},
		{
			acknowledged: 0,
			active: 0,
			type: VenusOS.Notification_Info,
			dateTime: root.date26MinutesAgo,
			deviceName: "System",
			description: "Software update available"
		},
		{
			acknowledged: 0,
			active: 0,
			type: VenusOS.Notification_Info,
			dateTime: root.date2h10mAgo,
			deviceName: "Pro Battery",
			description: "High temperature",
			value: "25C",
		}
	]

	property int dummyNotificationNumber

	property Connections _mockConn: Connections {
		target: Global.mockDataSimulator
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
				description: "Notification no. %1".arg(dummyNotificationNumber++),
				value: Math.round(Math.random() * 100) + "%"
			}
			addNotification(props)
		}
	}

	property Component notifComponent: Component {
		Notification {
			onActiveChanged: root._updateAlarmsAndAlerts()

			property Timer inactiveTimer: Timer {
				running: Global.mockDataSimulator.timersActive
				interval: 10000 * Math.random()
				onTriggered: parent._active.setValue(0)
			}
		}
	}

	property var notifications: []

	readonly property int maxNotificationCount: 20

	property VeQuickItem _alarm: VeQuickItem {
		uid: Global.notifications.serviceUid + "/Alarm"
	}

	property VeQuickItem _alert: VeQuickItem {
		uid: Global.notifications.serviceUid + "/Alert"
	}

	property VeQuickItem _numberOfNotifications: VeQuickItem {
		uid: Global.notifications.serviceUid + "/NumberOfNotifications"
	}

	property VeQuickItem _numberOfActiveNotifications: VeQuickItem {
		uid: Global.notifications.serviceUid + "/NumberOfActiveNotifications"
	}

	readonly property VeQuickItem _acknowledgeAll: VeQuickItem {
		uid: Global.notifications.serviceUid + "/AcknowledgeAll"
		onValueChanged: {
			for (let i = 0 ; i < notifications.length; ++i) {
				const notif = notifications[i]
				notif.setAcknowledged(true)
			}
			_acknowledgeAll.setValue(0)
			_alert.setValue(0)
			_alarm.setValue(0)
		}
	}

	function addNotification(params) {
		const numberOfNotifications = notifications.length
		let notificationId = numberOfNotifications

		if (numberOfNotifications >= maxNotificationCount) {
			notificationId = removeLastNotification()
		}

		let notif = notifComponent.createObject(root, { notificationId: notificationId })
		for (const p in params) {
			const value = p === "dateTime" ? params[p].valueOf() / 1000 : params[p]
			notif["_" + p].setValue(value)
		}
		if (params['type'] === VenusOS.Notification_Alarm) {
			_alarm.setValue(1)
		}
		if (!!params['active']) {
			_numberOfActiveNotifications.setValue((_numberOfActiveNotifications.value || 0) + 1)
			_alert.setValue(1)
		}
		notifications.push(notif)
		_numberOfNotifications.setValue(notifications.length)
	}

	function removeLastNotification() {
		const notif = notifications[notifications.length - 1]
		const notificationId = notif.notificationId
		if (notif.active) {
			_numberOfActiveNotifications.setValue(Math.max(0, _numberOfActiveNotifications.value - 1))
		}
		updateAlarm()
		updateAlert()
		notifications.splice(notifications.length - 1, 1)
		return notificationId
	}

	function _updateAlarmsAndAlerts() {
		updateAlarm()
		updateAlert()
	}

	function updateAlarm() {
		let activeCount = 0
		let hasAlarm = false
		for (let i = 0 ; i < notifications.length; ++i) {
			const notif = notifications[i]
			if (notif.active) {
				activeCount++
				if (!hasAlarm && notif.type === VenusOS.Notification_Alarm && !notif.acknowledged) {
					hasAlarm = true
				}
			}
		}
		_numberOfActiveNotifications.setValue(activeCount)
		_alarm.setValue(hasAlarm)
	}

	function updateAlert() {
		for (let i = 0 ; i < notifications.length; ++i) {
			const notif = notifications[i]
			if (!notif.acknowledged) {
				_alert.setValue(1)
				return
			}
		}
		_alert.setValue(0)
	}

	function populate() {
		for (let i = 0; i < dummyNotifications.length; ++i) {
			addNotification(dummyNotifications[i])
		}
		dummyNotificationNumber = notifications.length + 1
	}

	Component.onCompleted: {
		root.date26MinutesAgo.setMinutes(root.date26MinutesAgo.getMinutes() - 26)
		root.date2h10mAgo.setMinutes(root.date2h10mAgo.getMinutes() - 130)
		root.date1dAgo.setHours(root.date1dAgo.getHours() - 24)
		root.date8dAgo.setDate(root.date8dAgo.getDate() - 8)
		populate()
	}
}
