/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property real power: NaN
	readonly property real current: (isNaN(power) || isNaN(voltage) || voltage === 0) ? NaN : power / voltage
	property real voltage: NaN

	function reset() {
		power = NaN
		voltage = NaN
	}
}
