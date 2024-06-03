/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix

	readonly property real voltage: _voltage.numberValue
	readonly property real current: _current.numberValue
	readonly property real frequency: _frequency.numberValue

	// If the power is not reported, calculate the apparent power
	readonly property real power: _reportedPower.isValid ? _reportedPower.numberValue
			 : _apparentPower.isValid ? _apparentPower.numberValue
			 : (_voltage.isValid && _current.isValid) ? _voltage.numberValue * _current.numberValue
			 : NaN
	readonly property int powerUnit: _reportedPower.isValid ? VenusOS.Units_Watt : VenusOS.Units_VoltAmpere

	property VeQuickItem _voltage: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/V" : ""
	}

	property VeQuickItem _current: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/I" : ""
	}

	property VeQuickItem _reportedPower: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/P" : ""
	}

	property VeQuickItem _apparentPower: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/S" : ""
	}

	property VeQuickItem _frequency: VeQuickItem {
		uid: root.bindPrefix ? root.bindPrefix + "/F" : ""
	}
}
