/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	property real minimumValue
	property real maximumValue
	property real value: NaN
	readonly property real valueAsRatio: {
		if (isNaN(value) || isNaN(minimumValue) || isNaN(maximumValue)) {
			return 0
		}
		// Scale the value from the min-max range to a 0-1 range.
		return Utils.scaleNumber(value, minimumValue, maximumValue, 0, 1)
	}
}
