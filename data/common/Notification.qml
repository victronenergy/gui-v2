/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseNotification {
	id: notification

	readonly property string serviceUid: notificationId < 0 ? ""
															: Global.notifications.serviceUid + "/" + notificationId

	property date _invalidDate

	readonly property VeQuickItem _acknowledged: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Acknowledged" : ""
	}

	readonly property VeQuickItem _active: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Active" : ""
	}

	readonly property VeQuickItem _type: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Type" : ""
	}

	readonly property VeQuickItem _dateTime: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/DateTime" : ""
	}

	readonly property VeQuickItem _deviceName: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/DeviceName" : ""
	}

	readonly property VeQuickItem _description: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Description" : ""
	}

	readonly property VeQuickItem _value: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Value" : ""
	}

	readonly property bool _canInitialize: _acknowledged.value !== undefined
										   && _active.value !== undefined
										   && _type.value !== undefined
										   && _dateTime.value !== undefined
	on_CanInitializeChanged: _init()

	function updateAcknowledged(acknowledged: bool) {
		_acknowledged.setValue(acknowledged ? 1 : 0)
	}

	function updateActive(active: bool) {
		_active.setValue(active ? 1 : 0)
	}

	function _init() {
		if (!Global.notifications.allNotificationsModel || !_canInitialize) {
			return
		}
		// insert into the allNotificationsModel
		Global.notifications.allNotificationsModel.insertNotification(notification)
	}

	// These properties should not be written to; use updateAcknowledged() and updateActive() functions
	// to maintain data sync and not break bindings.
	acknowledged: !!_acknowledged.value
	active: !!_active.value
	type: _type.valid ? parseInt(_type.value) : -1
	dateTime: _dateTime.valid ? new Date(_dateTime.value * 1000) : _invalidDate
	deviceName: _deviceName.value || ""
	description: _description.value || ""
	value: _value.value || ""

	Component.onDestruction: {
		// remove from the allNotificationsModel
		Global.notifications.allNotificationsModel.removeNotification(notification)
	}
}
