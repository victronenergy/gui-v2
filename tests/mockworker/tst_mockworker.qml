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

	Component {
		id: movableStepperComponent
		MockDataStepper {
			stepSize: 1
			interval: 30
			property alias itemUid: input.uid
			VeQuickItem { id: input }
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

	// A phase with only current must still count. Power-only counting hides it.
	function test_phase_sum_countsCurrentOnlyPhase() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker.currentonly"
		const target = "mock/com.victronenergy.system.mockworker/Ac/PvCurrentOnly"
		MockManager.setValue(pv + "/Ac/L2/Current", 3)

		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power",
			sourceCurrentPattern: "/Ac/L%1/Current"
		})
		verify(calc)
		calc.addService("mock/" + pv)

		waitForValue(target + "/L2/Current", 3)
		waitForValue(target + "/NumberOfPhases", 2)
		tryVerify(function() { return isInvalid(MockManager.value(target + "/L2/Power")) })

		calc.destroy()
	}

	// A paced worker batch must not revert a newer external write.
	function test_externalWrite_supersedesQueuedUpdate() {
		const uid = "mock/com.victronenergy.test.mockworker/Supersede"
		const filler = "mock/com.victronenergy.test.mockworker/Supersede/Filler/"
		MockManager.setValue(uid, 1)

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: filler + i, value: 7 })
		}
		updates.push({ uid: uid, value: 3 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.setValue(uid, 99)
		// In-flight batch, already computed before the worker observes 99.
		MockManager.applyWorkerUpdatesForTest([{ uid: uid, value: 3 }])

		wait(80)
		compare(MockManager.value(uid), 99)
		compare(MockManager.value(filler + "0"), 7)
	}

	function test_animator_rejectsNonFiniteInterval() {
		const uid = "mock/com.victronenergy.test.mockworker/Interval/Inf"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = true
		const stepper = stepperComponent.createObject(root, { valueUid: uid, active: false })
		verify(stepper)
		stepper.interval = Infinity
		stepper.active = true
		wait(150)
		compare(MockManager.value(uid), 10)

		// Rejection must not stick. A later finite interval still starts.
		stepper.interval = 30
		tryVerify(function() { return MockManager.value(uid) >= 11 })
		stepper.destroy()
	}

	function test_animator_rejectsOutOfRangeInterval() {
		const uid = "mock/com.victronenergy.test.mockworker/Interval/Huge"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = true
		const stepper = stepperComponent.createObject(root, { valueUid: uid, active: false })
		verify(stepper)
		stepper.interval = 1e20
		stepper.active = true
		wait(150)
		compare(MockManager.value(uid), 10)
		stepper.destroy()
	}

	// A queued or in-flight batch must not call setValue() on a removed service.
	// setValue() uses itemGetOrCreate() and would recreate it.
	function test_removeValue_doesNotResurrectService() {
		const service = "mock/com.victronenergy.tank.mockworker_remove"
		const level = service + "/Level"
		const other = "mock/com.victronenergy.test.mockworker/Keep"
		MockManager.setValue(level, 1)

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: other + "/Filler/" + i, value: 7 })
		}
		updates.push({ uid: level, value: 9 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.removeValue(service)
		// Item is already unlinked. This batch must not recreate it.
		MockManager.applyWorkerUpdatesForTest([{ uid: level, value: 8 }])
		verify(isInvalid(MockManager.value(level)))

		wait(80)
		verify(isInvalid(MockManager.value(level)))
		compare(MockManager.value(other + "/Filler/0"), 7)

		// The block clears after forgetUidPrefix() acks. A later write applies.
		tryVerify(function() {
			MockManager.applyWorkerUpdatesForTest([{ uid: level, value: 4 }])
			return MockManager.value(level) === 4
		})
		MockManager.removeValue(service)
	}

	function test_removeServices_doesNotResurrectService() {
		const level = "mock/com.victronenergy.tank.mockworker_svc_a/Level"
		const other = "mock/com.victronenergy.temperature.mockworker_svc/Temperature"
		MockManager.setValue(level, 1)
		MockManager.setValue(other, 2)

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: "mock/com.victronenergy.test.mockworker/SvcFiller/" + i, value: 1 })
		}
		updates.push({ uid: level, value: 9 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.removeServices("tank")
		MockManager.applyWorkerUpdatesForTest([{ uid: level, value: 8 }])
		verify(isInvalid(MockManager.value(level)))
		compare(MockManager.value(other), 2)
	}

	// forgetUidPrefix() must stop the animator before uidPrefixForgotten().
	// The ack clears the block within a few milliseconds; a 30ms writer that
	// is still running will recreate the service during this wait.
	// No VeQuickItem: a QML item still bound to Level warns when the item is deleted.
	function test_removeValue_stopsAnimatorBeforeResurrection() {
		const service = "mock/com.victronenergy.tank.mockworker_live"
		const level = service + "/Level"
		MockManager.setValue(level, 10)
		MockManager.timersActive = true
		MockManager.registerStepperForTest(level, 30)
		tryVerify(function() { return MockManager.value(level) !== 10 })

		MockManager.removeValue(service)
		wait(250)
		verify(isInvalid(MockManager.value(level)))
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

	function test_stepper_reregistersWhenUidChanges() {
		const first = "mock/com.victronenergy.test.mockworker/Uid/First"
		const second = "mock/com.victronenergy.test.mockworker/Uid/Second"
		MockManager.setValue(first, 10)
		MockManager.setValue(second, 10)
		MockManager.timersActive = true

		const stepper = movableStepperComponent.createObject(root, { itemUid: first, active: true })
		verify(stepper)
		tryVerify(function() { return MockManager.value(first) >= 12 })

		const frozen = MockManager.value(first)
		stepper.itemUid = second
		tryVerify(function() { return MockManager.value(second) >= 12 })
		wait(150)
		verify(MockManager.value(first) <= frozen + 1)

		stepper.destroy()
	}

	Component {
		id: rangeComponent
		MockDataRangeAnimator {
			interval: 30
			property string valueUid
			VeQuickItem { uid: valueUid }
		}
	}

	Component {
		id: randomizerComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property string valueUid
			VeQuickItem { uid: valueUid }
		}
	}

	Component {
		id: signedRandomizerComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property var stepSource
			followSignOf: stepSource ? (stepSource.actualStepSizes[0] ?? NaN) : NaN
			property string valueUid
			VeQuickItem { uid: valueUid }
		}
	}

	Component {
		id: togglerComponent
		MockDataToggler {
			interval: 30
			repeat: false
			property string valueUid
			VeQuickItem { uid: valueUid }
		}
	}

	// Initial step direction must be published before the first bound hit.
	function test_rangeAnimator_reportsInitialStepSize() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/Initial"
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const divisor = uid + "/Divisor"
		MockManager.setValue(uid, 40)
		MockManager.setValue(divisor, 25)
		MockManager.timersActive = true

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 10,
			totalTargetUid: total,
			derivedTargetUids: [derived],
			derivedDivisorUids: [divisor]
		})
		verify(range)

		waitForValue(uid, 50)
		waitForValue(derived, 2)
		waitForValue(total, 50)
		tryVerify(function() { return range.actualStepSizes[0] === 10 })
		range.destroy()
	}

	function test_rangeAnimator_publishesStepSizeBeforeTick() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/Published"
		MockManager.timersActive = false

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: false,
			stepSize: 8
		})
		verify(range)
		compare(range.actualStepSizes.length, 1)
		compare(range.actualStepSizes[0], 8)
		range.destroy()
	}

	function test_rangeAnimator_forwardsActualStepSizes() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/ForwardStep"
		MockManager.setValue(uid, 50)
		MockManager.timersActive = true

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			interval: 200,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 10
		})
		verify(range)
		compare(range.actualStepSizes[0], 10)

		// After registration, so this must be forwarded rather than snapshotted.
		range.actualStepSizes = [-4]
		waitForValue(uid, 46)
		range.destroy()
	}

	function test_rangeAnimator_reversesAtUpperBound() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/Reverse"
		MockManager.setValue(uid, 100)
		MockManager.timersActive = true

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 5
		})
		verify(range)

		tryVerify(function() { return range.actualStepSizes[0] === -5 })
		waitForValue(uid, 95)
		range.destroy()
	}

	function test_rangeAnimator_invalidRangeDoesNotAdvance() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/Invalid"
		const witness = uid + "/Witness"
		MockManager.setValue(uid, 10)
		MockManager.setValue(witness, 0)
		MockManager.timersActive = true

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 10,
			maximumValue: 10,
			stepSize: 5
		})
		const stepper = stepperComponent.createObject(root, { valueUid: witness, active: true })
		verify(range)
		verify(stepper)

		tryVerify(function() { return MockManager.value(witness) >= 3 })
		compare(MockManager.value(uid), 10)
		range.destroy()
		stepper.destroy()
	}

	function test_randomizer_divideAndTotal() {
		const uid = "mock/com.victronenergy.test.mockworker/Random/Divide"
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const divisor = uid + "/Divisor"
		MockManager.setValue(uid, 100)
		MockManager.setValue(divisor, 25)
		MockManager.timersActive = true

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			totalTargetUid: total,
			derivedTargetUids: [derived],
			derivedDivisorUids: [divisor]
		})
		verify(randomizer)

		waitForValue(uid, 100)
		waitForValue(derived, 4)
		waitForValue(total, 100)
		randomizer.destroy()
	}

	function test_randomizer_invalidDivisorSkipsDerived_data() {
		return [
			{ tag: "zero", divisor: 0 },
			{ tag: "negative", divisor: -5 },
		]
	}

	function test_randomizer_invalidDivisorSkipsDerived(row) {
		const uid = "mock/com.victronenergy.test.mockworker/Random/BadDivisor/" + row.tag
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const divisor = uid + "/Divisor"
		MockManager.setValue(uid, 100)
		MockManager.setValue(derived, 55)
		MockManager.setValue(divisor, row.divisor)
		MockManager.timersActive = true

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			totalTargetUid: total,
			derivedTargetUids: [derived],
			derivedDivisorUids: [divisor]
		})
		verify(randomizer)

		waitForValue(total, 100)
		compare(MockManager.value(derived), 55)
		randomizer.destroy()
	}

	function test_randomizer_mismatchedDerivedListsDoNotWrite() {
		const uid = "mock/com.victronenergy.test.mockworker/Random/Mismatch"
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const divisor = uid + "/Divisor"
		MockManager.setValue(uid, 100)
		MockManager.setValue(derived, 55)
		MockManager.setValue(divisor, 2)
		MockManager.timersActive = true

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			totalTargetUid: total,
			derivedTargetUids: [derived, derived + "Extra"],
			derivedDivisorUids: [divisor]
		})
		verify(randomizer)

		waitForValue(total, 100)
		compare(MockManager.value(derived), 55)
		randomizer.destroy()
	}

	function test_randomizer_multiplyTotal() {
		const uid = "mock/com.victronenergy.test.mockworker/Random/Multiply"
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const multiplier = uid + "/Multiplier"
		MockManager.setValue(uid, 4)
		MockManager.setValue(multiplier, 2.5)
		MockManager.timersActive = true

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			derivedMultiplyTargetUids: [derived],
			derivedMultiplierUids: [multiplier],
			derivedMultiplyTotalTargetUid: total
		})
		verify(randomizer)

		waitForValue(uid, 4)
		waitForValue(derived, 10)
		waitForValue(total, 10)
		randomizer.destroy()
	}

	function test_randomizer_followSignOf_data() {
		return [
			{ tag: "positive", initial: -80, sign: 4, expected: 80 },
			{ tag: "negative", initial: 80, sign: -2, expected: -80 },
			{ tag: "unset", initial: -80, sign: NaN, expected: -80 },
		]
	}

	function test_randomizer_followSignOf(row) {
		const uid = "mock/com.victronenergy.test.mockworker/Random/Sign/" + row.tag
		const total = uid + "/Total"
		MockManager.setValue(uid, row.initial)
		MockManager.timersActive = true

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			followSignOf: row.sign,
			totalTargetUid: total
		})
		verify(randomizer)
		waitForValue(total, row.expected)
		waitForValue(uid, row.expected)
		randomizer.destroy()
	}

	// Production DC power binds followSignOf to the SOC animator's step direction.
	function test_randomizer_followSignOf_tracksInitialStepSize() {
		const power = "mock/com.victronenergy.test.mockworker/Random/TrackedSign/Power"
		const soc = power + "/Soc"
		MockManager.setValue(power, -100)
		MockManager.setValue(soc, 40)
		MockManager.timersActive = true

		const range = rangeComponent.createObject(root, {
			valueUid: soc,
			active: true,
			interval: 5000,
			minimumValue: -100000,
			maximumValue: 100000,
			stepSize: 5
		})
		verify(range)
		compare(range.actualStepSizes[0], 5)
		const randomizer = signedRandomizerComponent.createObject(root, {
			valueUid: power,
			stepSource: range,
			active: true
		})
		verify(randomizer)
		compare(randomizer.followSignOf, 5)

		waitForValue(power, 100)
		tryVerify(function() { return range.actualStepSizes[0] === 5 })
		range.destroy()
		randomizer.destroy()
	}

	function test_toggler_alternates_data() {
		return [
			{ tag: "a-to-b", initial: 1, expected: 0 },
			{ tag: "b-to-a", initial: 0, expected: 1 },
		]
	}

	function test_toggler_alternates(row) {
		const uid = "mock/com.victronenergy.test.mockworker/Toggle/" + row.tag
		MockManager.setValue(uid, row.initial)
		MockManager.timersActive = true

		const toggler = togglerComponent.createObject(root, {
			valueUid: uid,
			active: true,
			valueA: 1,
			valueB: 0
		})
		verify(toggler)
		waitForValue(uid, row.expected)
		toggler.destroy()
	}

	Component {
		id: notifyRandomizerComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property string valueUid
			property string derivedUid
			property string totalUid
			property int updates: 0
			property int totals: 0
			property int updateMismatches: 0
			property int derivedMismatches: 0
			property int totalMismatches: 0
			VeQuickItem { uid: valueUid }
			// Handler must observe the producer write, not a value queued for later.
			onNotifyUpdate: function(index, newValue) {
				updates++
				if (MockManager.value(valueUid) !== newValue) {
					updateMismatches++
				}
				if (MockManager.value(derivedUid) !== newValue / 2) {
					derivedMismatches++
				}
			}
			onNotifyTotal: function(total) {
				totals++
				if (MockManager.value(totalUid) !== total) {
					totalMismatches++
				}
			}
		}
	}

	Component {
		id: notifyRangeComponent
		MockDataRangeAnimator {
			interval: 30
			property string valueUid
			property string totalUid
			property int totals: 0
			property int itemMismatches: 0
			property int totalMismatches: 0
			VeQuickItem { uid: valueUid }
			onNotifyTotal: function(total) {
				totals++
				if (MockManager.value(valueUid) !== total) {
					itemMismatches++
				}
				if (MockManager.value(totalUid) !== total) {
					totalMismatches++
				}
			}
		}
	}

	// notifyUpdate/notifyTotal must not run before setValue() of the tick's uids.
	function test_randomizer_notifyAfterWrite() {
		const uid = "mock/com.victronenergy.test.mockworker/Notify/Random"
		const derived = uid + "/Derived"
		const total = uid + "/Total"
		const divisor = uid + "/Divisor"
		MockManager.setValue(uid, 1)
		MockManager.setValue(derived, 0)
		MockManager.setValue(total, 0)
		MockManager.setValue(divisor, 2)
		MockManager.timersActive = true

		const randomizer = notifyRandomizerComponent.createObject(root, {
			valueUid: uid,
			derivedUid: derived,
			totalUid: total,
			active: true,
			repeat: false,
			minimumValue: 7,
			maximumValue: 7,
			totalTargetUid: total,
			derivedTargetUids: [derived],
			derivedDivisorUids: [divisor]
		})
		verify(randomizer)
		tryVerify(function() {
			return randomizer.updates >= 1 && randomizer.totals >= 1
		}, 5000, "updates " + randomizer.updates + " totals " + randomizer.totals)
		compare(randomizer.updateMismatches, 0)
		compare(randomizer.derivedMismatches, 0)
		compare(randomizer.totalMismatches, 0)
		randomizer.destroy()
	}

	function test_rangeAnimator_notifyAfterWrite() {
		const uid = "mock/com.victronenergy.test.mockworker/Notify/Range"
		const total = uid + "/Total"
		MockManager.setValue(uid, 40)
		MockManager.setValue(total, 0)
		MockManager.timersActive = true

		const range = notifyRangeComponent.createObject(root, {
			valueUid: uid,
			totalUid: total,
			active: true,
			repeat: false,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 10,
			totalTargetUid: total
		})
		verify(range)
		tryVerify(function() { return range.totals >= 1 }, 5000, "totals " + range.totals)
		compare(range.itemMismatches, 0)
		compare(range.totalMismatches, 0)
		range.destroy()
	}
}
