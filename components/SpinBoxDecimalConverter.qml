/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	required property int decimals
	property real from
	property real to
	property real stepSize

	readonly property int intFrom: Math.max(Global.int32Min, from * decimalFactor)
	readonly property int intTo: Math.min(Global.int32Max, to * decimalFactor)
	readonly property int intStepSize: stepSize * decimalFactor

	readonly property int decimalFactor: Math.pow(10, decimals)

	function decimalToInt(value) {
		// Round the number to adjust for loss of precision in values reported from the backend
		return Math.round(value * decimalFactor)
	}

	function intToDecimal(value) {
		return value / decimalFactor
	}

	function textFromValue(value) {
		return Units.formatNumber(value / decimalFactor, decimals)
	}

	function valueFromText(text) {
		return Units.formattedNumberToReal(text) * decimalFactor
	}
}
