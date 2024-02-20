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
		expect(VenusOS.Units_Percentage, 0.4, "0.4", "%")
		expect(VenusOS.Units_Percentage, 0.55, "0.6", "%")
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
			expect(unit, 0.4, "0.4", unitString)
			expect(unit, 0.55, "0.6", unitString)
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
			expect(unit, 100, "100", unitString)
			expect(unit, 1234, "1234", unitString)

			if (Units.isScalingSupported(unit)) {
				expect(unit, 12345, "12.3", "k" + unitString)
				expect(unit, 123456789, "124", "M" + unitString)
				expect(unit, 123456789012, "124", "G" + unitString)
				expect(unit, 123456789012345, "124", "T" + unitString)
			} else {
				expect(unit, 12345, "12345", unitString)
				expect(unit, 123456789, "123456789", unitString)
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
		expect(unit, 14.123, "14.1", "kWh")
		expect(unit, 15.51, "15.5", "kWh")
		expect(unit, 100.3134, "100", "kWh")
		expect(unit, 1234.5951, "1235", "kWh")
		expect(unit, 12345, "12.3", "MWh")
		expect(unit, 123456789, "123", "GWh")
		expect(unit, 123456789012, "123", "TWh")
	}

	function test_volumeCubicMeter() {
		const unit = VenusOS.Units_Volume_CubicMeter

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
		expect(unit, 100.3134, "100", "kWh", true /* hysteresis */)
		expect(unit, 1234.5951, "1235", "kWh", true /* hysteresis */)
		expect(unit, 12345, "12.3", "MWh", true /* hysteresis */)
		expect(unit, 123456789, "123", "GWh", true /* hysteresis */)
		expect(unit, 123456789012, "123", "TWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567890123, "9.57", "TWh", true /* hysteresis */)
		expect(unit, 8967890123, "8968", "GWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567890, "9.57", "GWh", true /* hysteresis */)
		expect(unit, 8967890, "8968", "MWh", true /* hysteresis */)

		// Keep the scale when going 10% below the threshold
		expect(unit, 9567, "9.57", "MWh", true /* hysteresis */)
		expect(unit, 8967, "8967", "kWh", true /* hysteresis */)
	}

	function test_unitMatchValue() {
		const unit = VenusOS.Units_Energy_KiloWattHour
		var quantity = Units.getDisplayText(unit, 19567890123)
		compare("19.6", quantity.number)
		compare("TWh", quantity.unit)

		// choose scale based on different anchor value
		var quantity = Units.getDisplayText(unit, 19567890123, -1, 123456789)
		compare("19568", quantity.number)
		compare("GWh", quantity.unit)
	}

	function test_precision() {
		const unit = VenusOS.Units_Watt
		var quantity = Units.getDisplayText(unit, 1.9612345)
		compare("2", quantity.number)

		quantity = Units.getDisplayText(unit, 1.9612345, 1)
		compare("2.0", quantity.number)

		quantity = Units.getDisplayText(unit, 1.9612345, 2)
		compare("1.96", quantity.number)

		quantity = Units.getDisplayText(unit, 1.9612345, 3)
		compare("1.961", quantity.number)

		quantity = Units.getDisplayText(unit, 1.9612345, 4)
		compare("1.9612", quantity.number)
	}
}
