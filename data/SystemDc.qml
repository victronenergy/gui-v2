/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
