/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemServiceUid
	readonly property real stateOfCharge: _stateOfCharge.isValid ? _stateOfCharge.value : NaN
	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN
	readonly property real power: _power.isValid ? _power.value : NaN
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real temperature: _temperature.isValid ? _temperature.value : NaN
	readonly property real timeToGo: _timeToGo.isValid ? _timeToGo.value : NaN
	readonly property string icon: VenusOS.battery_iconFromMode(mode)
	readonly property int mode: VenusOS.battery_modeFromPower(power)

	readonly property VeQuickItem _stateOfCharge: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/Soc"
	}

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/Voltage"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/Power"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/Current"
	}

	readonly property VeQuickItem _temperature: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/Temperature"
	}

	readonly property VeQuickItem _timeToGo: VeQuickItem {
		uid: root.systemServiceUid + "/Dc/Battery/TimeToGo"
	}
}
