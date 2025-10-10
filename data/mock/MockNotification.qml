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

	property date _invalidDate

	readonly property VeQuickItem _silenced: VeQuickItem {
		uid: notification.serviceUid ? notification.serviceUid + "/Silenced" : ""
	}

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

	readonly property int notificationId: 0 // slot index
	readonly property bool acknowledged: !!_acknowledged.value
	readonly property bool silenced: !!_silenced.value
	readonly property bool active: _active.valid ? _active.value : true // assume active by default.
	readonly property int type: _type.valid ? parseInt(_type.value) : -1
	readonly property date dateTime: _dateTime.valid ? new Date(_dateTime.value * 1000) : _invalidDate
	readonly property string deviceName: _deviceName.value || ""
	readonly property string description: _description.value || ""
	readonly property string value: _value.value || ""
}
