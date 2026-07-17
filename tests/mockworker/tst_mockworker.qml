/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "MockWorkerTest"
	when: windowShown

	function cleanup() {
		MockManager.timersActive = false
	}

	property var lastValue

	function waitForValue(path, expected) {
		tryVerify(function() {
			lastValue = MockManager.value(path)
			return lastValue === expected
		}, 5000, path + " expected " + expected + " got " + lastValue)
	}

	function isInvalid(value) {
		return value === undefined || value === null || (typeof value === "number" && isNaN(value))
	}

	Component {
		id: consumptionComponent
		MockConsumptionCalculator {}
	}

	Component {
		id: phaseSumComponent
		MockPhaseSumCalculator {}
	}

	Component {
		id: stepperComponent
		MockDataStepper {
			stepSize: 1
			interval: 30
			property string valueUid
			VeQuickItem { uid: valueUid }
		}
	}

	// 3120-1/2: timers off, canonical (no mock/) source uids, per-input gauge maxima.
	function test_consumption_without_timers() {
		compare(MockManager.timersActive, false)

		const system = "mock/com.victronenergy.system.mockworker.consumption"
		const gauges = "mock/com.victronenergy.settings.mockworker/Settings/Gui/Gauges"
		const inverter0 = "com.victronenergy.inverter.mockworker0"
		const inverter1 = "mock/com.victronenergy.inverter.mockworker1"

		MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter0 + "/Ac/Out/L1/P", 40)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/I", 9)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/P", 90)
		MockManager.setValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 1)

		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		calc.addService("mock/" + inverter0, "inverter", 0)
		calc.addService(inverter1, "inverter", 1)

		waitForValue(system + "/Ac/Consumption/L1/Current", 13)
		waitForValue(system + "/Ac/Consumption/L1/Power", 130)
		waitForValue(system + "/Ac/Consumption/NumberOfPhases", 1)
		// Running sum is bucketed by the service just added: index 0 sees 4, index 1 sees 4+9.
		waitForValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 4)
		waitForValue(gauges + "/Ac/AcIn2/Consumption/Current/Max", 13)

		MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 6)
		waitForValue(system + "/Ac/Consumption/L1/Current", 15)
		waitForValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 6)
		waitForValue(gauges + "/Ac/AcIn2/Consumption/Current/Max", 15)

		calc.destroy()
	}

	// 3120-2/4: a valid phase count skips later phases; clearing the data leaves the count invalid.
	function test_phase_count_limit() {
		const system = "mock/com.victronenergy.system.mockworker.phases"
		const vebus = "mock/com.victronenergy.vebus.mockworker"
		MockManager.setValue(vebus + "/Ac/NumberOfPhases", 1)
		MockManager.setValue(vebus + "/Ac/ActiveIn/L1/I", 5)
		MockManager.setValue(vebus + "/Ac/ActiveIn/L1/P", 50)
		MockManager.setValue(vebus + "/Ac/ActiveIn/L2/I", 7)
		MockManager.setValue(vebus + "/Ac/ActiveIn/L2/P", 70)
		MockManager.setValue(vebus + "/Ac/Out/L1/I", 1)
		MockManager.setValue(vebus + "/Ac/Out/L1/P", 10)
		MockManager.setValue(vebus + "/Ac/Out/L2/I", 2)
		MockManager.setValue(vebus + "/Ac/Out/L2/P", 20)

		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		calc.addService(vebus, "vebus", 0)

		// Combined consumption current equals the included phase's AC-in current.
		waitForValue(system + "/Ac/Consumption/L1/Current", 5)
		waitForValue(system + "/Ac/Consumption/NumberOfPhases", 1)
		tryVerify(function() { return isInvalid(MockManager.value(system + "/Ac/Consumption/L2/Current")) })

		MockManager.setValue(vebus + "/Ac/ActiveIn/L1/P", null)
		MockManager.setValue(vebus + "/Ac/ActiveIn/L1/I", null)
		MockManager.setValue(vebus + "/Ac/Out/L1/P", null)
		MockManager.setValue(vebus + "/Ac/Out/L1/I", null)
		tryVerify(function() { return isInvalid(MockManager.value(system + "/Ac/Consumption/NumberOfPhases")) })

		calc.destroy()
	}

	function test_phase_sum_without_timers() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker"
		const target = "mock/com.victronenergy.system.mockworker/Ac/PvOnOutput"
		MockManager.setValue(pv + "/Ac/L1/Power", 100)
		MockManager.setValue(pv + "/Ac/L1/Current", 4)
		MockManager.setValue(pv + "/Ac/L2/Power", 50)

		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power",
			sourceCurrentPattern: "/Ac/L%1/Current"
		})
		verify(calc)
		calc.addService("mock/" + pv)

		waitForValue(target + "/L1/Power", 100)
		waitForValue(target + "/L1/Current", 4)
		waitForValue(target + "/L2/Power", 50)
		waitForValue(target + "/NumberOfPhases", 2)

		MockManager.setValue(pv + "/Ac/L1/Power", 80)
		waitForValue(target + "/L1/Power", 80)

		calc.destroy()
	}

	// 3120-3: an external write must replace the cached animator input before the next tick.
	function test_stepper_follows_external_write() {
		const uid = "mock/com.victronenergy.test.mockworker/Value"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = true

		const stepper = stepperComponent.createObject(root, { valueUid: uid, active: false })
		verify(stepper)
		stepper.active = true
		tryVerify(function() { return MockManager.value(uid) >= 11 })

		MockManager.setValue(uid, 80)
		tryVerify(function() { return MockManager.value(uid) >= 81 })

		stepper.active = false
		MockManager.setValue(uid, 40)
		stepper.active = true
		tryVerify(function() { return MockManager.value(uid) >= 41 && MockManager.value(uid) < 70 })

		// Global timer toggle must also restart from the producer, not the last tick.
		stepper.active = false
		MockManager.timersActive = false
		wait(100)
		MockManager.setValue(uid, 20)
		compare(MockManager.value(uid), 20)
		MockManager.timersActive = true
		stepper.active = true
		tryVerify(function() { return MockManager.value(uid) >= 21 && MockManager.value(uid) < 40 })

		stepper.destroy()
	}
}
