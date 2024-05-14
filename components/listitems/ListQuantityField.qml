/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	property real value: dataItem.isValid ? dataItem.value : NaN
	property int unit: VenusOS.Units_None
	property int decimals: Units.defaultUnitPrecision(unit)

	suffix: Units.defaultUnitString(unit)
	textField.validator: DoubleValidator {}
	textField.inputMethodHints: Qt.ImhDigitsOnly
	textField.text: tryAcceptInput(value)

	tryAcceptInput: function(inputText) {
		const n = Number(inputText)
		if (isNaN(n)) {
			return "--"
		}
		return n.toFixed(root.decimals)
	}
}
