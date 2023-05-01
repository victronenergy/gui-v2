/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: battery

	readonly property real stateOfCharge: _stateOfCharge.value === undefined ? NaN : _stateOfCharge.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property real timeToGo: _timeToGo.value === undefined ? NaN : _timeToGo.value  // in seconds
	readonly property string icon: (power === 0 || power === NaN)
			? "/images/battery.svg"
			: power > 0
			  ? "/images/battery_charging.svg"
			  : "/images/battery_discharging.svg"
	readonly property int mode: (power === 0 || power === NaN)
			? VenusOS.Battery_Mode_Idle
			: (power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)

	readonly property DataPoint _stateOfCharge: DataPoint {
		source: battery.serviceUid + "/Soc"
	}

	readonly property DataPoint _voltage: DataPoint {
		source: battery.serviceUid + "/Dc/0/Voltage"
	}

	readonly property DataPoint _power: DataPoint {
		source: battery.serviceUid + "/Dc/0/Power"
	}

	readonly property DataPoint _current: DataPoint {
		source: battery.serviceUid + "/Dc/0/Current"
	}

	readonly property DataPoint _temperature: DataPoint {
		source: battery.serviceUid + "/Dc/0/Temperature"
	}

	readonly property DataPoint _timeToGo: DataPoint {
		source: battery.serviceUid + "/TimeToGo"
	}

	property bool _valid: deviceInstance.value !== undefined
	on_ValidChanged: {
		if (_valid) {
			Global.batteries.addBattery(battery)
		} else {
			Global.batteries.removeBattery(battery)
		}
	}
}
