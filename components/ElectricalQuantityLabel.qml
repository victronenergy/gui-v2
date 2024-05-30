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
	readonly property bool _feedbackEnabled: Global.systemSettings.essFeedbackToGridEnabled && acInputMode
	readonly property real _value: !_dataObjectValid ? NaN
		: _unitAmps ? dataObject.current
		: dataObject.power

	// For AC inputs, if an AcInputDirectionIcon is present to indicate when power is negative,
	// then the minus sign is not necessary. In this case, if feed-in to grid is enabled, omit
	// the minus sign and just show the absolute value.
	// Don't use AcInputs.clampMeasurement() in this hot-path binding.
	value: _feedbackEnabled ? Math.abs(_value) // will return NaN if _value is NaN.
		: acInputMode ? Math.max(0, _value)    // will return NaN if _value is NaN.
		: _value

	unit: _unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
}
