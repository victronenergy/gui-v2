/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import "/components/Utils.js" as Utils

QtObject {
	property real value: NaN
	readonly property real valueAsRatio: _valueAsRatio
	property real maximumValue: NaN  // if NaN, the max is dynamically adjusted to the maximum encountered value

	property real _valueAsRatio: 0
	property real _min: NaN
	property real _max: isNaN(maximumValue) ? NaN : maximumValue

	onValueChanged: {
		// If value=NaN, or if only one value has been received, the min/max cannot yet be
		// calculated. In these cases, use 0 for the value ratio.
		if (isNaN(value)) {
			_valueAsRatio = 0
			return
		} else if (isNaN(_min) || isNaN(_max)) {
			_min = value
			_max = value
			_valueAsRatio = 0
			return
		}
		_min = Math.min(_min, value)
		_max = isNaN(maximumValue) ? Math.max(_max, value) : maximumValue
		if (!isNaN(_max) && value >= _max) {
			_valueAsRatio = 1
			return
		}
		const ratio = (value - _min) / (_max - _min)
		_valueAsRatio = ratio === Infinity ? 0 : ratio
	}
}
