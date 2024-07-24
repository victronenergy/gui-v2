/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	property int maximumLength

	readonly property var validateIntInput: function() {
		const trimmed = textField.text.trim()
		if (!trimmed.match(/^[0-9]+$/)) {
			return validationResult(VenusOS.InputValidation_Result_Error, CommonWords.error_nan.arg(textField.text))
		}
		if (maximumLength > 0 && trimmed.length > maximumLength) {
			//% "Use a number with %1 digits or less."
			return validationResult(VenusOS.InputValidation_Result_Error, qsTrId("number_field_input_too_long").arg(maximumLength))
		}
		return validationResult(VenusOS.InputValidation_Result_OK)
	}

	textField.inputMethodHints: Qt.ImhDigitsOnly
	validateInput: validateIntInput
	saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(parseInt(textField.text))
		}
	}
}
