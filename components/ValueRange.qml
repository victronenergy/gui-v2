/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import "/components/Utils.js" as Utils

QtObject {
	property real value: NaN
	readonly property real valueAsRatio: _valueAsRatio

	property real _valueAsRatio: 0
	property real _min: NaN
	property real _max: NaN

	onValueChanged: {
		if (isNaN(value)) {
			_valueAsRatio = 0
			return
		} else if (isNaN(_min) || isNaN(_max)) {
			_min = value
			_max = value
			_valueAsRatio = 1
			return
		}
		_min = Math.min(_min, value)
		_max = Math.max(_max, value)
		const ratio = (value - _min) / (_max - _min)
		_valueAsRatio = ratio === Infinity ? 0 : ratio
	}
}
