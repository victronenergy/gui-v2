/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property string bindPrefix

	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real frequency: _frequency.value === undefined ? NaN : _frequency.value

	// If the power is not reported, calculate the apparent power
	readonly property real power: _reportedPower.value !== undefined ? _reportedPower.value
			 : _apparentPower.value !== undefined ? _apparentPower.value
			 : _voltage.value !== undefined && _current.value !== undefined ? _voltage.value * _current.value
			 : NaN
	readonly property int powerUnit: _reportedPower.value !== undefined ? VenusOS.Units_Watt : VenusOS.Units_VoltAmpere

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
