/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: battery

	readonly property real stateOfCharge: _stateOfCharge.value === undefined ? NaN : _stateOfCharge.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real temperature_celsius: _temperature.value === undefined ? NaN : _temperature.value
	readonly property real timeToGo: _timeToGo.value === undefined ? NaN : _timeToGo.value
	readonly property string icon: !!Global.batteries ? Global.batteries.batteryIcon(battery) : ""
	readonly property int mode: !!Global.batteries ? Global.batteries.batteryMode(battery) : -1

	readonly property DataPoint _stateOfCharge: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Soc"
	}

	readonly property DataPoint _voltage: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Voltage"
	}

	readonly property DataPoint _power: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Power"
	}

	readonly property DataPoint _current: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Current"
	}

	readonly property DataPoint _temperature: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/Temperature"
	}

	readonly property DataPoint _timeToGo: DataPoint {
		source: Global.system.serviceUid + "/Dc/Battery/TimeToGo"
	}
}
