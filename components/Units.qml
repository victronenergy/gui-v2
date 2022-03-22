/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQuick

QtObject {
	// TODO: add other quantites as needed, eg. Distance, Volume
	enum PhysicalQuantity {
		Voltage,
		Current,
		Power,
		Percentage,
		Temperature
	}

	/*	physicalQuantity	|	precision:	|	value:	|	output:
		-----------------------------------------------------------
				Power		|		5		|	1234.56	|	1.2346kW
				Power		|		4		|	1234	|	1.234kW
				Power		|		3		|	1234	|	1.23kW
				Power		|		5		|	123		|	123W
				Power		|		2		|	123		|	120W
	*/
	function getDisplayText(physicalQuantity, value, precision) {
		let unitText = ""
		switch (physicalQuantity) {
		case Units.PhysicalQuantity.Power:
			value = _adjustedValue(value, precision)
			unitText = (value < 1000) ? "W" : "kW"
			break;
		case Units.PhysicalQuantity.Voltage:
			value = _adjustedValue(value, precision)
			unitText = (value < 1000) ? "V" : "kV"
			break;
		case Units.PhysicalQuantity.Current:
			value = _adjustedValue(value, precision)
			unitText = (value < 1000) ? "A" : "kA"
			break;
		case Units.PhysicalQuantity.Percentage:
			value = Math.round(value)
			unitText = "%"
			break;
		case Units.PhysicalQuantity.Temperature:
			unitText = "\u00b0"
			break;
		default:
			break;
		}
		return {
			number: isNaN(value) ? "--" : value,
			units: unitText
		}
	}

	function _adjustedValue(value, precision) {
		return parseFloat((value < 1000 ? value : (value / 1000)).toPrecision(precision))
	}
}
