/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: dcDevice

	readonly property real voltage: _voltage.valid ? _voltage.value : NaN
	readonly property real current: _current.valid ? _current.value : NaN
	readonly property real power: _power.valid ? _power.value : NaN

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
