/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: evCharger

	readonly property int status: _status.valid ? _status.value : -1
	readonly property int mode: _mode.valid ? _mode.value : -1
	readonly property bool connected: _connected.value === 1
	readonly property int chargingTime: _chargingTime.value || 0
	readonly property int position: _position.valid ? _position.value : VenusOS.AcPosition_Unknown

	readonly property real energy: _energy.valid ? _energy.value : NaN
	readonly property real power: _power.valid ? _power.value : NaN
	readonly property real current: _current.valid ? _current.value : NaN
	readonly property real maxCurrent: _maxCurrent.valid ? _maxCurrent.value : NaN

	readonly property VeQuickItem _energy: VeQuickItem {
		uid: evCharger.serviceUid + "/Session/Energy"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: evCharger.serviceUid + "/Ac/Power"
	}

	readonly property VeQuickItem _chargingTime: VeQuickItem {
		uid: evCharger.serviceUid + "/ChargingTime"
	}

	readonly property VeQuickItem _connected: VeQuickItem {
		uid: evCharger.serviceUid + "/Connected"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: evCharger.serviceUid + "/Current"
	}

	readonly property VeQuickItem _maxCurrent: VeQuickItem {
		uid: evCharger.serviceUid + "/MaxCurrent"
	}

	readonly property VeQuickItem _mode: VeQuickItem {
		uid: evCharger.serviceUid + "/Mode"
	}

	readonly property VeQuickItem _status: VeQuickItem {
		uid: evCharger.serviceUid + "/Status"
	}

	readonly property VeQuickItem _position: VeQuickItem {
		uid: evCharger.serviceUid + "/Position"
	}
}
