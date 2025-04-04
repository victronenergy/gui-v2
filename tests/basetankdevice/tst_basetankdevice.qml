/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick
import Victron.VenusOS

TestCase {
	id: root
	name: "BaseTankDeviceTest"

	Component {
		id: tankComponent

		BaseTankDevice {}
	}

	SignalSpy {
		id: spyLevelChanged
		signalName: "levelChanged"
	}

	SignalSpy {
		id: spyCapacityChanged
		signalName: "capacityChanged"
	}

	SignalSpy {
		id: spyRemainingChanged
		signalName: "remainingChanged"
	}

	function init() {
		spyLevelChanged.target = null
		spyCapacityChanged.target = null
		spyRemainingChanged.target = null
		spyLevelChanged.clear()
		spyCapacityChanged.clear()
		spyRemainingChanged.clear()
	}

	function test_measurements_data() {
		return [
			{
				tag: "all-valid",
				input: { level: 75, capacity: 160, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
				spyCounts: { level: 1, capacity: 1, remaining: 1 },
			},
			{
				// level=NaN, so calculate it (remaining / capacity*100)
				tag: "level=NaN",
				input: { level: NaN, capacity: 160, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
				spyCounts: { level: 1, capacity: 1, remaining: 1 },
			},
			{
				// capacity=NaN, so calculate it (remaining / level/100)
				tag: "capacity=NaN",
				input: { level: 75, capacity: NaN, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
				spyCounts: { level: 1, capacity: 1, remaining: 1 },
			},
			{
				// remaining=NaN, so calculate it (capacity * level/100)
				tag: "remaining=NaN",
				input: { level: 75, capacity: 160, remaining: NaN },
				expected: { level: 75, capacity: 160, remaining: 120 },
				spyCounts: { level: 1, capacity: 1, remaining: 1 },
			},
			{
				// level=NaN but cannot be calculated as capacity=0.
				tag: "level=NaN, capacity=0",
				input: { level: NaN, capacity: 0, remaining: 120 },
				expected: { level: NaN, capacity: 0, remaining: 120 },
				spyCounts: { level: 0, capacity: 1, remaining: 1 },
			},
			{
				// capacity=NaN but capacity cannot be calculated as level=0.
				tag: "capacity=NaN, level=0",
				input: { level: 0, capacity: NaN, remaining: 120 },
				expected: { level: 0, capacity: NaN, remaining: 120 },
				spyCounts: { level: 1, capacity: 0, remaining: 1 },
			},
			{
				// remaining=NaN and can be calculated even if level=0.
				tag: "remaining=NaN, level=0",
				input: { level: 0, capacity: 160, remaining: NaN },
				expected: { level: 0, capacity: 160, remaining: 0 },
				spyCounts: { level: 1, capacity: 1, remaining: 1 },
			},
		]
	}

	function test_measurements(data) {
		const tank = tankComponent.createObject(root)
		spyLevelChanged.target = tank
		spyCapacityChanged.target = tank
		spyRemainingChanged.target = tank

		verify(isNaN(tank.level))
		verify(isNaN(tank.capacity))
		verify(isNaN(tank.remaining))

		tank.level = data.input.level
		tank.capacity = data.input.capacity
		tank.remaining = data.input.remaining

		compare(tank.level, data.expected.level)
		compare(tank.capacity, data.expected.capacity)
		compare(tank.remaining, data.expected.remaining)

		compare(spyLevelChanged.count, data.spyCounts.level)
		compare(spyCapacityChanged.count, data.spyCounts.capacity)
		compare(spyRemainingChanged.count, data.spyCounts.remaining)

		tank.destroy()
	}
}
