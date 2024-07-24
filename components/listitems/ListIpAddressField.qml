/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	function _isValidIp(text) {
		// Do a simple IPv4 aaddress validation: 4 groups of 3 digits, separated by a decimal.
		if (!text.match(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)) {
			return false
		}
		const groups = text.split(".")
		for (let i = 0; i < groups.length; ++ i) {
			const group = parseInt(groups[i])
			if (group < 0 || group >= 256) {
				return false
			}
		}
		return true
	}

	text: CommonWords.ip_address
	placeholderText: "000.000.000.000"
	textField.inputMethodHints: Qt.ImhDigitsOnly
	validateInput: function() {
		const trimmed = textField.text.trim()
		if (!_isValidIp(trimmed)) {
			//% "'%1' is not a valid IP address."
			return validationResult(VenusOS.InputValidation_Result_Error, qsTrId("ip_address_input_not_valid").arg(trimmed))
		}
		return validationResult(VenusOS.InputValidation_Result_OK, "", trimmed)
	}
	saveInput: function() {
		if (dataItem.uid) {
			dataItem.setValue(textField.text.trim())
		}
	}
}
