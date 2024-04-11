/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

QtObject {
	property real value: NaN
	readonly property real valueAsRatio: _valueAsRatio
	property real maximumValue: NaN  // if NaN, _max is dynamically adjusted to the maximum encountered value
	readonly property real maximumSeen: isNaN(maximumValue) ? _max : _actualMaximum
	readonly property real minimumSeen: _min

	property real _valueAsRatio: 0
	property real _min: NaN
	property real _max: isNaN(maximumValue) ? NaN : maximumValue
	property real _actualMaximum: NaN

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

		if (isNaN(maximumValue)) {
			_max = Math.max(_max, value)
		} else {
			_max = maximumValue
			_actualMaximum = Math.max(_actualMaximum, value)
		}

		if (!isNaN(_max) && value >= _max) {
			_valueAsRatio = 1
			return
		}
		const ratio = (value - _min) / (_max - _min)
		_valueAsRatio = ratio === Infinity ? 0 : ratio
	}
}
