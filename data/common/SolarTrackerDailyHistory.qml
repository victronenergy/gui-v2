/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// Stores the overall daily history for a single solar tracker.
QtObject {
	id: root

	// Prefix is: com.victronenergy.solarcharger.tty0/History/Daily/<day>/Pv/<pv-index>
	property string uidPrefix

	readonly property real yieldKwh: _yieldKwh.isValid ? _yieldKwh.value : NaN
	readonly property real maxPower: _maxPower.isValid ? _maxPower.value : NaN
	readonly property real maxVoltage: _maxVoltage.isValid ? _maxVoltage.value : NaN

	//--- internal members below ---

	readonly property VeQuickItem _yieldKwh: VeQuickItem {
		uid: uidPrefix + "/Yield"
	}

	readonly property VeQuickItem _maxPower: VeQuickItem {
		uid: uidPrefix + "/MaxPower"
	}

	readonly property VeQuickItem _maxVoltage: VeQuickItem {
		uid: uidPrefix + "/MaxVoltage"
	}
}
