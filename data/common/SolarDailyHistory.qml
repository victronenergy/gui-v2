/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

// Stores the overall daily history for a solar charger, or the daily history for a single solar tracker.
QtObject {
	id: root

	// For a charger, prefix is: com.victronenergy.solarcharger.tty0/History/Daily/<day>
	// For a tracker, prefix is: com.victronenergy.solarcharger.tty0/History/Daily/<day>/Pv/<pv-index>
	property string uidPrefix

	readonly property real yieldKwh: _yieldKwh.value == undefined ? NaN : _yieldKwh.value
	readonly property real maxPower: _maxPower.value == undefined ? NaN : _maxPower.value
	readonly property real maxPvVoltage: _maxPvVoltage.value == undefined ? NaN : _maxPvVoltage.value

	readonly property real timeInFloat: _timeInFloat.value == undefined ? NaN : _timeInFloat.value
	readonly property real timeInAbsorption: _timeInAbsorption.value == undefined ? NaN : _timeInAbsorption.value
	readonly property real timeInBulk: _timeInBulk.value == undefined ? NaN : _timeInBulk.value

	readonly property real minBatteryVoltage: _minBatteryVoltage.value == undefined ? NaN : _minBatteryVoltage.value
	readonly property real maxBatteryVoltage: _maxBatteryVoltage.value == undefined ? NaN : _maxBatteryVoltage.value
	readonly property real maxBatteryCurrent: _maxBatteryCurrent.value == undefined ? NaN : _maxBatteryCurrent.value

	property SolarHistoryErrorModel errorModel: SolarHistoryErrorModel {
		uidPrefix: root.uidPrefix
	}

	//--- internal members below ---

	readonly property VeQuickItem _yieldKwh: VeQuickItem {
		uid: uidPrefix + "/Yield"
	}

	readonly property VeQuickItem _maxPower: VeQuickItem {
		uid: uidPrefix + "/MaxPower"
	}

	readonly property VeQuickItem _maxPvVoltage: VeQuickItem {
		uid: uidPrefix + "/MaxPvVoltage"
	}

	readonly property VeQuickItem _timeInFloat: VeQuickItem {
		uid: uidPrefix + "/TimeInFloat"
	}

	readonly property VeQuickItem _timeInAbsorption: VeQuickItem {
		uid: uidPrefix + "/TimeInAbsorption"
	}

	readonly property VeQuickItem _timeInBulk: VeQuickItem {
		uid: uidPrefix + "/TimeInBulk"
	}

	readonly property VeQuickItem _minBatteryVoltage: VeQuickItem {
		uid: uidPrefix + "/MinBatteryVoltage"
	}

	readonly property VeQuickItem _maxBatteryVoltage: VeQuickItem {
		uid: uidPrefix + "/MaxBatteryVoltage"
	}

	readonly property VeQuickItem _maxBatteryCurrent: VeQuickItem {
		uid: uidPrefix + "/MaxBatteryCurrent"
	}
}
