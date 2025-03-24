/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseNotification {
	id: notification

	readonly property string serviceUid: notificationId < 0 ? ""
			: Global.notifications.serviceUid + "/" + notificationId

	property var _currentModel
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

	readonly property Connections _ackConn: Connections {
		target: Global.notifications
		function onAcknowledgeNotification(notificationId) {
			if (notificationId === notification.notificationId) {
				_acknowledged.setValue(1)
			}
		}
	}

	readonly property bool _canInitialize: _acknowledged.value !== undefined
			   && _active.value !== undefined
			   && _type.value !== undefined
			   && _dateTime.value !== undefined
	on_CanInitializeChanged: _init()

	readonly property bool _isHistorical: !active && acknowledged
	on_IsHistoricalChanged: {
		if (!!_currentModel) {
			const newModel = _targetModel()
			if (newModel !== _currentModel) {
				_currentModel.removeNotification(notificationId)
				newModel.insertByDate(notification)
				_currentModel = newModel
			}
		}
	}

	function setAcknowledged(ack) {
		 _acknowledged.setValue(ack ? 1 : 0)
	}

	function _init() {
		if (!!_currentModel || !_canInitialize) {
			return
		}
		const model = _targetModel()
		model.insertByDate(notification)
		_currentModel = model
	}

	function _targetModel() {
		if (_isHistorical) {
			return Global.notifications.historicalModel
		} else {
			return Global.notifications.activeModel
		}
	}

	acknowledged: !!_acknowledged.value
	active: !!_active.value
	type: _type.valid ? parseInt(_type.value) : -1
	dateTime: _dateTime.valid ? new Date(_dateTime.value * 1000) : _invalidDate
	deviceName: _deviceName.value || ""
	description: _description.value || ""
	value: _value.value || ""

	Component.onDestruction: {
		if (_currentModel) {
			_currentModel.removeNotification(notificationId)
		}
	}
}
