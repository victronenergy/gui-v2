/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string serviceUid
	readonly property real frequency: _frequency.numberValue
	readonly property real current: _current.numberValue
	readonly property real voltage: _voltage.numberValue
	readonly property real power: _power.numberValue
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
