/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: battery

	readonly property real stateOfCharge: _stateOfCharge.value === undefined ? NaN : _stateOfCharge.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property real timeToGo: _timeToGo.value === undefined ? NaN : _timeToGo.value  // in seconds
	readonly property string icon: !!Global.batteries ? Global.batteries.batteryIcon(battery) : ""
	readonly property int mode: !!Global.batteries ? Global.batteries.batteryMode(battery) : -1

	readonly property VeQuickItem _stateOfCharge: VeQuickItem {
		uid: battery.serviceUid + "/Soc"
	}

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: battery.serviceUid + "/Dc/0/Voltage"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: battery.serviceUid + "/Dc/0/Power"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: battery.serviceUid + "/Dc/0/Current"
	}

	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: battery.serviceUid + "/Dc/0/Temperature"
	}

	readonly property VeQuickItem _timeToGo: VeQuickItem {
		uid: battery.serviceUid + "/TimeToGo"
	}

	onValidChanged: {
		if (!!Global.batteries) {
			if (valid) {
				Global.batteries.addBattery(battery)
			} else {
				Global.batteries.removeBattery(battery)
			}
		}
	}
}
