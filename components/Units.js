/*
** Copyright (C) 2021 Victron Energy B.V.
*/

.pragma library
.import Victron.VenusOS as V
.import Utils as Utils

function defaultUnitPrecision(unit) {
	return unit === V.VenusOS.Units_Energy_KiloWattHour ? 2
			: (unit === V.VenusOS.Units_Percentage
			   || unit === V.VenusOS.Units_Watt
			   || unit === V.VenusOS.Units_Temperature_Celsius
			   || unit === V.VenusOS.Units_Temperature_Fahrenheit) ? 0
			: 1
}

/*
	Returns the physical quantity in a map of { number, unit }.

	The number is scaled if the absolute value is >= 10,000 (e.g. 10000 W = 10kW).
*/
function getDisplayText(unit, value, precision, unitMatchValue = undefined) {
	switch (unit) {
	case V.VenusOS.Units_Watt:
		return _scaledQuantity(value, unitMatchValue, precision, "W", "kW")
	case V.VenusOS.Units_Volt:
		return _scaledQuantity(value, unitMatchValue, precision, "V", "kV")
	case V.VenusOS.Units_Amp:
		return _scaledQuantity(value, unitMatchValue, precision, "A", "kA")
	case V.VenusOS.Units_Energy_KiloWattHour:
		return _scaledQuantity(value, unitMatchValue, precision, "kWh")
	case V.VenusOS.Units_Percentage:
		return _scaledQuantity(value, unitMatchValue, precision, "%")
	case V.VenusOS.Units_Temperature_Celsius:
	case V.VenusOS.Units_Temperature_Fahrenheit:
		// \u00b0 = degrees symbol
		return _scaledQuantity(value, unitMatchValue, precision, "\u00b0")
	case V.VenusOS.Units_Volume_Liter:
		// \u2113 = l, \u3398 = kl
		return _scaledQuantity(value, unitMatchValue, precision, "\u2113", "\u3398")
	case V.VenusOS.Units_Volume_CubicMeter:
		// \u33A5 is not supported by the font, so use two characters \u006D\u00B3 instead.
		return _scaledQuantity(value, unitMatchValue, precision, "m³")
	case V.VenusOS.Units_Volume_GallonUS:
	case V.VenusOS.Units_Volume_GallonImperial:
		return _scaledQuantity(value, unitMatchValue, precision, "gal")
	default:
		console.warn("getDisplayText(): unknown unit", unit, "with value", value)
		return { number: "--", unit: "" }
	}
}

function getCapacityDisplayText(unit, capacity_m3, remaining_m3, precision) {
	const capacity = convertVolumeForUnit(capacity_m3, unit)
	const remaining = convertVolumeForUnit(remaining_m3, unit)

	// Use the capacity to determine the unit to be displayed for both 'remaining' and 'capacity'
	const remainingDisplay = getDisplayText(unit, remaining, precision, capacity)
	const capacityDisplay = getDisplayText(unit, capacity, precision)
	return ("%1/%2%3")
			.arg(remainingDisplay.number)
			.arg(capacityDisplay.number)
			.arg(capacityDisplay.unit)
}

function _scaledQuantity(value, unitMatchValue, precision, baseUnit, scaledUnit) {
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
		// If value is between -1 and 1, but is not zero, show one decimal precision regardless of
		// precision parameter, to avoid showing just '0'.
		// And if showing percentages, avoid showing '100%' if value is between 99-100.
		if ((precision === 0 && value !== 0 && Math.abs(value) < 1)
				|| (quantity.unit === "%" && value > 99 && value < 100)) {
			value = value.toFixed(1)
		} else {
			value = value.toFixed(precision)
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
