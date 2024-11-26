/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListIntField {
	id: root

	//% "Port"
	text: qsTrId("port_field_title")
	placeholderText: "80"
	validateInput: function() {
		// Check whether the input is a number
		const intValidationResult = validateIntInput()
		if (intValidationResult.status === VenusOS.InputValidation_Result_Error) {
			return intValidationResult
		}

		// Check whether the input is a valid port
		const valueAsInt = parseInt(textField.text)
		if (isNaN(valueAsInt) || valueAsInt < 0 || valueAsInt > 65535) {
			//% "'%1' is not a valid port number. Use a number between 0-65535."
			return Utils.validationResult(VenusOS.InputValidation_Result_Error, qsTrId("port_input_not_valid").arg(textField.text))
		}
		return Utils.validationResult(VenusOS.InputValidation_Result_OK)
	}
}
