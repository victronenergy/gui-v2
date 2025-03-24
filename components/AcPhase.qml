/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string serviceUid
	readonly property real frequency: _frequency.valid ? _frequency.value : NaN
	readonly property real current: _current.valid ? _current.value : NaN
	readonly property real voltage: _voltage.valid ? _voltage.value : NaN
	readonly property real power: _power.valid ? _power.value : NaN

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
