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

	function test_measurements_data() {
		return [
			{
				tag: "all-valid",
				input: { level: 75, capacity: 160, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				tag: "level=NaN",
				input: { level: NaN, capacity: 160, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				tag: "capacity=NaN",
				input: { level: 75, capacity: NaN, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				tag: "remaining=NaN",
				input: { level: 75, capacity: 160, remaining: NaN },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				tag: "level=NaN, capacity=0", // level cannot be calculated
				input: { level: NaN, capacity: 0, remaining: 120 },
				expected: { level: NaN, capacity: 0, remaining: 120 },
			},
			{
				tag: "capacity=NaN, level=0", // capacity cannot be calculated
				input: { level: 0, capacity: NaN, remaining: 120 },
				expected: { level: 0, capacity: NaN, remaining: 120 },
			},
			{
				tag: "remaining=NaN, level=0",  // remaining can still be calculated
				input: { level: 0, capacity: 160, remaining: NaN },
				expected: { level: 0, capacity: 160, remaining: 0 },
			},
		]
	}

	function test_measurements(data) {
		const tank = tankComponent.createObject(root)

		verify(isNaN(tank.level))
		verify(isNaN(tank.capacity))
		verify(isNaN(tank.remaining))

		tank.level = data.input.level
		tank.capacity = data.input.capacity
		tank.remaining = data.input.remaining

		compare(tank.level, data.expected.level)
		compare(tank.capacity, data.expected.capacity)
		compare(tank.remaining, data.expected.remaining)

		tank.destroy()
	}
}
