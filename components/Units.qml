/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQuick
import Victron.VenusOS

QtObject {
	// TODO: add other quantites as needed, eg. Distance, Volume
	enum PhysicalQuantity {
		Voltage,
		Current,
		Power
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
		var rv = { number: -1, units: "" }
		switch (physicalQuantity) {
		case Units.Power:
			rv = {
				number: parseFloat((value < 1000 ? value : (value / 1000)).toPrecision(precision)),
				units: (value < 1000) ? "W" : "kW"
			}
			break;
		case Units.Voltage:
			rv = {
				number: parseFloat((value < 1000 ? value : (value / 1000)).toPrecision(precision)),
				units: (value < 1000) ? "V" : "kV"
			}
			break;
		case Units.Current:
			rv = {
				number: parseFloat((value < 1000 ? value : (value / 1000)).toPrecision(precision)),
				units: (value < 1000) ? "A" : "kA"
			}
			break;
		default:
			break;
		}
		return rv
	}
}
