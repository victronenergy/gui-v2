/*
** Copyright (C) 2021 Victron Energy B.V.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	enum ValueType {
		RisingPercentage,
		FallingPercentage
	}

	function statusFromRisingValue(value) {
		if (value >= 85) return Theme.Critical
		if (value >= 60) return Theme.Warning
		return Theme.Ok
	}

	function statusFromFallingValue(value) {
		if (value <= 15) return Theme.Critical
		if (value <= 40) return Theme.Warning
		return Theme.Ok
	}

	function getValueStatus(value, valueType) {
		if (valueType === Gauges.RisingPercentage) {
			return statusFromRisingValue(value)
		}
		if (valueType === Gauges.FallingPercentage) {
			return statusFromFallingValue(value)
		}
		return Theme.Ok
	}
}
