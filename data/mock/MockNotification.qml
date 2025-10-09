/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: notification

	readonly property string serviceUid: notificationId < 0 ? ""
			: ("" + BackendConnection.serviceUidForType("platform") + "/Notifications" + "/" + notificationId)

	readonly property VeQuickItem _service: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Service" : ""
	}

	readonly property VeQuickItem _dateTime: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/DateTime" : ""
	}

	readonly property VeQuickItem _trigger: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Trigger" : ""
	}

	readonly property VeQuickItem _alarmValue: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/AlarmValue" : ""
	}

	readonly property VeQuickItem _deviceName: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/DeviceName" : ""
	}

	readonly property VeQuickItem _value: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Value" : ""
	}

	readonly property VeQuickItem _type: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Type" : ""
	}

	readonly property VeQuickItem _active: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Active" : ""
	}

	readonly property VeQuickItem _acknowledged: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Acknowledged" : ""
	}

	readonly property VeQuickItem _silenced: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Silenced" : ""
	}

	readonly property VeQuickItem _description: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Description" : ""
	}

	readonly property int notificationId: 0 // slot index
	readonly property bool acknowledged: _acknowledged.valid ? _acknowledged.value : false
	readonly property bool active: _active.valid ? _active.value : false
}
