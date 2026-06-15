/*
 * Copyright (C) 2024 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	name: "UnitsTest"

	function expectedAdjustedQuantity(unit, value, fixedNumbers, fixedNumberScale) {
		const baseUnitSymbol = Units.defaultUnitString(unit)

		if (isNaN(value)) {
			return { number: "--", unit: baseUnitSymbol, scale: VenusOS.Units_Scale_None }
		} else if (unit === VenusOS.Units_Watt && Math.abs(value) < 1) {
			// For Watts, values < abs(1.0) are always converted to zero, regardless of decimals.
			return { number: "0", unit: baseUnitSymbol, scale: VenusOS.Units_Scale_None }
		}

		// Scale up if there are more than 4 digits.
		let scale = VenusOS.Units_Scale_None
		let scaledValue = value
		if (Math.abs(value) > 9999) {
			while (scale < Units.maximumUnitScale(unit)) {
				scaledValue /= 1000
				scale++
				if (Math.abs(scaledValue) <= 9999) {
					break
				}
			}
		}

		// Now set the desired fixed number depending on the unit type.
		let fixedNumber
		const unitsWith4Precision = [ VenusOS.Units_AmpHour, VenusOS.Units_Energy_KiloWattHour, VenusOS.Units_VoltAmpere, VenusOS.Units_VoltAmpereReactive, VenusOS.Units_Watt ]
		if (Math.abs(value) > 9999 && unitsWith4Precision.indexOf(unit) >= 0) {
			fixedNumber = scaledValue.toPrecision(4)
		} else {
			let decimals
			if (Math.abs(value) > 100 && Math.abs(value) <= 9999 && (unit === VenusOS.Units_Amp || unit === VenusOS.Units_Volt_DC)) {
				// Use 0 decimals when over 100 A or 100 V (DC).
				decimals = 0
			} else {
				decimals = Units.defaultUnitDecimals(unit)
			}
			fixedNumber = scaledValue.toFixed(decimals)
		}

		if (parseInt(fixedNumber) === parseFloat(fixedNumber)) {
			const fixedWithoutDecimals = scaledValue.toFixed(0)
			if ((scaledValue < 0 && fixedWithoutDecimals.length === 5) // disregard minus symbol if present
				   || (scaledValue > 0 && fixedWithoutDecimals.length === 4)) {
				// Use zero decimals if that would give us the same value with 4 digits.
				fixedNumber = fixedWithoutDecimals
			}
		}

		if (fixedNumber === "-0") {
			fixedNumber = "0"
		}

		return {
			number: fixedNumber,
			unit: Units.scaleToString(scale) + baseUnitSymbol,
			scale: scale
		}
	}

	function test_getDisplayText_data() {
		function dataRow(unit, value, scale, fixedNumbers) {
			const symbol = Units.defaultUnitString(unit)
			if (unit !== VenusOS.Units_None && unit !== VenusOS.Units_PowerFactor) {
				console.assert(symbol, "no symbol for unit: %1".arg(unit))
			}

			// Create a unique unit tag in order to avoid duplicate data tags.
			let unitTag = symbol
			switch (unit) {
				// If the symbol is empty, set a hardcoded string id.
				case VenusOS.Units_None: unitTag = "(Units_None)"; break;
				case VenusOS.Units_PowerFactor: unitTag = "(PF)"; break;
				// Distinguish between AC vs DC volts.
				case VenusOS.Units_Volt_AC: unitTag += " (AC)"; break;
				case VenusOS.Units_Volt_DC: unitTag += " (DC)"; break;
				// Distinguish between imperial vs US gallons.
				case VenusOS.Units_Volume_GallonImperial: unitTag += " (Imp)"; break;
				case VenusOS.Units_Volume_GallonUS: unitTag += " (US)"; break;
				default: break;
			}
			let expectedSymbol = Units.scaleToString(scale) + symbol
			const adjusted = expectedAdjustedQuantity(unit, value, fixedNumbers, scale)
			const tag = "%1 %2 -> nonAdjusted=%3%4, adjusted=%5%6"
					.arg(value.toString()).arg(unitTag)
					.arg(fixedNumbers[Units.defaultUnitDecimals(unit)]).arg(expectedSymbol)
					.arg(adjusted.number).arg(adjusted.unit)
			return {
				tag: tag,
				unit: unit,
				value: value,
				nonAdjusted: {
					fixedNumbers: fixedNumbers,
					symbol: expectedSymbol,
					scale: scale,
				},
				adjusted: adjusted
			}
		}

		// Returns an array of the value with [0,1,2,3] decimals.
		function fixedNumbersForValue(v) {
			return [ v.toFixed(0), v.toFixed(1), v.toFixed(2), v.toFixed(3) ]
		}

		const unscaledTestValues = [ 0, 0.1234, 0.8888, 0.9999, 1, 12, 88.8888, 99.9999, 123, 123.4567, 888.8888, 999.9999, 1234, 1234.5678, 8888.8888 ]
		const scaledTestValues = [  9999.9999, 12345.6789, 88888.8888, 99999.9999, 123456.7899, 888888.8888, 999999.9999 ]

		// Expected results for unscaled values.
		const expectedUnscaled = unscaledTestValues.map(v => ({ value: v, fixedNumbers: fixedNumbersForValue(v) }))

		// Expected results for (unscaled) negative values, excluding the first (zero) entry in unscaledTestValues.
		let expectedNegativeUnscaled = unscaledTestValues.slice(1).map(v => ({ value: v * -1, fixedNumbers: fixedNumbersForValue(v * -1) }))
		expectedNegativeUnscaled[0].fixedNumbers = ["0", "-0.1", "-0.12", "-0.123"] // fix the first number so that it is not "-0"

		// Expected results for values that are expected to scale to the kilo range.
		// E.g. for value 12345.6789, the test row is { value: 12345.6789, fixedNumbers: [ "12", "12.3", "12.35, "12.346" ] }
		const expectedKilo = scaledTestValues.map(v => ({ value: v, fixedNumbers: fixedNumbersForValue(v / 1000) }))
		const expectedNegativeKilo = scaledTestValues.map(v => ({ value: v * -1, fixedNumbers: fixedNumbersForValue(v / 1000 * -1) }))

		// Expected results for values that are expected to scale to the mega range.
		// E.g. for value 12345.6789, the test row is { value: 12345678.9, fixedNumbers: [ "12", "12.3", "12.35, "12.346" ] }
		const expectedMega = scaledTestValues.map(v => ({ value: v * 1000, fixedNumbers: fixedNumbersForValue(v / 1000) }))

		// Expected results for values that are expected to scale to the giga range.
		// E.g. for value 12345.6789, the test row is { value: 12345678900, fixedNumbers: [ "12", "12.3", "12.35, "12.346" ] }
		const expectedGiga = scaledTestValues.map(v => ({ value: v * 1000 * 1000, fixedNumbers: fixedNumbersForValue(v / 1000) }))

		// Expected results for values that are expected to scale to the tera range.
		// E.g. for value 12345.6789, the test row is { value: 12345678900000, fixedNumbers: [ "12", "12.3", "12.35, "12.346" ] }
		const expectedTera = scaledTestValues.map(v => ({ value: v * 1000 * 1000 * 1000, fixedNumbers: fixedNumbersForValue(v / 1000) }))


		let data = []

		// For each unit, add a data row for each scale test value, with an array containing the
		// expected quantity text for [0,1,2,3] decimals.
		function addDataRows(unit) {
			data.push(dataRow(unit, NaN, VenusOS.Units_Scale_None, ["--","--","--","--"]))

			let expectedInfo
			for (expectedInfo of expectedUnscaled) {
				data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_None, expectedInfo.fixedNumbers))
			}
			for (expectedInfo of expectedNegativeUnscaled) {
				data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_None, expectedInfo.fixedNumbers))
			}
			if (Units.maximumUnitScale(unit) >= VenusOS.Units_Scale_Kilo) {
				for (expectedInfo of expectedKilo) {
					data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_Kilo, expectedInfo.fixedNumbers))
				}
				for (expectedInfo of expectedNegativeKilo) {
					data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_Kilo, expectedInfo.fixedNumbers))
				}
			}
			if (Units.maximumUnitScale(unit) >= VenusOS.Units_Scale_Mega) {
				for (expectedInfo of expectedMega) {
					data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_Mega, expectedInfo.fixedNumbers))
				}
			}
			if (Units.maximumUnitScale(unit) >= VenusOS.Units_Scale_Giga) {
				for (expectedInfo of expectedGiga) {
					data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_Giga, expectedInfo.fixedNumbers))
				}
			}
			if (Units.maximumUnitScale(unit) >= VenusOS.Units_Scale_Tera) {
				for (expectedInfo of expectedTera) {
					data.push(dataRow(unit, expectedInfo.value, VenusOS.Units_Scale_Tera, expectedInfo.fixedNumbers))
				}
			}
		}

		const exceptions = [
			VenusOS.Units_CardinalDirection, // see test_windDirection()
			VenusOS.Units_Energy_KiloWattHour, // see test_kiloWattHour()
			VenusOS.Units_Percentage, // see test_percentage()
			VenusOS.Units_Time_Day, // see test_timeUnits()
			VenusOS.Units_Time_Hour, // as above
			VenusOS.Units_Time_Minute, // as above
			VenusOS.Units_Time_Second, // as above
		]

		for (let i = 0; i <= VenusOS.Units_Type_Max; ++i) {
			if (exceptions.indexOf(i) < 0) {
				addDataRows(i)
			}
		}
		return data
	}

	function test_getDisplayText(data) {
		const baseUnitSymbol = Units.defaultUnitString(data.unit)
		let decimals
		let quantity

		// For Watts, any number between -1 to 1 (exclusive) becomes zero, to ignore potential noise.
		const overrideExpectedNumber = data.unit === VenusOS.Units_Watt && Math.abs(data.value) < 1 ? "0" : undefined

		// When decimals = -1 and formatHints = NoDecimalAdjustment, the result should contain a
		// fixed number with the default number of decimals for that unit. The resulting number
		// should also be scaled if needed (e.g. 123456W becomes 12.34kW).
		quantity = Units.getDisplayText(data.unit, data.value, -1, Units.NoDecimalAdjustment)
		compare(quantity.number, overrideExpectedNumber ?? data.nonAdjusted.fixedNumbers[Units.defaultUnitDecimals(data.unit)])
		compare(quantity.unit, Units.scaleToString(data.nonAdjusted.scale) + baseUnitSymbol)
		compare(quantity.scale, data.nonAdjusted.scale)

		// When custom decimals are specified, the result should match the fixedNumbers entry
		// for that amount of decimals.
		for (decimals = 0; decimals <= 3; ++decimals) {
			quantity = Units.getDisplayText(data.unit, data.value, decimals, Units.NoDecimalAdjustment)
			compare(quantity.number, overrideExpectedNumber ?? data.nonAdjusted.fixedNumbers[decimals])
			compare(quantity.unit, Units.scaleToString(data.nonAdjusted.scale) + baseUnitSymbol, decimals)
			compare(quantity.scale, data.nonAdjusted.scale, decimals)
		}

		// When the NoScaling flag is specified, the resulting number should be the same as the
		// source value, with the preferred decimals.
		// Only test numbers for the base and kilo scales, to avoid going over MAX_INT.
		if (data.nonAdjusted.scale === VenusOS.Units_Scale_None || data.nonAdjusted.scale === VenusOS.Units_Scale_Kilo) {
			for (decimals = 0; decimals <= 3; ++decimals) {
				quantity = Units.getDisplayText(data.unit, data.value, decimals, Units.NoDecimalAdjustment | Units.NoScaling)
				let unscaledNumber = isNaN(data.value) ? "--" : data.value.toFixed(decimals)
				if (unscaledNumber === "-0") {
					unscaledNumber = "0"
				}
				compare(quantity.number, overrideExpectedNumber ?? unscaledNumber) // expect an unscaled value
				compare(quantity.unit, baseUnitSymbol) // expect the unit symbol without any scaling
				compare(quantity.scale, VenusOS.Units_Scale_None) // expect no scaling has been applied
			}
		}

		// When the default decimals, scaling and decimal adjustments are used, the resulting
		// number should be scaled and formatted as needed.
		quantity = Units.getDisplayText(data.unit, data.value)
		compare(quantity.number, overrideExpectedNumber ?? data.adjusted.number)
		compare(quantity.unit, data.adjusted.unit)
		compare(quantity.scale, data.adjusted.scale)
	}

	function test_timeUnits_data() {
		return [
			{ unit: VenusOS.Units_Time_Day, symbol: "d" },
			{ unit: VenusOS.Units_Time_Hour, symbol: "h" },
			{ unit: VenusOS.Units_Time_Minute, symbol: "m" },
			{ unit: VenusOS.Units_Time_Second, symbol: "s" },
		]
	}

	function test_timeUnits(data) {
		compare(Units.defaultUnitString(data.unit), data.symbol)
		compare(Units.defaultUnitDecimals(data.unit), 0)
		compare(Units.maximumUnitScale(data.unit), VenusOS.Units_Scale_None)

		// There are currently no min/max constraints on time units, so getDisplayText() should just
		// return the given number with the appropriate symbol.
		let quantity
		quantity = Units.getDisplayText(data.unit, NaN)
		compare(quantity.unit, data.symbol)
		compare(quantity.number, "--")
		quantity = Units.getDisplayText(data.unit, 0)
		compare(quantity.unit, data.symbol)
		compare(quantity.number, "0")
		quantity = Units.getDisplayText(data.unit, 1)
		compare(quantity.unit, data.symbol)
		compare(quantity.number, "1")
		quantity = Units.getDisplayText(data.unit, 100)
		compare(quantity.unit, data.symbol)
		compare(quantity.number, "100")
	}

	function expect(type, value, number, unit, hysteresis = false) {
		var numberOut = ""
		var unitOut = ""
		if (hysteresis) {
			info.unitType = type
			info.value = value
			numberOut = info.number
			unitOut = info.unit
		} else {
			const quantity = Units.getDisplayText(type, value)
			numberOut = quantity.number
			unitOut = quantity.unit
		}

		console.log("Testing value", value, "(" + Units.defaultUnitString(type) +") ->", numberOut + unitOut)
		compare(numberOut, number)
		compare(unitOut, unit)
	}

	function test_percentage() {
		expect(VenusOS.Units_Percentage, NaN, "--", "%")
		expect(VenusOS.Units_Percentage, 0, "0", "%")
		expect(VenusOS.Units_Percentage, 0.4, "0", "%")
		expect(VenusOS.Units_Percentage, 0.55, "1", "%")
		expect(VenusOS.Units_Percentage, 14, "14", "%")
		expect(VenusOS.Units_Percentage, 15.5, "16", "%")
		expect(VenusOS.Units_Percentage, 99.3, "99", "%")
		expect(VenusOS.Units_Percentage, 99.7, "99", "%")
		expect(VenusOS.Units_Percentage, 99.9, "100", "%")
		expect(VenusOS.Units_Percentage, 100, "100", "%")
	}

	function test_windDirection() {
		expect(VenusOS.Units_CardinalDirection, NaN, "--", "°")
		expect(VenusOS.Units_CardinalDirection, 0, "0", "° direction_north")
		expect(VenusOS.Units_CardinalDirection, 45, "45", "° direction_northeast")
		expect(VenusOS.Units_CardinalDirection, 90, "90", "° direction_east")
		expect(VenusOS.Units_CardinalDirection, 135, "135", "° direction_southeast")
		expect(VenusOS.Units_CardinalDirection, 180, "180", "° direction_south")
		expect(VenusOS.Units_CardinalDirection, 215, "215", "° direction_southwest")
		expect(VenusOS.Units_CardinalDirection, 270, "270", "° direction_west")
		expect(VenusOS.Units_CardinalDirection, 315, "315", "° direction_northwest")
		expect(VenusOS.Units_CardinalDirection, 360, "0", "° direction_north")
		expect(VenusOS.Units_CardinalDirection, -23, "337", "° direction_northwest")
		expect(VenusOS.Units_CardinalDirection, 400, "40", "° direction_northeast")
		expect(VenusOS.Units_CardinalDirection, 23.6, "24", "° direction_northeast")
	}

	function test_kiloWattHour() {
		const unit = VenusOS.Units_Energy_KiloWattHour

		expect(unit, NaN, "--", "kWh")
		expect(unit, 0, "0", "kWh")
		expect(unit, 0.0005, "1", "Wh") // precision of three for kWh means precision of zero for Wh.
		expect(unit, 0.005, "5", "Wh")
		expect(unit, 0.3458, "346", "Wh")
		expect(unit, 0.5, "500", "Wh")
		expect(unit, 5, "5000", "Wh")
		expect(unit, 10.554, "10.55", "kWh")
		expect(unit, 10.555, "10.56", "kWh")
		expect(unit, 14.123, "14.12", "kWh")
		expect(unit, 15.51, "15.51", "kWh")
		expect(unit, 100.3134, "100.3", "kWh")
		expect(unit, 1234.5951, "1.235", "MWh")
		expect(unit, 12345, "12.35", "MWh")
		expect(unit, 123456789, "123.5", "GWh")
		expect(unit, 123456789012, "123.5", "TWh")
	}

	function test_hysteresis() {
		const unit = VenusOS.Units_Energy_KiloWattHour

		// Scaling up works like without hysteresis
		expect(unit, 1.234, "1234", "Wh", true) // hysteresis = true
		expect(unit, 100.3134, "100.3", "kWh", true) // hysteresis = true
		expect(unit, 1234.5951, "1.235", "MWh", true) // hysteresis = true
		expect(unit, 12345, "12.35", "MWh", true) // hysteresis = true
		expect(unit, 123456789, "123.5", "GWh", true) // hysteresis = true
		expect(unit, 123456789012, "123.5", "TWh", true) // hysteresis = true

		// Keep the scale when going 10% below the threshold
		expect(unit, 956789012, "0.957", "TWh", true) // hysteresis = true
		expect(unit, 896789012, "896.8", "GWh", true) // hysteresis = true
		expect(unit, 956789012, "956.8", "GWh", true) // hysteresis = true

		// Keep the scale when going 10% below the threshold
		expect(unit, 956789, "0.957", "GWh", true) // hysteresis = true
		expect(unit, 896789, "896.8", "MWh", true) // hysteresis = true
		expect(unit, 956789, "956.8", "MWh", true) // hysteresis = true

		// Keep the scale when going 10% below the threshold
		expect(unit, 956.7, "0.957", "MWh", true) // hysteresis = true
		expect(unit, 896.7, "896.7", "kWh", true) // hysteresis = true
		expect(unit, 956.7, "956.7", "kWh", true) // hysteresis = true

		// Keep the scale when going 10% below the threshold
		expect(unit, 9.5675, "9.568", "kWh", true) // hysteresis = true
		expect(unit, 8.967, "8967", "Wh", true) // hysteresis = true
	}

	function test_unitMatchValue() {
		const unit = VenusOS.Units_Energy_KiloWattHour
		var quantity = Units.getDisplayText(unit, 19567890123)
		compare(quantity.number, "19.57")
		compare(quantity.unit, "TWh")

		// choose scale based on different anchor value
		quantity = Units.getDisplayText(unit, 19567890123, 0, Units.NoFormatHints, 123456789)
		compare(quantity.number, "19568")
		compare(quantity.unit, "GWh")
	}

	function test_unitFormatHints() {
		const unit = VenusOS.Units_Metre
		let quantity

		quantity = Units.getDisplayText(unit, 19.5678)
		compare(quantity.number, "20")
		compare(quantity.unit, "m")

		// default internal scaling algorithm ignores passed function parameters
		// and uses four digits where possible
		quantity = Units.getDisplayText(unit, 19.5678, 2)
		compare(quantity.number, "19.57")
		compare(quantity.unit, "m")

		// force internal scaling algorithm to adhere to function parameters
		quantity = Units.getDisplayText(unit, 19.5678, 4, Units.NoDecimalAdjustment)
		compare(quantity.number, "19.5678")
		compare(quantity.unit, "m")

		// scaled value correctly rounded to default decimal places
		quantity = Units.getDisplayText(unit, 195678)
		compare(quantity.number, "196")
		compare(quantity.unit, "km")

		// scaled value correctly round to overridded decimal places
		quantity = Units.getDisplayText(unit, 195678, 2, Units.NoDecimalAdjustment)
		compare(quantity.number, "195.68")
		compare(quantity.unit, "km")

		// unscaled value correctly round to two decimal places
		quantity = Units.getDisplayText(unit, 195678, 2, Units.NoScaling)
		compare(quantity.number, "195678.00")
		compare(quantity.unit, "m")

		// unscaled value correctly round to two decimal places
		quantity = Units.getDisplayText(unit, 195678.5, 2, Units.NoScaling)
		compare(quantity.number, "195678.50")
		compare(quantity.unit, "m")
	}

	function test_coordinate_data() {
		// Note: directions are not translated in the tests, so the qtTrId translation ids are used
		// directly here.
		return [
			{
				latitude: {
					input: 52.372778,
					dms: "52° 22' 22.0\" cardinalDirection_short_north",
					dm: "52° 22.3667 cardinalDirection_short_north",
					dd: "52.372778",
				},
				longitude: {
					input: 4.893611,
					dms: "4° 53' 37.0\" cardinalDirection_short_east",
					dm: "4° 53.6167 cardinalDirection_short_east",
					dd: "4.893611",
				},
			},
			{
				latitude: {
					input: -27.911111,
					dms: "27° 54' 40.0\" cardinalDirection_short_south",
					dm: "27° 54.6667 cardinalDirection_short_south",
					dd: "-27.911111",
				},
				longitude: {
					input: -43.205556,
					dms: "43° 12' 20.0\" cardinalDirection_short_west",
					dm: "43° 12.3334 cardinalDirection_short_west",
					dd: "-43.205556",
				},
			},
		]
	}

	function test_coordinate(data) {
		// Degrees, minutes, seconds
		compare(Units.formatLatitude(data.latitude.input, VenusOS.GpsData_Format_DegreesMinutesSeconds), data.latitude.dms)
		compare(Units.formatLongitude(data.longitude.input, VenusOS.GpsData_Format_DegreesMinutesSeconds), data.longitude.dms)

		// Decimal degrees
		compare(Units.formatLatitude(data.latitude.input, VenusOS.GpsData_Format_DecimalDegrees), data.latitude.dd)
		compare(Units.formatLongitude(data.longitude.input, VenusOS.GpsData_Format_DecimalDegrees), data.longitude.dd)

		// Degrees, decimal minutes
		compare(Units.formatLatitude(data.latitude.input, VenusOS.GpsData_Format_DegreesMinutes), data.latitude.dm)
		compare(Units.formatLongitude(data.longitude.input, VenusOS.GpsData_Format_DegreesMinutes), data.longitude.dm)
	}

	QuantityInfo {
		id: info
	}
}
