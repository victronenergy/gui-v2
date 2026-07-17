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
		// A stopped animator can still flush one tick. Store that, then apply
		// the queue. One value per turn would otherwise delay the next test.
		MockManager.finishExternalWritesForTest()
		MockManager.finishAppliesForTest()
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

	// A paced batch must not revert a newer external write.
	function test_externalWrite_supersedesQueuedUpdate() {
		const uid = "mock/com.victronenergy.test.mockworker/Supersede"
		const filler = "mock/com.victronenergy.test.mockworker/Supersede/Filler/"
		MockManager.setValue(uid, 1)
		// The setup write is still being stored. Wait, or it discards this batch.
		MockManager.finishExternalWritesForTest()

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: filler + i, value: 7 })
		}
		updates.push({ uid: uid, value: 3 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.setValue(uid, 99)

		wait(80)
		compare(MockManager.value(uid), 99)
		compare(MockManager.value(filler + "0"), 7)
	}

	Component {
		id: handlerWriteComponent
		VeQuickItem {
			property string otherUid
			onValueChanged: {
				if (value === 1) {
					MockManager.setValue(otherUid, 5000)
				}
			}
		}
	}

	Component {
		id: veWriteComponent
		VeQuickItem {}
	}

	// A write from a QML handler while a batch is applied replaces the queued
	// update for that uid, even when it is in the chunk being applied.
	function test_handlerWrite_supersedesQueuedUpdate() {
		const trigger = "mock/com.victronenergy.test.mockworker/Handler/Trigger"
		const other = "mock/com.victronenergy.test.mockworker/Handler/Other"
		MockManager.setValue(trigger, 0)
		MockManager.setValue(other, 0)
		const item = handlerWriteComponent.createObject(root, { uid: trigger, otherUid: other })
		verify(item)
		// The setup writes are still being stored. Wait, or they discard this batch.
		MockManager.finishExternalWritesForTest()

		MockManager.applyWorkerUpdatesForTest([{ uid: trigger, value: 1 }, { uid: other, value: 115 }])
		wait(80)
		compare(MockManager.value(trigger), 1)
		compare(MockManager.value(other), 5000)
		item.destroy()
	}

	// VeQuickItem.setValue() must take the same path as MockManager.setValue().
	function test_veQuickItemWrite_supersedesQueuedUpdate() {
		const uid = "mock/com.victronenergy.test.mockworker/VeWrite"
		MockManager.setValue(uid, 1)
		const item = veWriteComponent.createObject(root, { uid: uid })
		verify(item)
		// The setup write is still being stored. Wait, or it discards this batch.
		MockManager.finishExternalWritesForTest()

		MockManager.applyWorkerUpdatesForTest([{ uid: uid, value: 3 }])
		item.setValue(99)
		wait(80)
		compare(MockManager.value(uid), 99)
		item.destroy()
	}

	// A write between an animator tick and the flush of its batch must win, and
	// calculators flushed with that batch must read the written value.
	function test_externalWrite_supersedesBatchedTimerUpdate() {
		const pv = "com.victronenergy.pvinverter.mockworker.batched"
		const source = "mock/" + pv + "/Ac/L1/Power"
		const target = "mock/com.victronenergy.system.mockworker/Ac/PvBatched"
		MockManager.setValue(source, 10)
		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		calc.addService("mock/" + pv)
		waitForValue(target + "/L1/Power", 10)

		MockManager.queueTimerUpdateForTest(source, 5000)
		MockManager.setValue(source, 115)
		wait(80)
		compare(MockManager.value(source), 115)
		compare(MockManager.value(target + "/L1/Power"), 115)
		calc.destroy()
	}

	// The tick writes Power 5000, Current 20 (5000 / 250 V) and Total 5000. An
	// external write to any of them, or to the voltage, before the flush must drop
	// the whole tick, not leave outputs computed from the superseded values.
	function test_externalWrite_dropsWholeTimerTick_data() {
		return [
			{ tag: "output", write: "", value: 115, power: 115 },
			{ tag: "derived", write: "/Current", value: 7, power: 100 },
			{ tag: "divisor", write: "/Voltage", value: 230, power: 100 },
		]
	}

	function test_externalWrite_dropsWholeTimerTick(row) {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/Tick/" + row.tag
		const current = power + "/Current"
		const total = power + "/Total"
		const voltage = power + "/Voltage"
		MockManager.setValue(power, 100)
		MockManager.setValue(current, 0.4)
		MockManager.setValue(total, 100)
		MockManager.setValue(voltage, 250)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			totalTargetUid: total,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)

		MockManager.tickAnimatorsForTest()
		MockManager.setValue(power + row.write, row.value)
		wait(80)
		compare(MockManager.value(power), row.power)
		compare(MockManager.value(current), row.tag === "derived" ? 7 : 0.4)
		compare(MockManager.value(total), 100)
		compare(MockManager.value(voltage), row.tag === "divisor" ? 230 : 250)
		randomizer.destroy()
	}

	// Y's tick divides by W, which X's earlier tick in the same batch wrote. A write
	// to X's input V drops X's tick, so Y's tick, computed from X's W, must go too.
	function test_externalWrite_dropsDependentTimerTicks() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/Chain"
		const v = base + "/V"
		const w = base + "/W"
		const one = base + "/One"
		const p = base + "/P"
		const i = base + "/I"
		MockManager.setValue(v, 250)
		MockManager.setValue(w, 250)
		MockManager.setValue(one, 1)
		MockManager.setValue(p, 100)
		MockManager.setValue(i, 0.4)
		const x = randomizerComponent.createObject(root, {
			valueUid: v,
			active: true,
			minimumValue: 300,
			derivedTargetUids: [w],
			derivedDivisorUids: [one]
		})
		const y = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [i],
			derivedDivisorUids: [w]
		})
		verify(x)
		verify(y)

		MockManager.tickAnimatorsForTest()
		MockManager.setValue(v, 260)
		wait(80)
		compare(MockManager.value(v), 260)
		compare(MockManager.value(w), 250)
		compare(MockManager.value(p), 100)
		compare(MockManager.value(i), 0.4)
		x.destroy()
		y.destroy()
	}

	// Removing a service that holds only some of a tick's outputs stops the animator
	// and drops its whole tick, not just the outputs under the removed service.
	function test_removeValue_dropsWholeTimerTick() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/Span"
		const removed = "mock/com.victronenergy.tank.mockworker_span"
		MockManager.setValue(keep + "/Power", 100)
		MockManager.setValue(keep + "/Voltage", 250)
		MockManager.setValue(removed + "/Current", 0.4)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: keep + "/Power",
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [removed + "/Current"],
			derivedDivisorUids: [keep + "/Voltage"]
		})
		verify(randomizer)

		MockManager.tickAnimatorsForTest()
		MockManager.removeValue(removed)
		wait(80)
		compare(MockManager.value(keep + "/Power"), 100)
		verify(isInvalid(MockManager.value(removed + "/Current")))
		randomizer.destroy()
	}

	// Re-registering after a property change keeps the animator id. The tick made
	// with the old config must not be applied.
	function test_reregister_dropsPendingTimerTick() {
		compare(MockManager.timersActive, false)
		const p = "mock/com.victronenergy.test.mockworker/Reregister/P"
		MockManager.setValue(p, 100)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 5000
		})
		verify(randomizer)

		MockManager.tickAnimatorsForTest()
		randomizer.deltaLow = 1
		wait(80)
		compare(MockManager.value(p), 100)
		randomizer.destroy()
	}

	// a writes X, b reads X and writes P and Y, c writes X. Dropping c's tick removes
	// every batched X, so a's tick and b's tick, computed from a's X, must go too.
	function test_droppedTick_dropsTicksSharingItsOutputs() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/Shared"
		const x = base + "/X"
		const p = base + "/P"
		const y = base + "/Y"
		MockManager.setValue(x, 10)
		MockManager.setValue(p, 100)
		MockManager.setValue(y, 10)
		const a = randomizerComponent.createObject(root, {
			valueUid: x,
			active: true,
			minimumValue: 5000
		})
		const b = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 300,
			derivedTargetUids: [y],
			derivedDivisorUids: [x]
		})
		const c = randomizerComponent.createObject(root, {
			valueUid: x,
			active: true,
			minimumValue: 7000
		})
		verify(a)
		verify(b)
		verify(c)

		MockManager.tickAnimatorsForTest()
		c.deltaLow = 1
		wait(80)
		compare(MockManager.value(x), 10)
		compare(MockManager.value(p), 100)
		compare(MockManager.value(y), 10)
		a.destroy()
		b.destroy()
		c.destroy()
	}

	Component {
		id: reregisteringRandomizerComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property string valueUid
			property int totals: 0
			VeQuickItem { uid: valueUid }
			onNotifyTotal: function(total) {
				totals++
				if (interval === 30) {
					interval = 31
				} else {
					interval = 30
				}
			}
		}
	}

	function test_notifyHandler_reregistersOwnAnimator() {
		const uid = "mock/com.victronenergy.test.mockworker/Notify/Reregister"
		MockManager.setValue(uid, 5)
		MockManager.timersActive = true
		const randomizer = reregisteringRandomizerComponent.createObject(root, {
			valueUid: uid,
			active: true
		})
		verify(randomizer)
		tryVerify(function() { return randomizer.totals >= 3 }, 5000, "totals " + randomizer.totals)
		randomizer.destroy()
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

	// A queued batch must not call setValue() on a removed service.
	// setValue() uses itemGetOrCreate() and would recreate it.
	function test_removeValue_doesNotResurrectService() {
		const service = "mock/com.victronenergy.tank.mockworker_remove"
		const level = service + "/Level"
		const other = "mock/com.victronenergy.test.mockworker/Keep"
		MockManager.setValue(level, 1)
		// The setup write is still being stored. Wait, or it discards this batch.
		MockManager.finishExternalWritesForTest()

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: other + "/Filler/" + i, value: 7 })
		}
		updates.push({ uid: level, value: 9 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.removeValue(service)

		wait(80)
		verify(isInvalid(MockManager.value(level)))
		compare(MockManager.value(other + "/Filler/0"), 7)

		// An intentional later write still applies.
		MockManager.setValue(level, 4)
		compare(MockManager.value(level), 4)
		MockManager.removeValue(service)
	}

	function test_removeServices_doesNotResurrectService() {
		const level = "mock/com.victronenergy.tank.mockworker_svc_a/Level"
		const other = "mock/com.victronenergy.temperature.mockworker_svc/Temperature"
		MockManager.setValue(level, 1)
		MockManager.setValue(other, 2)
		// The setup writes are still being stored. Wait, or they discard this batch.
		MockManager.finishExternalWritesForTest()

		let updates = []
		for (let i = 0; i < 20; ++i) {
			updates.push({ uid: "mock/com.victronenergy.test.mockworker/SvcFiller/" + i, value: 1 })
		}
		updates.push({ uid: level, value: 9 })
		MockManager.applyWorkerUpdatesForTest(updates)
		MockManager.removeServices("tank")
		wait(80)
		verify(isInvalid(MockManager.value(level)))
		compare(MockManager.value(other), 2)
	}

	// removeValue() must stop the animator before it can write again.
	// A 30ms writer that is still running will recreate the service during this wait.
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

	// An external write must be the value the next tick continues from.
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

	// The model index is live. Adding the same service again must update it, not double the sum.
	function test_consumption_indexCanChange() {
		const system = "mock/com.victronenergy.system.mockworker.index"
		const gauges = "mock/com.victronenergy.settings.mockworker.index/Settings/Gui/Gauges"
		const ac = "mock/com.victronenergy.acsystem.mockworker.index"
		MockManager.setValue(ac + "/Ac/NumberOfPhases", 1)
		MockManager.setValue(ac + "/Ac/In/1/L1/P", 10)
		MockManager.setValue(ac + "/Ac/In/1/L1/I", 1)
		MockManager.setValue(ac + "/Ac/In/2/L1/P", 30)
		MockManager.setValue(ac + "/Ac/In/2/L1/I", 3)
		MockManager.setValue(ac + "/Ac/Out/L1/P", 0)
		MockManager.setValue(ac + "/Ac/Out/L1/I", 0)
		MockManager.setValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 0)
		MockManager.setValue(gauges + "/Ac/AcIn2/Consumption/Current/Max", 0)

		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		calc.addService(ac, "acsystem", 1)
		waitForValue(system + "/Ac/ConsumptionOnInput/L1/Power", 30)
		waitForValue(gauges + "/Ac/AcIn2/Consumption/Current/Max", 3)
		compare(MockManager.value(gauges + "/Ac/AcIn1/Consumption/Current/Max"), 0)

		calc.addService(ac, "acsystem", 1)
		compare(MockManager.value(system + "/Ac/ConsumptionOnInput/L1/Power"), 30)

		calc.addService(ac, "acsystem", 0)
		waitForValue(system + "/Ac/ConsumptionOnInput/L1/Power", 10)
		waitForValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 1)

		calc.destroy()
	}

	// Removing the system pauses consumption. A source change must not recreate it.
	function test_consumption_resumesAfterSystemRestore() {
		const system = "mock/com.victronenergy.system.mockworker.resume"
		const inverter = "mock/com.victronenergy.inverter.mockworker.resume"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)

		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		calc.addService(inverter, "inverter", 0)
		waitForValue(system + "/Ac/Consumption/L1/Current", 4)

		MockManager.removeValue(system)
		wait(80)
		verify(isInvalid(MockManager.value(system + "/Ac/Consumption/L1/Current")))

		MockManager.setValue(inverter + "/Ac/Out/L1/I", 8)
		wait(80)
		verify(isInvalid(MockManager.value(system + "/Ac/Consumption/L1/Current")))

		MockManager.setValue(system + "/Dc/System/Power", 1)
		waitForValue(system + "/Ac/Consumption/L1/Current", 8)

		calc.destroy()
		MockManager.removeValue(system)
		MockManager.removeValue(inverter)
	}

	function test_phaseSum_ignoresDuplicateAndResumes() {
		const pv = "com.victronenergy.pvinverter.mockworker.resume"
		const target = "mock/com.victronenergy.system.mockworker/Ac/PvResume"
		MockManager.setValue(pv + "/Ac/L1/Power", 100)

		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		calc.addService("mock/" + pv)
		calc.addService("mock/" + pv)
		waitForValue(target + "/L1/Power", 100)

		MockManager.removeValue(target)
		wait(80)
		verify(isInvalid(MockManager.value(target + "/L1/Power")))

		MockManager.setValue(pv + "/Ac/L1/Power", 80)
		wait(80)
		verify(isInvalid(MockManager.value(target + "/L1/Power")))

		MockManager.setValue(target + "/L1/Power", 1)
		waitForValue(target + "/L1/Power", 80)

		calc.destroy()
		MockManager.removeValue(target)
		MockManager.removeValue("mock/" + pv)
	}

	function test_stepper_resumesAfterSameUidRestored() {
		const service = "mock/com.victronenergy.tank.mockworker_resume"
		const level = service + "/Level"
		MockManager.setValue(level, 10)
		MockManager.timersActive = true

		const stepper = stepperComponent.createObject(root, { valueUid: level, active: true })
		verify(stepper)
		tryVerify(function() { return MockManager.value(level) >= 12 })

		MockManager.removeValue(service)
		wait(250)
		verify(isInvalid(MockManager.value(level)))

		MockManager.setValue(level, 3)
		tryVerify(function() { return MockManager.value(level) >= 5 })

		stepper.destroy()
		MockManager.removeValue(service)
	}

	Component {
		id: missingTotalComponent
		MockDataRandomizer {
			interval: 30
			property string sourceUid
			property string totalUid
			totalTargetUid: totalUid
			VeQuickItem { uid: sourceUid }
		}
	}

	Component {
		id: multiplyTotalComponent
		MockDataRangeAnimator {
			interval: 30
			property string currentUid
			property string voltageUid
			property string powerUid
			property string totalUid
			minimumValue: 0
			maximumValue: 100
			stepSize: 1
			derivedMultiplyTargetUids: [powerUid]
			derivedMultiplierUids: [voltageUid]
			derivedMultiplyTotalTargetUid: totalUid
			VeQuickItem { uid: currentUid }
		}
	}

	function test_randomizer_doesNotWriteTotalWhenSourceMissing() {
		const source = "mock/com.victronenergy.test.mockworker/Missing/Source"
		const total = "mock/com.victronenergy.test.mockworker/Missing/Total"
		MockManager.setValue(total, 12)
		MockManager.timersActive = true

		const randomizer = missingTotalComponent.createObject(root, {
			sourceUid: source,
			totalUid: total,
			active: true
		})
		verify(randomizer)
		wait(200)
		compare(MockManager.value(total), 12)
		verify(isInvalid(MockManager.value(source)))

		randomizer.destroy()
		MockManager.removeValue(total)
	}

	function test_multiplyTotal_notWrittenWhenVoltageMissing() {
		const base = "mock/com.victronenergy.test.mockworker/Multiply"
		const current = base + "/I"
		const voltage = base + "/V"
		const total = base + "/Total"
		MockManager.setValue(current, 5)
		MockManager.setValue(total, 9)
		MockManager.timersActive = true

		const animator = multiplyTotalComponent.createObject(root, {
			currentUid: current,
			voltageUid: voltage,
			powerUid: base + "/P",
			totalUid: total,
			active: true
		})
		verify(animator)
		tryVerify(function() { return MockManager.value(current) !== 5 })
		compare(MockManager.value(total), 9)

		animator.destroy()
		MockManager.removeValue(base)
	}
}
