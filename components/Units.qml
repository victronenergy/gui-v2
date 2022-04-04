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
		Temperature,
		Liters,
		CubicMeters,
		Gallons
	}

	/*	physicalQuantity	|	precision:	|	value:	|	output:
		-----------------------------------------------------------
				Power		|		5		|	1234.56	|	1.2346kW
				Power		|		4		|	1234	|	1.234kW
				Power		|		3		|	1234	|	1.23kW
				Power		|		5		|	123		|	123W
				Power		|		2		|	123		|	120W
	*/
	function getDisplayText(physicalQuantity, value, precision, unitMatchValue = undefined) {
		let unitText = ""
		unitMatchValue = unitMatchValue === undefined ? value : unitMatchValue

		switch (physicalQuantity) {
		case Units.PhysicalQuantity.Power:
			if (isNaN(value)) {
				unitText = "W"
			} else {
				value = _adjustedValue(value, precision, unitMatchValue)
				unitText = unitMatchValue < 1000 ? "W" : "kW"
			}
			break;
		case Units.PhysicalQuantity.Voltage:
			if (isNaN(value)) {
				unitText = "V"
			} else {
				value = _adjustedValue(value, precision, unitMatchValue)
				unitText = unitMatchValue < 1000 ? "V" : "kV"
			}
			break;
		case Units.PhysicalQuantity.Current:
			if (isNaN(value)) {
				unitText = "A"
			} else {
				value = _adjustedValue(value, precision, unitMatchValue)
				unitText = unitMatchValue < 1000 ? "A" : "kA"
			}
			break;
		case Units.PhysicalQuantity.Percentage:
			value = isNaN(value) ? value : Math.round(value)
			unitText = "%"
			break;
		case Units.PhysicalQuantity.Temperature:
			unitText = "\u00b0"
			break;
		case Units.PhysicalQuantity.Liters:
			if (isNaN(value)) {
				unitText = "\u2113" // 'l' symbol
			} else {
				value = _adjustedValue(value, precision, unitMatchValue)
				unitText = unitMatchValue < 1000 ? "\u2113" : "\u3398"
			}
			break;
		case Units.PhysicalQuantity.CubicMeters:
			value = isNaN(value) ? value : value.toPrecision(precision)
			unitText = "\u33A5"
			break;
		case Units.PhysicalQuantity.Gallons:
			unitText = "gal"
			break;
		default:
			break;
		}
		return {
			number: isNaN(value) ? "--" : value,
			units: unitText
		}
	}

	function getCapacityDisplayText(physicalQuantity, capacity, remaining, precision) {
		// Use the capacity to determine the unit to be displayed for both 'remaining' and 'capacity'
		const remainingDisplay = getDisplayText(physicalQuantity, remaining, precision, capacity)
		const capacityDisplay = getDisplayText(physicalQuantity, capacity, precision)
		return ("%1/%2%3")
				.arg(remainingDisplay.number)
				.arg(capacityDisplay.number)
				.arg(capacityDisplay.units)
	}

	function _adjustedValue(value, precision, unitMatchValue) {
		return parseFloat((unitMatchValue < 1000 ? value : (value / 1000)).toPrecision(precision))
	}
}
