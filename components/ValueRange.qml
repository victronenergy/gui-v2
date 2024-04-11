/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

QtObject {
	property real minimumValue
	property real maximumValue
	property real value: NaN
	readonly property real valueAsRatio: {
		if (isNaN(value) || isNaN(minimumValue) || isNaN(maximumValue)) {
			return 0
		}
		const range = maximumValue - minimumValue
		const normalizedValue = Math.max(minimumValue, Math.min(maximumValue, value))
		return range === 0 ? 0 : (normalizedValue - minimumValue) / range
	}
}
