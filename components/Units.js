/*
** Copyright (C) 2021 Victron Energy B.V.
*/

.pragma library
.import Victron.VenusOS as V
.import "/components/Utils.js" as Utils

/*
	Returns the physical quantity in a map of { number, unit }.

	The number is scaled if the absolute value is >= 10,000 (e.g. 10000 W = 10kW) and the
	precision and decimal places are adjusted according to the specified length.

	E.g. if length=4:

	0.0345 W => 0.035 W
	10.0345 W => 10.03 W
	100.345 W => 100.3 W
	1000.345 W => 1000 W
	10000.345 W => 10 kW
*/
function getDisplayText(unit, value, length, unitMatchValue = undefined) {
	switch (unit) {
	case V.VenusOS.Units_Energy_Watt:
		return _scaledQuantity(value, unitMatchValue, length, "W", "kW")
	case V.VenusOS.Units_Potential_Volt:
		return _scaledQuantity(value, unitMatchValue, length, "V", "kV")
	case V.VenusOS.Units_Energy_Amp:
		return _scaledQuantity(value, unitMatchValue, length, "A", "kA")
	case V.VenusOS.Units_Percentage:
		return _scaledQuantity(value, unitMatchValue, length, "%")
	case V.VenusOS.Units_Temperature_Celsius:
	case V.VenusOS.Units_Temperature_Fahrenheit:
		// \u00b0 = degrees symbol
		return _scaledQuantity(value, unitMatchValue, length, "\u00b0")
	case V.VenusOS.Units_Volume_Liter:
		// \u2113 = l, \u3398 = kl
		return _scaledQuantity(value, unitMatchValue, length, "\u2113", "\u3398")
	case V.VenusOS.Units_Volume_CubicMeter:
		// \u33A5 = m3
		return _scaledQuantity(value, unitMatchValue, length, "\u33A5")
	case V.VenusOS.Units_Volume_GallonUS:
	case V.VenusOS.Units_Volume_GallonImperial:
		return _scaledQuantity(value, unitMatchValue, length, "gal")
	default:
		console.warn("getDisplayText(): unknown unit", unit, "with value", value)
		return { number: "--", unit: "" }
	}
}

function getCapacityDisplayText(unit, capacity_m3, remaining_m3, length) {
	const capacity = convertVolumeForUnit(capacity_m3, unit)
	const remaining = convertVolumeForUnit(remaining_m3, unit)

	// Use the capacity to determine the unit to be displayed for both 'remaining' and 'capacity'
	const remainingDisplay = getDisplayText(unit, remaining, length, capacity)
	const capacityDisplay = getDisplayText(unit, capacity, length)
	return ("%1/%2%3")
			.arg(remainingDisplay.number)
			.arg(capacityDisplay.number)
			.arg(capacityDisplay.unit)
}

function _scaledQuantity(value, unitMatchValue, length, baseUnit, scaledUnit) {
	unitMatchValue = unitMatchValue === undefined ? value : unitMatchValue

	let quantity = {}
	if (isNaN(value)) {
		quantity.number = "--"
		quantity.unit = baseUnit
	} else {
		if (scaledUnit !== undefined && Math.abs(unitMatchValue) >= 10000) {
			quantity.unit = scaledUnit
			value = value / 1000
		} else {
			quantity.unit = baseUnit
		}
		if (quantity.unit === "W") {
			// Don't use decimals for watt values
			value = Math.round(value)
		} else {
			if (value < 1) {
				value = parseFloat(value.toFixed(length - 1))
			}
			if (length > 0) {
				// use parseFloat() to remove trailing zeros
				value = parseFloat(value.toPrecision(length))
			}
		}
		quantity.number = value
	}
	return quantity
}

function celsiusToFahrenheit(celsius) {
	return isNaN(celsius) ? celsius: (celsius * 9/5) + 32
}

function convertVolumeForUnit(value_m3, toUnit) {
	if (toUnit === V.VenusOS.Units_Volume_CubicMeter) {
		return value_m3
	} else if (toUnit === V.VenusOS.Units_Volume_Liter) {
		return value_m3 * 1000
	} else if (toUnit === V.VenusOS.Units_Volume_GallonUS) {
		return value_m3 * 264.1720523581
	} else if (toUnit === V.VenusOS.Units_Volume_GallonImperial) {
		return value_m3 * 219.9692483
	}
	console.warn("convertVolumeForUnit(): cannot convert m3 to unit", toUnit)
	return value_m3
}
