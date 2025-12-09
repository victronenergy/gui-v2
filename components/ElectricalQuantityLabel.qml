/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Shows a quantity in Amps or Watts depending on the user-preferred display mode, as per
	Global.systemSettings.electricalPowerDisplay:

	- PreferWatts: show dataObject.power in Watts.
	- PreferAmps: show dataObject.current in Amps, if the current is valid. Otherwise, show
	  dataObject.power in Watts.
	- Mixed: if sourceType=ElectricalQuantity_Source_Dc, then show dataObject.current in Amps.
	  Otherwise, show dataObject.power in Watts.

	If dataObject.<power|current> is invalid when used, the label shows "--".
*/
QuantityLabel {
	id: root

	property int sourceType: VenusOS.ElectricalQuantity_Source_Any

	// An object with 'power' and 'current' values. When showing in Amps, the current is displayed,
	// otherwise the power is displayed.
	property var dataObject

	readonly property bool _dataObjectValid: dataObject !== null && dataObject !== undefined
	readonly property bool _unitAmps: (Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferAmps
					&& !isNaN(dataObject?.current))
			|| (Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_Mixed
				&& sourceType === VenusOS.ElectricalQuantity_Source_Dc)
	readonly property real _value: !_dataObjectValid ? NaN
		: _unitAmps ? (dataObject.current ?? NaN)
		: (dataObject.power ?? NaN)

	// For AC inputs, the AcInputDirectionIcon should be present to indicate when power is negative,
	// so just show the absolute value without a minus sign.
	value: sourceType === VenusOS.ElectricalQuantity_Source_AcInputOnly
		? Math.abs(_value) // will return NaN if _value is NaN.
		: _value

	unit: _dataObjectValid ? (_unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt) : VenusOS.Units_None
}
