/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	property real value: dataItem.valid ? dataItem.value : NaN
	property int unit: VenusOS.Units_None
	property int decimals: Units.defaultUnitPrecision(unit)

	suffix: Units.defaultUnitString(unit)
	textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
	textField.text: Units.formatNumber(root.value, root.decimals)
	validateInput: function() {
		const numberValue = Units.formattedNumberToReal(textField.text)
		if (isNaN(numberValue)) {
		   return Utils.validationResult(VenusOS.InputValidation_Result_Error, CommonWords.error_nan.arg(textField.text))
		}

		// In case the user has entered a number with a greater precision than what is supported,
		// adjust the precision of the displayed number.
		const formattedNumber = Units.formatNumber(numberValue, root.decimals)
		return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", formattedNumber)
	}
	saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(Units.formattedNumberToReal(textField.text))
		}
	}
}
