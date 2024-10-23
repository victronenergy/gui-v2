/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: battery

	readonly property real stateOfCharge: _stateOfCharge.isValid ? _stateOfCharge.value : NaN
	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real temperature: _temperature.isValid ? _temperature.value : NaN
	readonly property real timeToGo: _timeToGo.isValid ? _timeToGo.value : NaN // in seconds
	readonly property string icon: !!Global.batteries ? Global.batteries.batteryIcon(power) : ""
	readonly property int mode: !!Global.batteries ? Global.batteries.batteryMode(power) : -1
	readonly property bool isParallelBms: _numberOfBmses.isValid
	readonly property int state: _state.isValid ? _state.value : NaN

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

	property VeQuickItem _numberOfBmses: VeQuickItem {
		uid: battery.serviceUid + "/NumberOfBmses"
	}

	property VeQuickItem _state: VeQuickItem {
		uid: battery.serviceUid + "/State"
	}
}
