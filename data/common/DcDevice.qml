/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: dcDevice

	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real power: _power.value === undefined ? NaN : _power.value

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: dcDevice.serviceUid + "/Dc/0/Voltage"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: dcDevice.serviceUid + "/Dc/0/Current"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: dcDevice.serviceUid + "/Dc/0/Power"
	}
}
