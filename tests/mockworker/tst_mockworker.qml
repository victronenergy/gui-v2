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
		// destroy() deletes later. Run that first, or the destructor's
		// invalidation flush lands in the next test's batch.
		wait(0)
		MockManager.flushPendingForTest()
		// One value per turn would otherwise delay the next test.
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

	// Deleting one watched current, while the service stays, must rerun the total.
	// The deleted current must not be written back.
	function test_removeValue_recalculatesWatchedSource() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.partial"
		const inverter = "mock/com.victronenergy.inverter.mockworker.partial"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		calc.addService(inverter, "inverter", 0)
		waitForValue(system + "/Ac/Consumption/L1/Current", 4)

		MockManager.removeValue(inverter + "/Ac/Out/L1/I")
		tryVerify(function() {
			lastValue = MockManager.value(system + "/Ac/Consumption/L1/Current")
			return isInvalid(lastValue)
		}, 5000, "consumption current should clear, got " + lastValue)
		verify(isInvalid(MockManager.value(inverter + "/Ac/Out/L1/I")))
		calc.destroy()
	}

	// A queued current must not still raise the consumption total or gauge maximum
	// after the voltage that current was calculated from is written.
	function test_externalWrite_dropsCalculatorOutputs() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.calcqueue"
		const gauges = "mock/com.victronenergy.settings.mockworker.calcqueue/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.calcqueue"
		const power = inverter + "/Ac/Out/L1/P"
		const current = inverter + "/Ac/Out/L1/I"
		const voltage = inverter + "/Ac/Out/L1/V"
		const total = inverter + "/Ac/Out/P"
		MockManager.setValue(power, 100)
		MockManager.setValue(current, 0.4)
		MockManager.setValue(voltage, 250)
		MockManager.setValue(total, 100)
		MockManager.setValue(gauges + "/Ac/AcIn1/Consumption/Current/Max", 1)

		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		calc.addService(inverter, "inverter", 0)
		waitForValue(system + "/Ac/Consumption/L1/Current", 0.4)
		compare(MockManager.value(gauges + "/Ac/AcIn1/Consumption/Current/Max"), 1)
		// That wait returns while later consumption writes are still paced out.
		// A flush during that drain only queues the animator tick.
		MockManager.finishAppliesForTest()

		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			totalTargetUid: total,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(power), 5000)
			MockManager.setValue(voltage, 230)
			wait(80)
			compare(MockManager.value(current), 0.4)
			compare(MockManager.value(system + "/Ac/Consumption/L1/Current"), 0.4)
			compare(MockManager.value(gauges + "/Ac/AcIn1/Consumption/Current/Max"), 1)
			compare(MockManager.value(total), 100)
		} finally {
			randomizer.destroy()
			calc.destroy()
		}
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

	// The tick is already queued. A write must still drop outputs that have not
	// been applied, not only the uid that was written.
	function test_externalWrite_dropsQueuedTimerTick() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/QueuedTick/Power"
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
		try {
			MockManager.tickAnimatorsForTest()
			// Flush now. A timed wait can also apply the later outputs.
			MockManager.flushPendingForTest()
			compare(MockManager.value(power), 5000)
			MockManager.setValue(power, 115)
			wait(80)
			compare(MockManager.value(power), 115)
			compare(MockManager.value(current), 0.4)
			compare(MockManager.value(total), 100)
		} finally {
			randomizer.destroy()
		}
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

	// X is already queued. Y then reads X's output and has not been flushed.
	// A write that drops X must also drop Y, not only ticks in the same batch.
	function test_externalWrite_dropsCrossFlushDependentTick() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/CrossFlush"
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
		verify(x)
		let y = null
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(v), 300)
			// W is still queued. Turn X off so the next tick hook does not tick it again.
			x.active = false
			y = randomizerComponent.createObject(root, {
				valueUid: p,
				active: true,
				minimumValue: 5000,
				derivedTargetUids: [i],
				derivedDivisorUids: [w]
			})
			verify(y)
			MockManager.tickAnimatorsForTest()
			MockManager.setValue(v, 260)
			wait(80)
			compare(MockManager.value(v), 260)
			compare(MockManager.value(w), 250)
			compare(MockManager.value(p), 100)
			compare(MockManager.value(i), 0.4)
		} finally {
			if (y) {
				y.destroy()
			}
			x.destroy()
		}
	}

	// A's derived W is still queued. B reads that W and replaces it. Writing A's
	// voltage must drop B's replacement, not only A's leftover record.
	function test_externalWrite_dropsReplacedDependentTick() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/ReplacedWrite"
		const v = base + "/V"
		const w = base + "/W"
		const p = base + "/P"
		MockManager.setValue(v, 250)
		MockManager.setValue(w, 1)
		MockManager.setValue(p, 100)
		const a = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [w],
			derivedDivisorUids: [v]
		})
		verify(a)
		let b = null
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(p), 5000)
			compare(MockManager.value(w), 1)
			a.active = false
			b = stepperComponent.createObject(root, { valueUid: w, active: true })
			verify(b)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.setValue(v, 260)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(v), 260)
			compare(MockManager.value(w), 1)
			compare(MockManager.value(p), 5000)
		} finally {
			if (b) {
				b.destroy()
			}
			a.destroy()
		}
	}

	// Same replacement as above. Unregistering A must drop B even though A no
	// longer lists W.
	function test_unregister_dropsReplacedDependentTick() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/ReplacedUnregister"
		const v = base + "/V"
		const w = base + "/W"
		const p = base + "/P"
		MockManager.setValue(v, 250)
		MockManager.setValue(w, 1)
		MockManager.setValue(p, 100)
		const a = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [w],
			derivedDivisorUids: [v]
		})
		verify(a)
		let b = null
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(w), 1)
			a.active = false
			b = stepperComponent.createObject(root, { valueUid: w, active: true })
			verify(b)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			a.deltaLow = 1
			MockManager.finishAppliesForTest()
			compare(MockManager.value(w), 1)
		} finally {
			if (b) {
				b.destroy()
			}
			a.destroy()
		}
	}

	// C replaces W without reading it. Writing A's voltage must not drop C's W.
	function test_externalWrite_keepsReplacementThatDidNotRead() {
		compare(MockManager.timersActive, false)
		const base = "mock/com.victronenergy.test.mockworker/ReplacedUnread"
		const v = base + "/V"
		const w = base + "/W"
		const p = base + "/P"
		const one = base + "/One"
		const other = base + "/Other"
		MockManager.setValue(v, 250)
		MockManager.setValue(w, 1)
		MockManager.setValue(p, 100)
		MockManager.setValue(one, 1)
		MockManager.setValue(other, 10)
		const a = randomizerComponent.createObject(root, {
			valueUid: p,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [w],
			derivedDivisorUids: [v]
		})
		verify(a)
		let c = null
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(p), 5000)
			compare(MockManager.value(w), 1)
			a.active = false
			c = randomizerComponent.createObject(root, {
				valueUid: other,
				active: true,
				minimumValue: 40,
				derivedTargetUids: [w],
				derivedDivisorUids: [one]
			})
			verify(c)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.setValue(v, 260)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(w), 40)
			compare(MockManager.value(other), 40)
		} finally {
			if (c) {
				c.destroy()
			}
			a.destroy()
		}
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

	// Writing the surviving output must not resume a writer that still owns a
	// removed path. Restoring that path does resume it. Do not remove the path
	// the animator's own item is bound to: that warns as the item is destroyed.
	function test_removeValue_survivingWriteDoesNotResume() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/SpanLive"
		const removed = "mock/com.victronenergy.tank.mockworker_span_live"
		const power = keep + "/Power"
		const voltage = keep + "/Voltage"
		const current = removed + "/Current"
		MockManager.setValue(power, 100)
		MockManager.setValue(voltage, 250)
		MockManager.setValue(current, 0.4)
		MockManager.timersActive = true
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.removeValue(removed)
			MockManager.setValue(power, 80)
			wait(250)
			compare(MockManager.value(power), 80)
			verify(isInvalid(MockManager.value(current)))

			MockManager.setValue(current, 1)
			tryVerify(function() { return MockManager.value(power) >= 5000 })
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
		}
	}

	// The tick only read the removed voltage. Its power and current must not be
	// applied after that voltage is gone.
	function test_removeValue_dropsTickThatReadRemovedInput() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/ReadInput"
		const voltageService = "mock/com.victronenergy.grid.mockworker_readinput"
		const power = keep + "/Power"
		const current = keep + "/Current"
		const voltage = voltageService + "/Ac/L1/Voltage"
		MockManager.setValue(power, 100)
		MockManager.setValue(current, 0.4)
		MockManager.setValue(voltage, 250)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)

		MockManager.tickAnimatorsForTest()
		MockManager.removeValue(voltageService)
		wait(80)
		compare(MockManager.value(power), 100)
		compare(MockManager.value(current), 0.4)
		verify(isInvalid(MockManager.value(voltage)))
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

	// The first output is already applied. Changing the animator must still drop
	// the rest of that tick, not leave current and total calculated from it.
	function test_reregister_dropsQueuedTimerTick() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/ReregisterQueued/Power"
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
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(power), 5000)
			randomizer.deltaLow = 1
			wait(80)
			compare(MockManager.value(power), 5000)
			compare(MockManager.value(current), 0.4)
			compare(MockManager.value(total), 100)
		} finally {
			randomizer.destroy()
		}
	}

	// Repeated ticks must not keep a record for every past tick. One record owns
	// the outputs still waiting.
	function test_queuedTicks_doNotAccumulate() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/TickRecords/Power"
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
		try {
			for (let i = 0; i < 20; ++i) {
				MockManager.tickAnimatorsForTest()
				MockManager.flushPendingForTest()
			}
			verify(MockManager.queuedTickCountForTest() <= 1)
		} finally {
			randomizer.destroy()
		}
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
		try {
			tryVerify(function() { return randomizer.totals >= 3 }, 5000, "totals " + randomizer.totals)
		} finally {
			randomizer.destroy()
		}
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

	// Completion publishes the step from that moment. A later change, before
	// activation, must be the step the first tick uses.
	function test_rangeAnimator_stepSizeBeforeActivation() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/StepBeforeActive"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = false
		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: false,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 8
		})
		verify(range)
		try {
			compare(range.actualStepSizes[0], 8)
			range.stepSize = 2
			compare(range.actualStepSizes[0], 2)
			range.active = true
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 12)
		} finally {
			range.destroy()
		}
	}

	// An unavailable step is NaN at completion. A later finite step must
	// replace it. NaN is not equal to itself, so a normal comparison misses it.
	function test_rangeAnimator_nanStepBecomesFinite() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/NanStep"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = false
		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: false,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: NaN
		})
		verify(range)
		try {
			verify(isNaN(range.actualStepSizes[0]))
			range.stepSize = 2
			compare(range.actualStepSizes[0], 2)
			range.active = true
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 12)
		} finally {
			range.destroy()
			MockManager.removeValue(uid)
		}
	}

	// An active animator whose step size resolves after registration, but before
	// the first tick, must use the resolved step.
	function test_rangeAnimator_stepSizeBeforeFirstTick() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/StepBeforeTick"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = false
		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			repeat: false,
			interval: 10000,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 8
		})
		verify(range)
		try {
			range.stepSize = 2
			compare(range.actualStepSizes[0], 2)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 12)
		} finally {
			range.destroy()
		}
	}

	// An explicit per-item step must not be replaced when stepSize changes.
	function test_rangeAnimator_explicitStepSurvivesStepSizeChange() {
		const uid = "mock/com.victronenergy.test.mockworker/Range/ExplicitStep"
		MockManager.setValue(uid, 10)
		MockManager.timersActive = false
		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: false,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 8
		})
		verify(range)
		try {
			range.actualStepSizes = [3]
			range.stepSize = 2
			compare(range.actualStepSizes[0], 3)
			range.active = true
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 13)
		} finally {
			range.destroy()
		}
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
		// Live 30 ms ticks can skip 95 before it is applied. Tick explicitly.
		MockManager.timersActive = false

		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 5
		})
		verify(range)
		try {
			// The bound tick clamps and reverses. The next tick moves.
			MockManager.tickAnimatorsForTest()
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			wait(0)
			compare(range.actualStepSizes[0], -5)
			compare(MockManager.value(uid), 95)

			range.stepSize = 2
			compare(range.actualStepSizes[0], -5)

			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(range.actualStepSizes[0], -5)
			compare(MockManager.value(uid), 90)
		} finally {
			range.destroy()
		}
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
		id: notifyCountComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property string valueUid
			property int updates: 0
			property int totals: 0
			property int mismatches: 0
			VeQuickItem { uid: valueUid }
			onNotifyUpdate: function(index, newValue) {
				updates++
				if (MockManager.value(valueUid) !== newValue) {
					mismatches++
				}
			}
			onNotifyTotal: function(total) {
				totals++
				if (MockManager.value(valueUid) !== total) {
					mismatches++
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

	// Changing the configuration must not clear a removal pause, including a
	// change made while the animator is inactive. The old tick must still drop.
	function test_reregister_keepsRemovalPause() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/PauseConfig"
		const removed = "mock/com.victronenergy.tank.mockworker_pause_config"
		const power = keep + "/Power"
		const voltage = keep + "/Voltage"
		const current = removed + "/Current"
		MockManager.setValue(power, 100)
		MockManager.setValue(voltage, 250)
		MockManager.setValue(current, 0.4)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.removeValue(removed)
			randomizer.interval = 40
			randomizer.active = false
			randomizer.deltaLow = 1
			randomizer.active = true
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 100)
			verify(isInvalid(MockManager.value(current)))

			MockManager.setValue(current, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 5000)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
			MockManager.removeValue(keep)
		}
	}

	// Restoring one removed output must not resume another output of the same writer.
	function test_removeValue_restoresOneOutputOnly() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/OneOfSeveral"
		const removed = "mock/com.victronenergy.tank.mockworker_one_of_several"
		const power = keep + "/Power"
		const voltage = keep + "/Voltage"
		const current = removed + "/Current"
		const total = removed + "/Total"
		MockManager.setValue(power, 100)
		MockManager.setValue(voltage, 250)
		MockManager.setValue(current, 0.4)
		MockManager.setValue(total, 100)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			totalTargetUid: total,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.removeValue(removed)
			MockManager.setValue(current, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 100)
			compare(MockManager.value(current), 1)
			verify(isInvalid(MockManager.value(total)))

			MockManager.setValue(total, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 5000)
			compare(MockManager.value(total), 5000)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
			MockManager.removeValue(keep)
		}
	}

	// Removing one consumption output must not pause the other outputs.
	function test_removeValue_pausesConsumptionLeafOnly() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.leaf"
		const inverter = "mock/com.victronenergy.inverter.mockworker.leaf"
		const removed = system + "/Ac/Consumption/L1/Power"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(inverter + "/Ac/Out/L2/I", 1)
		MockManager.setValue(inverter + "/Ac/Out/L2/P", 10)
		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(system + "/Ac/Consumption/L1/Power", 40)
			waitForValue(system + "/Ac/Consumption/L2/Power", 10)
			MockManager.finishAppliesForTest()

			MockManager.removeValue(removed)
			MockManager.setValue(inverter + "/Ac/Out/L1/P", 80)
			MockManager.setValue(inverter + "/Ac/Out/L2/P", 30)
			MockManager.setValue(inverter + "/Ac/Out/L1/I", 9)
			waitForValue(system + "/Ac/Consumption/L2/Power", 30)
			waitForValue(system + "/Ac/Consumption/L1/Current", 9)
			verify(isInvalid(MockManager.value(removed)))

			MockManager.setValue(removed, 1)
			waitForValue(removed, 80)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(inverter)
		}
	}

	// Removing one phase-sum output must not pause the other phases.
	function test_removeValue_pausesPhaseSumLeafOnly() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker.leaf"
		const target = "mock/com.victronenergy.system.mockworker/Ac/PvLeaf"
		const removed = target + "/L1/Power"
		MockManager.setValue(pv + "/Ac/L1/Power", 100)
		MockManager.setValue(pv + "/Ac/L2/Power", 40)
		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		try {
			calc.addService("mock/" + pv)
			waitForValue(target + "/L1/Power", 100)
			waitForValue(target + "/L2/Power", 40)
			MockManager.finishAppliesForTest()

			MockManager.removeValue(removed)
			MockManager.setValue(pv + "/Ac/L1/Power", 70)
			MockManager.setValue(pv + "/Ac/L2/Power", 55)
			waitForValue(target + "/L2/Power", 55)
			verify(isInvalid(MockManager.value(removed)))

			MockManager.setValue(removed, 1)
			waitForValue(removed, 70)
		} finally {
			calc.destroy()
			MockManager.removeValue(target)
			MockManager.removeValue("mock/" + pv)
		}
	}

	// Removing one gauge maximum must not pause the other gauge.
	function test_removeValue_pausesGaugeLeafOnly() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.gaugeleaf"
		const gauges = "mock/com.victronenergy.settings.mockworker.gaugeleaf/Settings/Gui/Gauges"
		const inverter0 = "mock/com.victronenergy.inverter.mockworker.gaugeleaf0"
		const inverter1 = "mock/com.victronenergy.inverter.mockworker.gaugeleaf1"
		const removed = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const other = gauges + "/Ac/AcIn2/Consumption/Current/Max"
		MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter0 + "/Ac/Out/L1/P", 40)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/I", 2)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/P", 20)
		MockManager.setValue(removed, 0)
		MockManager.setValue(other, 0)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter0, "inverter", 0)
			calc.addService(inverter1, "inverter", 1)
			waitForValue(removed, 4)
			waitForValue(other, 6)
			MockManager.finishAppliesForTest()

			MockManager.removeValue(removed)
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			verify(isInvalid(MockManager.value(removed)))

			MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 9)
			waitForValue(other, 11)
			verify(isInvalid(MockManager.value(removed)))

			MockManager.setValue(removed, 1)
			waitForValue(removed, 9)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(inverter0)
			MockManager.removeValue(inverter1)
		}
	}

	// A clearing write must survive a later write of an input the old tick read.
	function test_invalidate_survivesOldInputWrite() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker.invalidate"
		const target = "mock/com.victronenergy.system.mockworker/Ac/Invalidate"
		const l1 = target + "/L1/Power"
		const l2 = target + "/L2/Power"
		const l3 = target + "/L3/Power"
		MockManager.setValue(pv + "/Ac/L1/Power", 100)
		MockManager.setValue(pv + "/Ac/L2/Power", 40)
		MockManager.setValue(pv + "/Ac/L3/Power", 7)
		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		try {
			calc.addService("mock/" + pv)
			waitForValue(l1, 100)
			waitForValue(l2, 40)
			waitForValue(l3, 7)
			MockManager.finishAppliesForTest()

			MockManager.setValue(pv + "/Ac/L1/Power", 200)
			MockManager.setValue(pv + "/Ac/L2/Power", 50)
			MockManager.setValue(pv + "/Ac/L3/Power", 9)
			MockManager.flushPendingForTest()
			calc.removeService("mock/" + pv)
			MockManager.flushPendingForTest()
			MockManager.setValue(pv + "/Ac/L1/Power", 80)
			MockManager.finishAppliesForTest()
			verify(isInvalid(MockManager.value(l1)))
			verify(isInvalid(MockManager.value(l3)))
		} finally {
			calc.destroy()
			MockManager.removeValue(target)
			MockManager.removeValue("mock/" + pv)
		}
	}

	// An explicit step assigned after a reversal was queued must win.
	function test_rangeAnimator_ignoresStaleReversal() {
		compare(MockManager.timersActive, false)
		const uid = "mock/com.victronenergy.test.mockworker/Range/StaleReverse"
		MockManager.setValue(uid, 100)
		const range = rangeComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 0,
			maximumValue: 100,
			stepSize: 5
		})
		verify(range)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.tickAnimatorsForTest()
			range.actualStepSizes = [3]
			wait(0)
			compare(range.actualStepSizes[0], 3)
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 95)

			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(range.actualStepSizes[0], 3)
			compare(MockManager.value(uid), 98)
		} finally {
			range.destroy()
			MockManager.removeValue(uid)
		}
	}

	// Turning auto-max off must drop a queued gauge maximum and keep the rest.
	function test_gaugesAutoMaxOff_dropsQueuedGaugeOnly() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.automax"
		const gauges = "mock/com.victronenergy.settings.mockworker.automax/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.automax"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const consumption = system + "/Ac/Consumption/L1/Current"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(consumption, 4)
			waitForValue(gauge, 4)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter + "/Ac/Out/L1/I", 20)
			MockManager.flushPendingForTest()
			calc.gaugesAutoMax = false
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(consumption), 20)
			compare(MockManager.value(gauge), 4)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(inverter)
		}
	}

	// Stopping the calculator must drop a gauge maximum that is still waiting.
	function test_consumption_deactivateDropsQueuedGauge() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.deactivate"
		const gauges = "mock/com.victronenergy.settings.mockworker.deactivate/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.deactivate"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const consumption = system + "/Ac/Consumption/L1/Current"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(consumption, 4)
			waitForValue(gauge, 4)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter + "/Ac/Out/L1/I", 20)
			MockManager.flushPendingForTest()
			calc.active = false
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			verify(isInvalid(MockManager.value(consumption)))
			compare(MockManager.value(gauge), 4)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(inverter)
		}
	}

	// Comparing the old total must not tie the replacement to a removed service.
	// Do not wait between the flush and the write: a wait would drain the queue
	// and the old calculation would already be gone.
	function test_phaseSum_replacementIgnoresRemovedService() {
		compare(MockManager.timersActive, false)
		const a = "com.victronenergy.pvinverter.mockworker.inheritA"
		const b = "com.victronenergy.pvinverter.mockworker.inheritB"
		const target = "mock/com.victronenergy.system.mockworker/Ac/Inherit"
		const l1 = target + "/L1/Power"
		const l2 = target + "/L2/Power"
		const l3 = target + "/L3/Power"
		MockManager.setValue(a + "/Ac/L1/Power", 10)
		MockManager.setValue(a + "/Ac/L2/Power", 20)
		MockManager.setValue(a + "/Ac/L3/Power", 30)
		MockManager.setValue(b + "/Ac/L1/Power", 1)
		MockManager.setValue(b + "/Ac/L2/Power", 2)
		MockManager.setValue(b + "/Ac/L3/Power", 3)

		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		try {
			calc.addService("mock/" + a)
			calc.addService("mock/" + b)
			waitForValue(l1, 11)
			waitForValue(l2, 22)
			waitForValue(l3, 33)
			MockManager.finishAppliesForTest()

			MockManager.setValue(a + "/Ac/L1/Power", 100)
			MockManager.setValue(a + "/Ac/L2/Power", 200)
			MockManager.setValue(a + "/Ac/L3/Power", 300)
			MockManager.setValue(b + "/Ac/L1/Power", 4)
			MockManager.setValue(b + "/Ac/L2/Power", 5)
			MockManager.setValue(b + "/Ac/L3/Power", 6)
			MockManager.flushPendingForTest()
			calc.removeService("mock/" + a)
			MockManager.flushPendingForTest()
			MockManager.setValue(a + "/Ac/L1/Power", 999)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(l1), 4)
			compare(MockManager.value(l2), 5)
			compare(MockManager.value(l3), 6)
		} finally {
			calc.destroy()
			MockManager.removeValue(target)
			MockManager.removeValue("mock/" + a)
			MockManager.removeValue("mock/" + b)
		}
	}

	function test_consumption_replacementIgnoresRemovedService() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.inherit"
		const inverter0 = "com.victronenergy.inverter.mockworker.inherit0"
		const inverter1 = "mock/com.victronenergy.inverter.mockworker.inherit1"
		const current = system + "/Ac/Consumption/L1/Current"
		const power = system + "/Ac/Consumption/L1/Power"
		MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter0 + "/Ac/Out/L1/P", 40)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/I", 9)
		MockManager.setValue(inverter1 + "/Ac/Out/L1/P", 90)

		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		try {
			calc.addService("mock/" + inverter0, "inverter", 0)
			calc.addService(inverter1, "inverter", 1)
			waitForValue(current, 13)
			waitForValue(power, 130)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 6)
			MockManager.setValue(inverter0 + "/Ac/Out/L1/P", 60)
			MockManager.setValue(inverter1 + "/Ac/Out/L1/I", 1)
			MockManager.setValue(inverter1 + "/Ac/Out/L1/P", 10)
			MockManager.flushPendingForTest()
			calc.removeService("mock/" + inverter0)
			MockManager.flushPendingForTest()
			MockManager.setValue(inverter0 + "/Ac/Out/L1/I", 99)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(current), 1)
			compare(MockManager.value(power), 10)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue("mock/" + inverter0)
			MockManager.removeValue(inverter1)
		}
	}

	// An equal recalculation must claim a value that is still queued. Do not
	// wait between the flush and the write: a wait would drain the queue.
	function test_phaseSum_equalResultKeepsQueuedUpdate() {
		compare(MockManager.timersActive, false)
		const a = "com.victronenergy.pvinverter.mockworker.equalA"
		const b = "com.victronenergy.pvinverter.mockworker.equalB"
		const target = "mock/com.victronenergy.system.mockworker/Ac/Equal"
		const l1 = target + "/L1/Power"
		const l2 = target + "/L2/Power"
		const l1Current = target + "/L1/Current"
		const l2Current = target + "/L2/Current"
		const phases = target + "/NumberOfPhases"
		MockManager.setValue(a + "/Ac/L1/Power", 0)
		MockManager.setValue(a + "/Ac/L1/Current", 0)
		MockManager.setValue(b + "/Ac/L1/Power", 10)
		MockManager.setValue(b + "/Ac/L1/Current", 1)

		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power",
			sourceCurrentPattern: "/Ac/L%1/Current"
		})
		verify(calc)
		try {
			calc.addService("mock/" + a)
			calc.addService("mock/" + b)
			waitForValue(l1, 10)
			waitForValue(l1Current, 1)
			waitForValue(phases, 1)
			MockManager.finishAppliesForTest()

			// A still contributes zero, including on the new phase, so removing
			// A does not change the totals or the phase count.
			MockManager.setValue(b + "/Ac/L1/Power", 100)
			MockManager.setValue(b + "/Ac/L1/Current", 5)
			MockManager.setValue(b + "/Ac/L2/Power", 200)
			MockManager.setValue(b + "/Ac/L2/Current", 6)
			MockManager.setValue(a + "/Ac/L2/Power", 0)
			MockManager.setValue(a + "/Ac/L2/Current", 0)
			MockManager.flushPendingForTest()
			calc.removeService("mock/" + a)
			MockManager.flushPendingForTest()
			MockManager.setValue(a + "/Ac/L1/Power", 999)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(l1), 100)
			compare(MockManager.value(l2), 200)
			compare(MockManager.value(l1Current), 5)
			compare(MockManager.value(l2Current), 6)
			compare(MockManager.value(phases), 2)
		} finally {
			calc.destroy()
			MockManager.removeValue(target)
			MockManager.removeValue("mock/" + a)
			MockManager.removeValue("mock/" + b)
		}
	}

	function test_consumption_equalResultKeepsQueuedUpdate() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.equalcons"
		const a = "mock/com.victronenergy.inverter.mockworker.equalA"
		const b = "mock/com.victronenergy.inverter.mockworker.equalB"
		const l1 = system + "/Ac/Consumption/L1/Current"
		const l2 = system + "/Ac/Consumption/L2/Current"
		const l2Power = system + "/Ac/Consumption/L2/Power"
		const phases = system + "/Ac/Consumption/NumberOfPhases"
		MockManager.setValue(a + "/Ac/Out/L1/I", 0)
		MockManager.setValue(a + "/Ac/Out/L1/P", 0)
		MockManager.setValue(b + "/Ac/Out/L1/I", 4)
		MockManager.setValue(b + "/Ac/Out/L1/P", 40)

		const calc = consumptionComponent.createObject(root, { systemUidPrefix: system })
		verify(calc)
		try {
			calc.addService(a, "inverter", 0)
			calc.addService(b, "inverter", 1)
			waitForValue(l1, 4)
			waitForValue(phases, 1)
			MockManager.finishAppliesForTest()

			MockManager.setValue(b + "/Ac/Out/L1/I", 8)
			MockManager.setValue(b + "/Ac/Out/L1/P", 80)
			MockManager.setValue(b + "/Ac/Out/L2/I", 3)
			MockManager.setValue(b + "/Ac/Out/L2/P", 30)
			MockManager.setValue(a + "/Ac/Out/L2/I", 0)
			MockManager.setValue(a + "/Ac/Out/L2/P", 0)
			MockManager.flushPendingForTest()
			calc.removeService(a)
			MockManager.flushPendingForTest()
			MockManager.setValue(a + "/Ac/Out/L1/I", 99)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(l1), 8)
			compare(MockManager.value(l2), 3)
			compare(MockManager.value(l2Power), 30)
			compare(MockManager.value(phases), 2)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(a)
			MockManager.removeValue(b)
		}
	}

	// Turning auto-max off drops the gauge write, not the consumption values
	// still waiting. A later gauge write must not cancel those values.
	function test_gaugesAutoMaxOff_manualWriteKeepsQueuedConsumption() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.automaxequal"
		const gauges = "mock/com.victronenergy.settings.mockworker.automaxequal/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.automaxequal"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const l1 = system + "/Ac/Consumption/L1/Current"
		const l2 = system + "/Ac/Consumption/L2/Current"
		const phases = system + "/Ac/Consumption/NumberOfPhases"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(l1, 4)
			waitForValue(gauge, 4)
			waitForValue(phases, 1)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter + "/Ac/Out/L1/I", 20)
			MockManager.setValue(inverter + "/Ac/Out/L1/P", 200)
			MockManager.setValue(inverter + "/Ac/Out/L2/I", 7)
			MockManager.setValue(inverter + "/Ac/Out/L2/P", 70)
			MockManager.flushPendingForTest()
			calc.gaugesAutoMax = false
			MockManager.flushPendingForTest()
			MockManager.setValue(gauge, 100)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(l1), 20)
			compare(MockManager.value(l2), 7)
			compare(MockManager.value(phases), 2)
			compare(MockManager.value(gauge), 100)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(inverter)
		}
	}

	// An unchanged gauge maximum must move to the new calculation while
	// auto-max stays on. Do not wait between the flush and the write: a wait
	// would drain the queue.
	function test_consumption_unchangedGaugeKeepsQueuedUpdate() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.gaugeequal"
		const gauges = "mock/com.victronenergy.settings.mockworker.gaugeequal/Settings/Gui/Gauges"
		const a = "mock/com.victronenergy.inverter.mockworker.gaugeequalA"
		const b = "mock/com.victronenergy.inverter.mockworker.gaugeequalB"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const l1 = system + "/Ac/Consumption/L1/Current"
		const l2 = system + "/Ac/Consumption/L2/Current"
		MockManager.setValue(a + "/Ac/Out/L1/I", 0)
		MockManager.setValue(a + "/Ac/Out/L1/P", 0)
		MockManager.setValue(b + "/Ac/Out/L1/I", 4)
		MockManager.setValue(b + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(a, "inverter", 0)
			calc.addService(b, "inverter", 0)
			waitForValue(l1, 4)
			waitForValue(gauge, 4)
			MockManager.finishAppliesForTest()

			// A still contributes zero, so removing A does not change the total
			// or the gauge maximum. Both stay queued until the write below.
			MockManager.setValue(b + "/Ac/Out/L1/I", 8)
			MockManager.setValue(b + "/Ac/Out/L1/P", 80)
			MockManager.setValue(b + "/Ac/Out/L2/I", 3)
			MockManager.setValue(b + "/Ac/Out/L2/P", 30)
			MockManager.setValue(a + "/Ac/Out/L2/I", 0)
			MockManager.setValue(a + "/Ac/Out/L2/P", 0)
			MockManager.flushPendingForTest()
			calc.removeService(a)
			MockManager.flushPendingForTest()
			MockManager.setValue(a + "/Ac/Out/L1/I", 99)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(l1), 8)
			compare(MockManager.value(l2), 3)
			compare(MockManager.value(gauge), 8)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(a)
			MockManager.removeValue(b)
		}
	}

	// The gauge maximum is a real input. Writing it must still drop a total
	// that was calculated from it. Do not wait: the write also schedules a
	// new calculation.
	function test_consumption_gaugeFloorWriteDropsQueuedTotal() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.gaugefloor"
		const gauges = "mock/com.victronenergy.settings.mockworker.gaugefloor/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.gaugefloor"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const consumption = system + "/Ac/Consumption/L1/Current"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 10)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(consumption, 4)
			compare(MockManager.value(gauge), 10)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter + "/Ac/Out/L1/I", 6)
			MockManager.flushPendingForTest()
			MockManager.setValue(gauge, 100)
			MockManager.finishAppliesForTest()
			compare(MockManager.value(consumption), 4)
			compare(MockManager.value(gauge), 100)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(inverter)
		}
	}

	// Changing the gauge prefix must drop a maximum still waiting for the old
	// prefix, and must not drop the consumption update from the same calculation.
	function test_gaugesPrefixChange_dropsQueuedGauge() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.gaugeprefix"
		const gauges = "mock/com.victronenergy.settings.mockworker.gaugeprefix/Settings/Gui/Gauges"
		const nextGauges = "mock/com.victronenergy.settings.mockworker.gaugeprefix2/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.gaugeprefix"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const nextGauge = nextGauges + "/Ac/AcIn1/Consumption/Current/Max"
		const consumption = system + "/Ac/Consumption/L1/Current"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(consumption, 4)
			waitForValue(gauge, 4)
			MockManager.finishAppliesForTest()

			MockManager.setValue(inverter + "/Ac/Out/L1/I", 20)
			MockManager.flushPendingForTest()
			calc.gaugesUidPrefix = nextGauges
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(consumption), 20)
			compare(MockManager.value(gauge), 4)
			compare(MockManager.value(nextGauge), 20)
		} finally {
			calc.destroy()
			MockManager.removeValue(system)
			MockManager.removeValue(gauges)
			MockManager.removeValue(nextGauges)
			MockManager.removeValue(inverter)
		}
	}

	// The paused-system return also stores the new prefix. A maximum already
	// waiting for the old prefix must be dropped there too.
	function test_gaugesPrefixChange_dropsQueuedGaugeWhenSystemPaused() {
		compare(MockManager.timersActive, false)
		const system = "mock/com.victronenergy.system.mockworker.gaugepauseprefix"
		const gauges = "mock/com.victronenergy.settings.mockworker.gaugepauseprefix/Settings/Gui/Gauges"
		const nextGauges = "mock/com.victronenergy.settings.mockworker.gaugepauseprefix2/Settings/Gui/Gauges"
		const inverter = "mock/com.victronenergy.inverter.mockworker.gaugepauseprefix"
		const gauge = gauges + "/Ac/AcIn1/Consumption/Current/Max"
		const nextGauge = nextGauges + "/Ac/AcIn1/Consumption/Current/Max"
		const filler = "mock/com.victronenergy.test.mockworker/GaugePausePrefix/Filler"
		MockManager.setValue(inverter + "/Ac/Out/L1/I", 4)
		MockManager.setValue(inverter + "/Ac/Out/L1/P", 40)
		MockManager.setValue(gauge, 1)
		MockManager.setValue(filler, 0)
		const calc = consumptionComponent.createObject(root, {
			systemUidPrefix: system,
			gaugesAutoMax: true,
			gaugesUidPrefix: gauges
		})
		verify(calc)
		try {
			calc.addService(inverter, "inverter", 0)
			waitForValue(gauge, 4)
			MockManager.finishAppliesForTest()

			MockManager.removeValue(system)
			// A filler is applied immediately, so the gauge stays queued.
			MockManager.applyWorkerUpdatesForTest([
				{ uid: filler, value: 1 },
				{ uid: gauge, value: 99 }
			])
			compare(MockManager.value(gauge), 4)
			calc.gaugesUidPrefix = nextGauges
			MockManager.finishAppliesForTest()
			compare(MockManager.value(gauge), 4)
			verify(!MockManager.hasItemForTest(nextGauge))
		} finally {
			calc.destroy()
			// The body already removed the system. The new prefix is never created.
			if (MockManager.hasItemForTest(system)) {
				MockManager.removeValue(system)
			}
			MockManager.removeValue(gauges)
			if (MockManager.hasItemForTest(nextGauges)) {
				MockManager.removeValue(nextGauges)
			}
			MockManager.removeValue(inverter)
			MockManager.removeValue(filler)
		}
	}

	// Retargeting must not recreate a leaf that was removed before the change.
	function test_phaseSum_retargetSkipsRemovedLeaf() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker.retarget"
		const target = "mock/com.victronenergy.system.mockworker/Ac/Retarget"
		const next = "mock/com.victronenergy.system.mockworker/Ac/RetargetNext"
		const removed = target + "/L1/Power"
		MockManager.setValue(pv + "/Ac/L1/Power", 100)
		MockManager.setValue(pv + "/Ac/L2/Power", 40)
		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		try {
			calc.addService("mock/" + pv)
			waitForValue(removed, 100)
			waitForValue(target + "/L2/Power", 40)
			MockManager.finishAppliesForTest()

			MockManager.removeValue(removed)
			verify(!MockManager.hasItemForTest(removed))
			calc.targetPrefix = next
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			verify(!MockManager.hasItemForTest(removed))
			verify(isInvalid(MockManager.value(target + "/L2/Power")))
			compare(MockManager.value(next + "/L1/Power"), 100)
			compare(MockManager.value(next + "/L2/Power"), 40)
		} finally {
			calc.destroy()
			MockManager.removeValue(target)
			MockManager.removeValue(next)
			MockManager.removeValue("mock/" + pv)
		}
	}

	// A later animator in the same turn replaces the value. The earlier notify
	// must not report the value that was never applied.
	function test_notify_dropsReplacedUnflushedValue() {
		compare(MockManager.timersActive, false)
		const uid = "mock/com.victronenergy.test.mockworker/Notify/Unflushed"
		MockManager.setValue(uid, 1)
		const first = notifyCountComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 5,
			maximumValue: 5
		})
		const second = notifyCountComponent.createObject(root, {
			valueUid: uid,
			active: true,
			minimumValue: 8,
			maximumValue: 8
		})
		verify(first)
		verify(second)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(uid), 8)
			compare(first.updates, 0)
			compare(first.totals, 0)
			compare(second.updates, 1)
			compare(second.totals, 1)
			compare(second.mismatches, 0)
		} finally {
			first.destroy()
			second.destroy()
			MockManager.removeValue(uid)
		}
	}

	// The first notify is already queued, waiting on a value that has not been
	// applied. A later animator replaces that value. The old notify must not run.
	function test_notify_dropsReplacedQueuedValue() {
		compare(MockManager.timersActive, false)
		const filler = "mock/com.victronenergy.test.mockworker/Notify/Queued/Filler"
		const target = "mock/com.victronenergy.test.mockworker/Notify/Queued/Target"
		const divisor = "mock/com.victronenergy.test.mockworker/Notify/Queued/Divisor"
		MockManager.setValue(filler, 1)
		MockManager.setValue(target, 1)
		MockManager.setValue(divisor, 2)
		const first = notifyCountComponent.createObject(root, {
			valueUid: filler,
			active: true,
			minimumValue: 10,
			maximumValue: 10,
			derivedTargetUids: [target],
			derivedDivisorUids: [divisor]
		})
		verify(first)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(filler), 10)
			compare(MockManager.value(target), 1)
			first.active = false

			const second = notifyCountComponent.createObject(root, {
				valueUid: target,
				active: true,
				minimumValue: 9,
				maximumValue: 9
			})
			verify(second)
			try {
				MockManager.tickAnimatorsForTest()
				MockManager.flushPendingForTest()
				MockManager.finishAppliesForTest()
				compare(MockManager.value(target), 9)
				compare(first.updates, 0)
				compare(first.totals, 0)
				compare(second.updates, 1)
				compare(second.totals, 1)
				compare(second.mismatches, 0)
			} finally {
				second.destroy()
			}
		} finally {
			first.destroy()
			MockManager.removeValue(filler)
			MockManager.removeValue(target)
			MockManager.removeValue(divisor)
		}
	}

	// The tick is staged before the flush. A write in that gap drops it, so the
	// flush must not apply the staged value.
	function test_tick_isQueuedBeforeFlush() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/SingleQueue/BeforeFlush"
		MockManager.setValue(power, 10)
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000
		})
		verify(randomizer)
		try {
			MockManager.finishAppliesForTest()
			MockManager.tickAnimatorsForTest()
			verify(MockManager.queuedTickCountForTest() >= 1)
			compare(MockManager.value(power), 10)
			MockManager.setValue(power, 115)
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 115)
			compare(MockManager.queuedTickCountForTest(), 0)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(power)
		}
	}

	// The phase sum runs after the animator tick is staged, in the same flush.
	// It must read 5000, not the producer value from before the tick.
	function test_phaseSum_readsStagedAnimatorValue() {
		compare(MockManager.timersActive, false)
		const pv = "com.victronenergy.pvinverter.mockworker.staged"
		const source = "mock/" + pv + "/Ac/L1/Power"
		const target = "mock/com.victronenergy.system.mockworker/Ac/Staged"
		MockManager.setValue(source, 10)
		const calc = phaseSumComponent.createObject(root, {
			targetPrefix: target,
			sourcePhasePattern: "/Ac/L%1/Power"
		})
		verify(calc)
		try {
			calc.addService("mock/" + pv)
			waitForValue(target + "/L1/Power", 10)
			MockManager.finishAppliesForTest()
			const randomizer = randomizerComponent.createObject(root, {
				valueUid: source,
				active: true,
				minimumValue: 5000
			})
			verify(randomizer)
			try {
				MockManager.tickAnimatorsForTest()
				compare(MockManager.value(source), 10)
				MockManager.flushPendingForTest()
				MockManager.finishAppliesForTest()
				compare(MockManager.value(source), 5000)
				compare(MockManager.value(target + "/L1/Power"), 5000)
			} finally {
				randomizer.destroy()
			}
		} finally {
			calc.destroy()
			MockManager.removeValue(source)
			MockManager.removeValue(target)
		}
	}

	// One flush applies one staged uid. The other outputs of the tick wait.
	function test_flush_appliesOneStagedValue() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/SingleQueue/OneApply"
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
		try {
			MockManager.finishAppliesForTest()
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			let applied = 0
			if (MockManager.value(power) === 5000) {
				applied++
			}
			if (MockManager.value(current) === 20) {
				applied++
			}
			if (MockManager.value(total) === 5000) {
				applied++
			}
			compare(applied, 1)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(power)
		}
	}

	// The first output has been applied. Another output of that tick is still
	// queued. A later animator writes a different value for the applied output.
	// The old notify must not report the value that is no longer stored.
	function test_notify_dropsReplacedAppliedValue() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/Notify/Applied/Power"
		const current = "mock/com.victronenergy.test.mockworker/Notify/Applied/Current"
		const voltage = "mock/com.victronenergy.test.mockworker/Notify/Applied/Voltage"
		MockManager.setValue(power, 1)
		MockManager.setValue(current, 1)
		MockManager.setValue(voltage, 2)
		const first = notifyCountComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5,
			maximumValue: 5,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(first)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(power), 5)
			compare(MockManager.value(current), 1)
			first.active = false

			const second = notifyCountComponent.createObject(root, {
				valueUid: power,
				active: true,
				minimumValue: 8,
				maximumValue: 8
			})
			verify(second)
			try {
				MockManager.tickAnimatorsForTest()
				MockManager.flushPendingForTest()
				MockManager.finishAppliesForTest()
				compare(MockManager.value(power), 8)
				compare(first.updates, 0)
				compare(first.totals, 0)
				compare(first.mismatches, 0)
				compare(second.updates, 1)
				compare(second.totals, 1)
				compare(second.mismatches, 0)
			} finally {
				second.destroy()
			}
		} finally {
			first.destroy()
			MockManager.removeValue(power)
			MockManager.removeValue(current)
			MockManager.removeValue(voltage)
		}
	}

	// The same stored value must not drop a notify that is still waiting on
	// another output. Only a different value does.
	function test_notify_keepsAppliedValueWhenReplacementMatches() {
		compare(MockManager.timersActive, false)
		const power = "mock/com.victronenergy.test.mockworker/Notify/SameApplied/Power"
		const current = "mock/com.victronenergy.test.mockworker/Notify/SameApplied/Current"
		const voltage = "mock/com.victronenergy.test.mockworker/Notify/SameApplied/Voltage"
		MockManager.setValue(power, 1)
		MockManager.setValue(current, 1)
		MockManager.setValue(voltage, 2)
		const first = notifyCountComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5,
			maximumValue: 5,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(first)
		try {
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			compare(MockManager.value(power), 5)
			compare(MockManager.value(current), 1)
			first.active = false

			const second = notifyCountComponent.createObject(root, {
				valueUid: power,
				active: true,
				minimumValue: 5,
				maximumValue: 5
			})
			verify(second)
			try {
				MockManager.tickAnimatorsForTest()
				MockManager.flushPendingForTest()
				MockManager.finishAppliesForTest()
				compare(MockManager.value(power), 5)
				compare(first.updates, 1)
				compare(first.totals, 1)
				compare(first.mismatches, 0)
				compare(second.updates, 1)
				compare(second.mismatches, 0)
			} finally {
				second.destroy()
			}
		} finally {
			first.destroy()
			MockManager.removeValue(power)
			MockManager.removeValue(current)
			MockManager.removeValue(voltage)
		}
	}

	Component {
		id: optionalDcComponent
		MockDataRandomizer {
			interval: 30
			deltaLow: 0
			deltaHigh: 0
			property string voltageUid
			property string temperatureUid
			property string inPowerUid
			property string inVoltageUid
			property string inCurrentUid
			VeQuickItem { uid: voltageUid }
			VeQuickItem { uid: temperatureUid }
			VeQuickItem { uid: inPowerUid }
			VeQuickItem { uid: inVoltageUid }
			VeQuickItem { uid: inCurrentUid }
		}
	}

	// Optional paths that were never created must not keep the animator paused
	// after the paths that did exist are written back.
	function test_removeValue_resumesWhenOptionalPathMissing() {
		compare(MockManager.timersActive, false)
		const service = "mock/com.victronenergy.battery.mockworker_optional"
		const voltage = service + "/Dc/0/Voltage"
		const temperature = service + "/Dc/0/Temperature"
		const missingPower = service + "/Dc/In/P"
		const missingVoltage = service + "/Dc/In/V"
		const missingCurrent = service + "/Dc/In/I"
		MockManager.setValue(voltage, 50)
		MockManager.setValue(temperature, 20)
		const randomizer = optionalDcComponent.createObject(root, {
			voltageUid: voltage,
			temperatureUid: temperature,
			inPowerUid: missingPower,
			inVoltageUid: missingVoltage,
			inCurrentUid: missingCurrent,
			active: true,
			minimumValue: 60,
			maximumValue: 60
		})
		verify(randomizer)
		try {
			// A binding can create an empty item. That is not a value, and it
			// must not be required when the paths that had values are restored.
			verify(isInvalid(MockManager.value(missingPower)))
			verify(isInvalid(MockManager.value(missingVoltage)))
			verify(isInvalid(MockManager.value(missingCurrent)))

			MockManager.removeValue(service + "/Dc")
			verify(isInvalid(MockManager.value(voltage)))
			verify(isInvalid(MockManager.value(temperature)))

			MockManager.setValue(voltage, 50)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(voltage), 50)
			verify(isInvalid(MockManager.value(temperature)))

			MockManager.setValue(temperature, 20)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(voltage), 60)
			compare(MockManager.value(temperature), 60)
			verify(!MockManager.hasItemForTest(missingPower))
			verify(!MockManager.hasItemForTest(missingVoltage))
			verify(!MockManager.hasItemForTest(missingCurrent))
		} finally {
			randomizer.destroy()
			MockManager.removeValue(service)
		}
	}

	// The derived current has no value yet, but a tick has queued its first
	// write. Removing it must pause the animator. The next tick must not
	// create it. Restoring it resumes the writer.
	function test_removeValue_pausesQueuedDerivedDestination() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/QueuedDerived"
		const removed = "mock/com.victronenergy.tank.mockworker_queued_derived"
		const power = keep + "/Power"
		const voltage = keep + "/Voltage"
		const current = removed + "/Current"
		MockManager.setValue(power, 100)
		MockManager.setValue(voltage, 250)
		verify(isInvalid(MockManager.value(current)))
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			maximumValue: 5000,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.tickAnimatorsForTest()
			compare(MockManager.value(power), 100)
			verify(isInvalid(MockManager.value(current)))
			verify(!MockManager.hasItemForTest(current))

			MockManager.removeValue(current)
			MockManager.setValue(power, 80)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 80)
			verify(isInvalid(MockManager.value(current)))
			verify(!MockManager.hasItemForTest(current))

			MockManager.setValue(current, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 5000)
			compare(MockManager.value(current), 20)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
			MockManager.removeValue(keep)
		}
	}

	// A total is generated the same way. A queued first write must stay gone
	// until that total is written back.
	function test_removeValue_pausesQueuedTotal() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/QueuedTotal"
		const removed = "mock/com.victronenergy.tank.mockworker_queued_total"
		const power = keep + "/Power"
		const total = removed + "/Total"
		MockManager.setValue(power, 100)
		verify(isInvalid(MockManager.value(total)))
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			maximumValue: 5000,
			totalTargetUid: total
		})
		verify(randomizer)
		try {
			MockManager.tickAnimatorsForTest()
			compare(MockManager.value(power), 100)
			verify(isInvalid(MockManager.value(total)))

			MockManager.removeValue(total)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 100)
			verify(isInvalid(MockManager.value(total)))
			verify(!MockManager.hasItemForTest(total))

			MockManager.setValue(total, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 5000)
			compare(MockManager.value(total), 5000)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
			MockManager.removeValue(keep)
		}
	}

	// A derived destination that was never queued is not required. Removing it
	// must not pause the animator, and the next tick creates it.
	function test_removeValue_createsUnqueuedDerived() {
		compare(MockManager.timersActive, false)
		const keep = "mock/com.victronenergy.test.mockworker/UnqueuedDerived"
		const removed = "mock/com.victronenergy.tank.mockworker_unqueued_derived"
		const power = keep + "/Power"
		const voltage = keep + "/Voltage"
		const current = removed + "/Current"
		MockManager.setValue(power, 100)
		MockManager.setValue(voltage, 250)
		verify(isInvalid(MockManager.value(current)))
		const randomizer = randomizerComponent.createObject(root, {
			valueUid: power,
			active: true,
			minimumValue: 5000,
			maximumValue: 5000,
			derivedTargetUids: [current],
			derivedDivisorUids: [voltage]
		})
		verify(randomizer)
		try {
			MockManager.removeValue(current)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(power), 5000)
			compare(MockManager.value(current), 20)
		} finally {
			randomizer.destroy()
			MockManager.removeValue(removed)
			MockManager.removeValue(keep)
		}
	}

	// A toggler writes even when its path is missing. A queued first write
	// must stay gone until that path is written back.
	function test_removeValue_pausesQueuedToggler() {
		compare(MockManager.timersActive, false)
		const removed = "mock/com.victronenergy.tank.mockworker_queued_toggler"
		const status = removed + "/Status"
		verify(isInvalid(MockManager.value(status)))
		const toggler = togglerComponent.createObject(root, {
			valueUid: status,
			active: true,
			repeat: true,
			valueA: 1,
			valueB: 2
		})
		verify(toggler)
		try {
			MockManager.tickAnimatorsForTest()
			verify(isInvalid(MockManager.value(status)))

			MockManager.removeValue(status)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			verify(isInvalid(MockManager.value(status)))
			verify(!MockManager.hasItemForTest(status))

			MockManager.setValue(status, 1)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(status), 2)
		} finally {
			toggler.destroy()
			MockManager.removeValue(removed)
		}
	}

	// A toggler path that was never queued is not required. Removing the empty
	// item created by its binding must not pause it, and the next tick creates
	// the value.
	function test_removeValue_createsUnqueuedToggler() {
		compare(MockManager.timersActive, false)
		const removed = "mock/com.victronenergy.tank.mockworker_unqueued_toggler"
		const status = removed + "/Status"
		const toggler = togglerComponent.createObject(root, {
			valueUid: status,
			active: true,
			repeat: true,
			valueA: 1,
			valueB: 2
		})
		verify(toggler)
		try {
			verify(isInvalid(MockManager.value(status)))
			MockManager.removeValue(status)
			MockManager.tickAnimatorsForTest()
			MockManager.flushPendingForTest()
			MockManager.finishAppliesForTest()
			compare(MockManager.value(status), 1)
		} finally {
			toggler.destroy()
			MockManager.removeValue(removed)
		}
	}
}
