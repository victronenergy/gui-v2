/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	property real value: dataItem.numberValue
	property int unit: VenusOS.Units_None
	property int decimals: Units.defaultUnitPrecision(unit)

	suffix: Units.defaultUnitString(unit)
	textField.validator: DoubleValidator {
		decimals: root.decimals
		locale: Units.numberFormattingLocaleName
	}
	textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
	textField.text: Units.formatNumber(root.value, root.decimals)
}
