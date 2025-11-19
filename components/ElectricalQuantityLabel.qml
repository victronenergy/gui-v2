/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Shows a quantity in Amps or Watts depending on the user-preferred display mode, as per
	Global.systemSettings.electricalPowerDisplay.

	Depending on the preferred mode:
	- PreferWatts: show dataObject.power in Watts.
	- PreferAmps: if dataObject.current is valid, show it in Amps, otherwise show dataObject.power
	  in Watts.
	- Mixed: if 'source' is ElectricalQuantity_Source_Dc, and dataObject.current is valid, show it
	  in Amps. Otherwise, show dataObject.power in Watts.
*/
QuantityLabel {
	id: root

	property int sourceType: VenusOS.ElectricalQuantity_Source_Any

	// An object with 'power' and 'current' values. When showing in Amps, the current is displayed,
	// otherwise the power is displayed.
	property var dataObject
	property bool acInputMode

	readonly property bool _dataObjectValid: dataObject !== null && dataObject !== undefined
	readonly property bool _unitAmps: (Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferAmps
			|| (Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_Mixed
				&& sourceType === VenusOS.ElectricalQuantity_Source_Dc))
			&& _dataObjectValid
			&& !isNaN(dataObject.current)
	readonly property real _value: !_dataObjectValid ? NaN
		: _unitAmps ? dataObject.current
		: dataObject.power

	// For AC inputs, the AcInputDirectionIcon should be present to indicate when power is negative,
	// so just show the absolute value without a minus sign.
	value: acInputMode ? Math.abs(_value) // will return NaN if _value is NaN.
		: _value

	unit: _unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
}
