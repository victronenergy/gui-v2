/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick
import Victron.VenusOS

TestCase {
	id: root

	name: "BaseTankDeviceModelTest"

	property int deviceInstanceCount

	function createTank() {
		const instance = deviceInstanceCount++
		const serviceUid = "mock/com.victronenergy.tank." + instance
		const name = "Tank " + instance
		return tankComponent.createObject(root, {
			serviceUid: serviceUid,
			deviceInstance: instance,
			name: name,
			productName: name,
			objectName: name
		})
	}

	Component {
		id: tankComponent

		BaseTankDevice {}
	}

	BaseTankDeviceModel {
		id: tankModel
	}

	function showModel() {
		console.log("Model:")
		for (let i = 0; i < tankModel.count; ++i) {
			console.log("\t", tankModel.tankAt(i))
		}
	}

	function cleanup() {
		tankModel.deleteAllAndClear()
	}

	function test_averageLevel_data() {
		return [
			{
				// Capacity and remaining provided for all tanks, so the average level is the
				// combined level.
				// Crude average level = 25+75/2 = 50%, but actual combined average = 15.5/22 = 70%
				tanks: [
					{ level: 25, capacity: 2, remaining: 0.5 },
					{ level: 75, capacity: 20, remaining: 15 },
				],
				averageLevel: 70.4545454,
			},
			{
				// No capacity and remaining, so calculate a crude average level.
				tanks: [
					{ level: 25, capacity: NaN, remaining: NaN },
					{ level: 75, capacity: NaN, remaining: NaN },
				],
				averageLevel: 50,
			},
		]
	}

	function test_averageLevel(data) {
		// Add tanks with the values already set.
		let tankData
		for (tankData of data.tanks) {
			const tank = createTank()
			tank.level = tankData.level
			tank.capacity = tankData.capacity
			tank.remaining = tankData.remaining
			tankModel.addDevice(tank)
		}
		tryCompare(tankModel, "averageLevel", data.averageLevel, 1)
		tankModel.deleteAllAndClear()

		// Update tank values after they have been added to the model.
		for (tankData of data.tanks) {
			const tank = createTank()
			tankModel.addDevice(tank)
			tank.level = tankData.level
			tank.capacity = tankData.capacity
			tank.remaining = tankData.remaining
		}
		tryCompare(tankModel, "averageLevel", data.averageLevel, 1)
		tankModel.deleteAllAndClear()
	}

	function data_totals() {
		return [
			{
				values: [ 0 ],
				total: 0,
			},
			{
				values: [ NaN ],
				total: NaN,
			},
			{
				values: [ NaN, 313 ],
				total: 313,
			},
			{
				values: [ 2, 0, 15, 1003.534 ],
				total: 1020.534,
			},
		]
	}

	function test_totalCapacity_data() {
		return data_totals()
	}

	function test_totalCapacity(data) {
		// Add tanks with the values already set.
		let capacity
		for (capacity of data.values) {
			const tank = createTank()
			tank.capacity = capacity
			tankModel.addDevice(tank)
		}
		tryCompare(tankModel, "totalCapacity", data.total, 1)
		tankModel.deleteAllAndClear()

		// Update tank values after they have been added to the model.
		for (capacity of data.values) {
			const tank = createTank()
			tankModel.addDevice(tank)
			tank.capacity = capacity
		}
		tryCompare(tankModel, "totalCapacity", data.total, 1)
		tankModel.deleteAllAndClear()
	}

	function test_totalRemaining_data() {
		return data_totals()
	}

	function test_totalRemaining(data) {
		// Add tanks with the values already set.
		let remaining
		for (remaining of data.values) {
			const tank = createTank()
			tank.remaining = remaining
			tankModel.addDevice(tank)
		}
		tryCompare(tankModel, "totalRemaining", data.total, 1)
		tankModel.deleteAllAndClear()

		// Update tank values after they have been added to the model.
		for (remaining of data.values) {
			const tank = createTank()
			tankModel.addDevice(tank)
			tank.remaining = remaining
		}
		tryCompare(tankModel, "totalRemaining", data.total, 1)
		tankModel.deleteAllAndClear()
	}
}
