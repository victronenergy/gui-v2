/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix

	readonly property real voltage: _voltage.isValid ? _voltage.value : NaN
	readonly property real current: _current.isValid ? _current.value : NaN
	readonly property real frequency: _frequency.isValid ? _frequency.value : NaN

	// If the power is not reported, calculate the apparent power
	readonly property real power: _reportedPower.isValid ? _reportedPower.value : _apparentPower.isValid ? _apparentPower.value : _voltage.isValid && _current.isValid ? _voltage.value * _current.value : NaN
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
