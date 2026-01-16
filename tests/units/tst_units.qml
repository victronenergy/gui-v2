/*
 * Copyright (C) 2024 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import Victron.VenusOS

TestCase {
	name: "UnitsTest"

	QuantityInfo {
		id: info
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

	function test_powerFactor() {
		expect(VenusOS.Units_PowerFactor, NaN, "--", "")
		expect(VenusOS.Units_PowerFactor, -1234, "-1234", "")
		expect(VenusOS.Units_PowerFactor, -100, "-100.0", "")
		expect(VenusOS.Units_PowerFactor, -15.55, "-15.55", "")
		expect(VenusOS.Units_PowerFactor, -1, "-1.000", "")
		expect(VenusOS.Units_PowerFactor, -0.255, "-0.255", "")
		expect(VenusOS.Units_PowerFactor, -0.25, "-0.250", "")
		expect(VenusOS.Units_PowerFactor, -0.1, "-0.100", "")
		expect(VenusOS.Units_PowerFactor, 0, "0.000", "")
		expect(VenusOS.Units_PowerFactor, 0.1, "0.100", "")
		expect(VenusOS.Units_PowerFactor, 0.25, "0.250", "")
		expect(VenusOS.Units_PowerFactor, 0.255, "0.255", "")
		expect(VenusOS.Units_PowerFactor, 1, "1.000", "")
		expect(VenusOS.Units_PowerFactor, 15.55, "15.55", "")
		expect(VenusOS.Units_PowerFactor, 100, "100.0", "")
		expect(VenusOS.Units_PowerFactor, 1234, "1234", "")
	}

	function test_precisionZero() {
		var units = [VenusOS.Units_Volume_Litre,
					 VenusOS.Units_Volume_GallonImperial,
					 VenusOS.Units_Volume_GallonUS,
					 VenusOS.Units_Watt,
					 VenusOS.Units_WattsPerSquareMetre,
					 VenusOS.Units_Temperature_Celsius,
					 VenusOS.Units_Temperature_Fahrenheit,
					 VenusOS.Units_Temperature_Kelvin,
					 VenusOS.Units_Altitude_Metre,
					 VenusOS.Units_Altitude_Foot,
					 VenusOS.Units_RevolutionsPerMinute]

		for (const unit of units) {
			const unitString = Units.defaultUnitString(unit)

			expect(unit, NaN, "--", unitString)
			expect(unit, 0, "0", unitString)
			expect(unit, 0.4, "0", unitString)
			if (unit === VenusOS.Units_Watt) {
				expect(unit, 0.55, "0", unitString)
				expect(unit, 0.9, "0", unitString)
				expect(unit, 1.1, "1", unitString)
			} else {
				expect(unit, 0.55, "1", unitString)
			}
			expect(unit, 14, "14", unitString)
			expect(unit, 15.5, "16", unitString)
			expect(unit, 100, "100", unitString)
			expect(unit, 1234, "1234", unitString)

			if (Units.isScalingSupported(unit)) {
				if (unit === VenusOS.Units_Volume_Litre
						|| unit === VenusOS.Units_Altitude_Metre) {
					expect(unit, 12345, "12", "k" + unitString)
					expect(unit, 123456789, "123457", "k" + unitString)
				} else {
					expect(unit, 12345, "12", "k" + unitString)
					expect(unit, 123456789, "123", "M" + unitString)
					expect(unit, 123456789012, "123", "G" + unitString)
					expect(unit, 123456789012345, "123", "T" + unitString)
				}
			} else {
				expect(unit, 1234, "1234", unitString)
				expect(unit, 12345, "12345", unitString)
				expect(unit, 123456789, "123456789", unitString)
			}
		}
	}

	function test_precisionOne() {
		var units = [VenusOS.Units_VoltAmpere,
					 VenusOS.Units_Amp,
					 VenusOS.Units_Hertz,
					 VenusOS.Units_AmpHour,
					 VenusOS.Units_Hectopascal]

		for (const unit of units) {
			const unitString = Units.defaultUnitString(unit)

			expect(unit, NaN, "--", unitString)
			expect(unit, 0, "0.0", unitString)
			expect(unit, 0.4, "0.4", unitString)
			expect(unit, 0.54, "0.5", unitString)
			expect(unit, 0.55, "0.6", unitString)
			expect(unit, 14, "14.0", unitString)
			expect(unit, 15.5, "15.5", unitString)
			expect(unit, 100, "100", unitString)
			expect(unit, 1234, "1234", unitString)

			if (Units.isScalingSupported(unit)) {
				expect(unit, 12345, "12.3", "k" + unitString)
				expect(unit, 123456789, "123", "M" + unitString)
				expect(unit, 123556789012, "124", "G" + unitString)
				expect(unit, 123456789012345, "123", "T" + unitString)
			} else {
				expect(unit, 12345, "12345", unitString)
				expect(unit, 123456789, "123456789", unitString)
			}
		}
	}

	function test_precisionTwo() {
		var units = [
			VenusOS.Units_Volt_DC
		]

		for (const unit of units) {
			const unitString = Units.defaultUnitString(unit)

			expect(unit, NaN, "--", unitString)
			expect(unit, 0, "0.00", unitString)
			expect(unit, 0.64, "0.64", unitString)
			expect(unit, 0.254, "0.25", unitString)
			expect(unit, 0.255, "0.26", unitString)
			expect(unit, 14, "14.00", unitString)
			expect(unit, 15.55, "15.55", unitString)
			expect(unit, 100, "100", unitString)
			expect(unit, 1234, "1234", unitString)

			if (Units.isScalingSupported(unit)) {
				expect(unit, 12345, "12.35", "k" + unitString)
				expect(unit, 123456789, "123", "M" + unitString)
				expect(unit, 123556789012, "124", "G" + unitString)
				expect(unit, 123456789012345, "123", "T" + unitString)
			} else {
				expect(unit, 12345, "12345", unitString)
				expect(unit, 123456789, "123456789", unitString)
			}
		}
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

	function test_volumeCubicMetre() {
		const unit = VenusOS.Units_Volume_CubicMetre

		expect(unit, NaN, "--", "m³")
		expect(unit, 0, "0.000", "m³")
		expect(unit, 0.0005, "0.001", "m³")
		expect(unit, 0.005, "0.005", "m³")
		expect(unit, 0.554, "0.554", "m³")
		expect(unit, 0.5555, "0.556", "m³")
		expect(unit, 14.1234, "14.12", "m³")
		expect(unit, 15.5123, "15.51", "m³")
		expect(unit, 100.3134, "100.3", "m³")
		expect(unit, 1234.59551, "1235", "m³")
		expect(unit, 12345.5, "12.35", "km³")
		expect(unit, 123456789, "123.5", "Mm³")
		expect(unit, 123456789012, "123.5", "Gm³")
		expect(unit, 123456789012345, "123.5", "Tm³")
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
		quantity = Units.getDisplayText(unit, 19567890123, -1, true, 123456789)
		compare(quantity.number, "19568")
		compare(quantity.unit, "GWh")
	}

	function test_precision() {
		const unit = VenusOS.Units_Watt
		var quantity = Units.getDisplayText(unit, 1.9612345)
		compare(quantity.number, "2")

		quantity = Units.getDisplayText(unit, 1.9612345, 1)
		compare(quantity.number, "2.0")

		quantity = Units.getDisplayText(unit, 1.9612345, 2)
		compare(quantity.number, "1.96")

		quantity = Units.getDisplayText(unit, 1.9612345, 3)
		compare(quantity.number, "1.961")

		quantity = Units.getDisplayText(unit, 1.9612345, 4)
		compare(quantity.number, "1.9612")
	}

	function test_unitNone() {
		expect(VenusOS.Units_None, NaN, "--", "")
		expect(VenusOS.Units_None, 123, "123", "")
		expect(VenusOS.Units_None, 12345678, "12345678", "")
	}

	function test_partsPerMillion() {
		const unit = VenusOS.Units_PartsPerMillion
		const unitString = Units.defaultUnitString(unit)

		expect(unit, NaN, "--", unitString)
		expect(unit, 0, "0", unitString)
		expect(unit, 400, "400", unitString)
		expect(unit, 425, "425", unitString)
		expect(unit, 1000, "1000", unitString)
		expect(unit, 5000, "5000", unitString)
		expect(unit, 40000, "40000", unitString)
	}

	function test_microgramPerCubicMeter() {
		const unit = VenusOS.Units_MicrogramPerCubicMeter
		const unitString = Units.defaultUnitString(unit)

		expect(unit, NaN, "--", unitString)
		expect(unit, 0, "0.0", unitString)
		expect(unit, 0.4, "0.4", unitString)
		expect(unit, 0.54, "0.5", unitString)
		expect(unit, 0.55, "0.6", unitString)
		expect(unit, 2.2, "2.2", unitString)
		expect(unit, 10.5, "10.5", unitString)
		expect(unit, 100, "100", unitString)
		expect(unit, 250.7, "251", unitString)
		expect(unit, 999.9, "1000", unitString)
		expect(unit, 1000, "1000", unitString)
	}

	function test_lux() {
		const unit = VenusOS.Units_Lux
		const unitString = Units.defaultUnitString(unit)

		expect(unit, NaN, "--", unitString)
		expect(unit, 0, "0", unitString)
		expect(unit, 1, "1", unitString)
		expect(unit, 10, "10", unitString)
		expect(unit, 100, "100", unitString)
		expect(unit, 244, "244", unitString)
		expect(unit, 1000, "1000", unitString)
		expect(unit, 10472, "10472", unitString)
		expect(unit, 13026.67, "13027", unitString)
		expect(unit, 65535, "65535", unitString)
		expect(unit, 144284, "144284", unitString)
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
}
