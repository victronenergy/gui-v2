/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QuantityLabel {
	id: root

	property var dataObject
	property bool acInputMode
	readonly property bool _dataObjectValid: dataObject !== null && dataObject !== undefined
	readonly property bool _unitAmps: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp && _dataObjectValid && !isNaN(dataObject.current)
	readonly property real _value: !_dataObjectValid ? NaN
		: _unitAmps ? dataObject.current
		: dataObject.power

	// For AC inputs, the AcInputDirectionIcon should be present to indicate when power is negative,
	// so just show the absolute value without a minus sign.
	value: acInputMode ? Math.abs(_value) // will return NaN if _value is NaN.
		: _value

	unit: _unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
}
