/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Stores the overall daily history for a solar charger.
QtObject {
	id: root

	// Prefix is: com.victronenergy.solarcharger.tty0/History/Daily/<day>
	property string uidPrefix

	readonly property real yieldKwh: _yieldKwh.numberValue
	readonly property real maxPower: _maxPower.numberValue
	readonly property real maxPvVoltage: _maxPvVoltage.numberValue

	readonly property real timeInFloat: _timeInFloat.numberValue
	readonly property real timeInAbsorption: _timeInAbsorption.numberValue
	readonly property real timeInBulk: _timeInBulk.numberValue

	readonly property real minBatteryVoltage: _minBatteryVoltage.numberValue
	readonly property real maxBatteryVoltage: _maxBatteryVoltage.numberValue
	readonly property real maxBatteryCurrent: _maxBatteryCurrent.numberValue

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
