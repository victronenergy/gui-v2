/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

QtObject {
	id: root

	property string serviceUid
	readonly property real frequency: _frequency.value === undefined ? NaN : _frequency.value
	readonly property real current: _current.value === undefined ? NaN : _current.value
	readonly property real voltage: _voltage.value === undefined ? NaN : _voltage.value
	readonly property real power: _power.value === undefined ? NaN : _power.value
	readonly property bool valid: !isNaN(frequency)
								  && !isNaN(current)
								  && !isNaN(voltage)
								  && !isNaN(power)

	readonly property VeQuickItem _frequency: VeQuickItem {
		uid: serviceUid + "/F"
	}

	readonly property VeQuickItem _current: VeQuickItem {
		uid: serviceUid + "/I"
	}

	readonly property VeQuickItem _voltage: VeQuickItem {
		uid: serviceUid + "/V"
	}

	readonly property VeQuickItem _power: VeQuickItem {
		uid: serviceUid + "/P"
	}
}
