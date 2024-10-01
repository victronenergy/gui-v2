/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: battery

	readonly property real stateOfCharge: _stateOfCharge.isValid ? _stateOfCharge.value : NaN
	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real temperature: _temperature.isValid ? _temperature.value : NaN
	readonly property real timeToGo: _timeToGo.isValid ? _timeToGo.value : NaN
	readonly property string icon: !!Global.batteries ? Global.batteries.batteryIcon(battery) : ""
	readonly property int mode: !!Global.batteries ? Global.batteries.batteryMode(battery) : -1

	readonly property VeQuickItem _stateOfCharge: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/Soc"
	}

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/Voltage"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/Power"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/Current"
	}

	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/Temperature"
	}

	readonly property VeQuickItem _timeToGo: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/Battery/TimeToGo"
	}
}
