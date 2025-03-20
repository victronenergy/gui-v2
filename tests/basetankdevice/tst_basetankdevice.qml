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
				// level=NaN, so calculate it (remaining / capacity*100)
				tag: "level=NaN",
				input: { level: NaN, capacity: 160, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				// capacity=NaN, so calculate it (remaining / level/100)
				tag: "capacity=NaN",
				input: { level: 75, capacity: NaN, remaining: 120 },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				// remaining=NaN, so calculate it (capacity * level/100)
				tag: "remaining=NaN",
				input: { level: 75, capacity: 160, remaining: NaN },
				expected: { level: 75, capacity: 160, remaining: 120 },
			},
			{
				// level=NaN but cannot be calculated as capacity=0.
				tag: "level=NaN, capacity=0",
				input: { level: NaN, capacity: 0, remaining: 120 },
				expected: { level: NaN, capacity: 0, remaining: 120 },
			},
			{
				// capacity=NaN but capacity cannot be calculated as level=0.
				tag: "capacity=NaN, level=0",
				input: { level: 0, capacity: NaN, remaining: 120 },
				expected: { level: 0, capacity: NaN, remaining: 120 },
			},
			{
				// remaining=NaN and can be calculated even if level=0.
				tag: "remaining=NaN, level=0",
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
