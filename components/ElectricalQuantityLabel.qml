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
	readonly property bool _unitAmps: !!dataObject && !isNaN(dataObject.current) && Global.systemSettings.electricalQuantity === VenusOS.Units_Amp

	value: {
		if (dataObject == null) { // double equals to catch undefined and null
			return NaN
		}
		const v = _unitAmps ? dataObject.current : dataObject.power
		if (acInputMode) {
			// For AC inputs, if an AcInputDirectionIcon is present to indicate when power is negative,
			// then the minus sign is not necessary. In this case, if feed-in to grid is enabled, omit
			// the minus sign and just show the absolute value.
			return Global.systemSettings.essFeedbackToGridEnabled ? Math.abs(v) : v
		}
		return v
	}

	unit: _unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
}
