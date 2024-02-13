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
		expect(VenusOS.Units_Percentage, 0.5, "1", "%")
		expect(VenusOS.Units_Percentage, 14, "14", "%")
		expect(VenusOS.Units_Percentage, 15.5, "16", "%")
		expect(VenusOS.Units_Percentage, 99.3, "99.3", "%")
		expect(VenusOS.Units_Percentage, 99.7, "99.7", "%")
		expect(VenusOS.Units_Percentage, 100, "100", "%")
	}

	function test_precisionZero() {
		var units = [VenusOS.Units_Volume_Liter,
					 VenusOS.Units_Volume_GallonImperial,
					 VenusOS.Units_Volume_GallonUS,
					 VenusOS.Units_Watt,
					 VenusOS.Units_WattsPerSquareMeter,
					 VenusOS.Units_Temperature_Celsius,
					 VenusOS.Units_Temperature_Fahrenheit,
					 VenusOS.Units_Temperature_Kelvin,
					 VenusOS.Units_RevolutionsPerMinute]

		for (const unit of units) {
			const unitString = Units.defaultUnitString(unit)

			expect(unit, NaN, "--", unitString)
			expect(unit, 0, "0", unitString)
			expect(unit, 0.4, "0", unitString)
			expect(unit, 0.5, "1", unitString)
			expect(unit, 14, "14", unitString)
			expect(unit, 15.5, "16", unitString)
			expect(unit, 100, "100", unitString)
			expect(unit, 1234, "1234", unitString)

			if (Units.isScalingSupported(unit)) {
				if (unit === VenusOS.Units_Volume_Liter) {
					expect(unit, 12345, "12", "㎘")
					expect(unit, 123456789, "123457", "㎘")
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
		var units = [VenusOS.Units_Volt,
					 VenusOS.Units_VoltAmpere,
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
			expect(unit, 100, "100.0", unitString)
			expect(unit, 1234, "1234.0", unitString)

			if (Units.isScalingSupported(unit)) {
				expect(unit, 12345, "12.3", "k" + unitString)
				expect(unit, 123456789, "123.5", "M" + unitString)
				expect(unit, 123456789012, "123.5", "G" + unitString)
				expect(unit, 123456789012345, "123.5", "T" + unitString)
			} else {
				expect(unit, 12345, "12345.0", unitString)
				expect(unit, 123456789, "123456789.0", unitString)
			}
		}
	}

	function test_kiloWattHour() {
		const unit = VenusOS.Units_Energy_KiloWattHour

		expect(unit, NaN, "--", "kWh")
		expect(unit, 0, "0.00", "kWh")
		expect(unit, 0.005, "0.01", "kWh")
		expect(unit, 0.05, "0.05", "kWh")
		expect(unit, 0.554, "0.55", "kWh")
		expect(unit, 0.555, "0.56", "kWh")
		expect(unit, 14.123, "14.12", "kWh")
		expect(unit, 15.51, "15.51", "kWh")
		expect(unit, 100.3134, "100.31", "kWh")
		expect(unit, 1234.5951, "1234.60", "kWh")
		expect(unit, 12345, "12.35", "MWh")
		expect(unit, 123456789, "123.46", "GWh")
		expect(unit, 123456789012, "123.46", "TWh")
	}

	function test_volumeCubicMeter() {
		const unit = VenusOS.Units_Volume_CubicMeter

		expect(unit, NaN, "--", "m³")
		expect(unit, 0, "0.000", "m³")
		expect(unit, 0.0005, "0.001", "m³")
		expect(unit, 0.005, "0.005", "m³")
		expect(unit, 0.554, "0.554", "m³")
		expect(unit, 0.5555, "0.556", "m³")
		expect(unit, 14.1234, "14.123", "m³")
		expect(unit, 15.5123, "15.512", "m³")
		expect(unit, 100.3134, "100.313", "m³")
		expect(unit, 1234.59551, "1234.596", "m³")
		expect(unit, 12345.5, "12.346", "km³")
		expect(unit, 123456789, "123.457", "Mm³")
		expect(unit, 123456789012, "123.457", "Gm³")
		expect(unit, 123456789012345, "123.457", "Tm³")
	}

	function test_hysteresis() {
		const unit = VenusOS.Units_Energy_KiloWattHour

		// Scaling up works like without hysteresis
		expect(unit, 100.3134, "100.31", "kWh", true /* hysteresis */)
		expect(unit, 1234.5951, "1234.60", "kWh", true /* hysteresis */)
		expect(unit, 12345, "12.35", "MWh", true /* hysteresis */)
		expect(unit, 123456789, "123.46", "GWh", true /* hysteresis */)
		expect(unit, 123456789012, "123.46", "TWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567890123, "9.57", "TWh", true /* hysteresis */)
		expect(unit, 8967890123, "8967.89", "GWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567890, "9.57", "GWh", true /* hysteresis */)
		expect(unit, 8967890, "8967.89", "MWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567, "9.57", "MWh", true /* hysteresis */)
		expect(unit, 8967, "8967.00", "kWh", true /* hysteresis */)
	}
}
