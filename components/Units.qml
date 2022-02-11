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
		let number = isNaN(value)
			? "--"
			: parseFloat((value < 1000 ? value : (value / 1000)).toPrecision(precision))
		let rv
		switch (physicalQuantity) {
		case Units.PhysicalQuantity.Power:
			rv = {
				number: number,
				units: (value < 1000) ? "W" : "kW"
			}
			break;
		case Units.PhysicalQuantity.Voltage:
			rv = {
				number: number,
				units: (value < 1000) ? "V" : "kV"
			}
			break;
		case Units.PhysicalQuantity.Current:
			rv = {
				number: number,
				units: (value < 1000) ? "A" : "kA"
			}
			break;
		case Units.PhysicalQuantity.Percentage:
			rv = {
				number: number,
				units: "%"
			}
			break;
		case Units.PhysicalQuantity.Temperature:
			rv = {
				number: number,
				units: "°"
			}
			break;
		default:
			rv = { number: -1, units: "" }
			break;
		}
		return rv
	}
}
