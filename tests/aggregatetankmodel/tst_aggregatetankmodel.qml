/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick
import Victron.VenusOS

TestCase {
	id: root

	name: "AggregateTankModelTest"

	property int deviceInstanceCount

	function createTank(fluidType, name) {
		return tankComponent.createObject(root, {
			deviceInstance: deviceInstanceCount++,
			type: fluidType,
			name: name,
			name: name,
		})
	}

	Component {
		id: tankComponent

		BaseTankDevice {
			serviceUid: "mock/com.victronenergy.tank." + deviceInstance
			objectName: name
		}
	}

	BaseTankDeviceModel {
		id: fuelTanks
		type: VenusOS.Tank_Type_Fuel
		modelId: "fuel"
		objectName: modelId
	}
	BaseTankDeviceModel {
		id: freshWaterTanks
		type: VenusOS.Tank_Type_FreshWater
		modelId: "fresh"
		objectName: modelId
	}
	BaseTankDeviceModel {
		id: wasteWaterTanks
		type: VenusOS.Tank_Type_WasteWater
		modelId: "waste"
		objectName: modelId
	}
	BaseTankDeviceModel {
		id: oilTanks
		type: VenusOS.Tank_Type_Oil
		modelId: "oil"
		objectName: modelId
	}

	AggregateTankModel {
		id: allTanks
	}

	SignalSpy {
		id: spyCountChanged
		target: allTanks
		signalName: "countChanged"
	}
	SignalSpy {
		id: spyRowsInserted
		target: allTanks
		signalName: "rowsInserted"
	}
	SignalSpy {
		id: spyRowsRemoved
		target: allTanks
		signalName: "rowsRemoved"
	}
	SignalSpy {
		id: spyDataChanged
		target: allTanks
		signalName: "dataChanged"
	}
	SignalSpy {
		id: spyMoved
		target: allTanks
		signalName: "rowsMoved"
	}

	function showModel() {
		console.log("Model:")
		for (let i = 0; i < allTanks.count; ++i) {
			console.log("\t", allTanks.tankAt(i), allTanks.tankModelAt(i))
		}
	}

	function cleanup() {
		allTanks.tankModels = []
		allTanks.mergeThreshold = 0
		for (const model of [fuelTanks, freshWaterTanks, wasteWaterTanks, oilTanks]) {
			model.deleteAllAndClear()
		}
		for (const spy of [spyCountChanged, spyRowsInserted, spyRowsRemoved, spyDataChanged, spyMoved]) {
			spy.clear()
		}
	}


	function test_setTankModels_data() {
		return [
			{
				tag: "No merge",
				mergeThreshold: 6,  // above tank count, so should not merge
				tanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
			},
			{
				tag: "Merge fuel tanks",
				mergeThreshold: 5,
				tanks: [
					// Only fuel tanks should be merged, as the model count is 4 after that merge,
					// which is under the threshold.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
			},
			{
				tag: "Merge fuel and oil tanks",
				mergeThreshold: 4,
				tanks: [
					// Both fuel and oil tanks should be merged to fall under the threshold.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: true, name: "" },
				],
			},
			{
				tag: "Merge all tanks",
				mergeThreshold: 3,
				tanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
				],
			},
		]
	}

	function test_setTankModels(data) {
		allTanks.mergeThreshold = data.mergeThreshold
		for (const tankInfo of data.tanks) {
			tankInfo.tankModel.addDevice(createTank(tankInfo.tankModel.type, tankInfo.name))
		}
		allTanks.tankModels = [fuelTanks, freshWaterTanks, wasteWaterTanks, oilTanks]
		let i

		// Test against the expectedTanks merged results
		compare(allTanks.count, data.expectedTanks.length)
		for (i = 0; i < data.expectedTanks.length; ++i) {
			compare(allTanks.tankModelAt(i), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), data.expectedTanks[i].isGroup, `row=${i}`)
		}

		// Test un-merging. If merge threshold == 0, then no tanks should be merged, and the input
		// tanks should match the expectedTanks tanks exactly.
		allTanks.mergeThreshold = 0
		compare(allTanks.count, data.tanks.length)
		for (i = 0; i < allTanks.count; ++i) {
			compare(allTanks.tankModelAt(i), data.tanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i).name, data.tanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole).name, data.tanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.tanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), false, `row=${i}`)
		}

		// Then set the same merge threshold again, and check the results are same as before.
		allTanks.mergeThreshold = data.mergeThreshold
		compare(allTanks.count, data.expectedTanks.length)
		for (i = 0; i < data.expectedTanks.length; ++i) {
			compare(allTanks.tankModelAt(i), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), data.expectedTanks[i].isGroup, `row=${i}`)
		}
	}

	function test_insert_data() {
		return [
			{
				// Add a tank without triggering a merge.
				tag: "Add 1 tank; no merge",
				mergeThreshold: 0,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				newTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Add a tank, trigger a merge of tanks of that type.
				tag: "1 fuel, add fuel; merge fuel",
				mergeThreshold: 2,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
				],
				newTanks: [
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// With 2 tank types, add a tank, trigger a merge of tanks of that type.
				tag: "1 fuel + 1 oil, add fuel; merge fuel",
				mergeThreshold: 3,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
				],
				newTanks: [
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// With 2 tank types, add a tank of the second type, trigger a merge of tanks of the
				// first mergeable type.
				tag: "2 fuel + 2 oil, add oil; merge fuel, insert single oil",
				mergeThreshold: 5,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				newTanks: [
					{ tankModel: oilTanks, name: "Oil 3" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 3" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 1 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// With 2 tank types, add a third tank type, trigger a merge of tanks of the first
				// mergeable type.
				tag: "2 fuel + 2 oil, add waste; merge fuel, insert waste",
				mergeThreshold: 5,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				newTanks: [
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 1 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// With one set of tanks already merged, add a tank that triggers a new merge.
				tag: "2 merged fuel + 2 oil, add waste; merge oil, insert waste",
				mergeThreshold: 4,
				initialTanks: [
					// As threshold=4, expect the fuel tanks to be merged on initial model load.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				newTanks: [
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
				],
				expectedTanks: [
					// Both fuel and oil tanks should now be merged.
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: true, name: "" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 1 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// With one set of tanks already merged, add a tank that does not trigger a merge.
				tag: "2 merged fuel + 2 oil; add waste, no merge",
				mergeThreshold: 3,
				initialTanks: [
					// As threshold=3, expect the fuel tanks to be merged on initial model load.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: oilTanks, name: "Oil 1" },
				],
				newTanks: [
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 0},
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Add a tank to a set of tanks that have already been merged.
				tag: "2 merged fuel + 2 oil, add fuel to merged group",
				mergeThreshold: 4,
				initialTanks: [
					// As threshold=4, expect the fuel tanks to be merged on initial model load.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				newTanks: [
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
				expectedSignals: [
					// No model changes expected
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Use a merge threshold that cannot be obeyed as there is only a single tank of
				// each type.
				tag: "1 fuel + 1 oil, add waste water, no merge",
				mergeThreshold: 3,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
				],
				newTanks: [
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Use a merge threshold that cannot be obeyed despite the merging of one tank type.
				tag: "1 fuel + 1 oil, add waste water; merge fuel",
				mergeThreshold: 4,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: oilTanks, name: "Oil 1" },
				],
				newTanks: [
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
				],
				expectedTanks: [
					// Even though model count is >= merge threshold, only the fuel tanks can be
					// merged so other tank types will remain as single model items.
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 1 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
		]
	}

	function test_insert(data) {
		allTanks.mergeThreshold = data.mergeThreshold
		for (const initialTank of data.initialTanks) {
			initialTank.tankModel.addDevice(createTank(initialTank.tankModel.type, initialTank.name))
		}
		allTanks.tankModels = [fuelTanks, freshWaterTanks, wasteWaterTanks, oilTanks]

		let expectedSignal
		for (expectedSignal of data.expectedSignals) {
			expectedSignal.spy.clear()
		}
		for (const newTank of data.newTanks) {
			newTank.tankModel.addDevice(createTank(newTank.tankModel.type, newTank.name))
		}

		compare(allTanks.count, data.expectedTanks.length)
		for (let i = 0; i < data.expectedTanks.length; ++i) {
			compare(allTanks.tankModelAt(i), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), data.expectedTanks[i].isGroup, `row=${i}`)
		}
		for (expectedSignal of data.expectedSignals) {
			compare(expectedSignal.spy.count, expectedSignal.count, expectedSignal.spy.signalName)
		}
	}

	function test_remove_data() {
		return [
			{
				// Remove a tank from a model that has no groups.
				tag: "Remove 1 tank, no groups",
				mergeThreshold: 5,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 },
				],
				expectedTanks: [],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 1 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Remove the first tank from a two-tank group, triggering a separation as there is
				// no longer a group.
				tag: "Remove 1st tank from two-tank group, single entry left",
				mergeThreshold: 2,
				initialTanks: [
					// These will be initially merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 }, // remove fuel 1
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 }, // row 0 changed isGroup=true to false
				]
			},
			{
				// Remove the second tank from a two-tank group, triggering a separation as there is
				// no longer a group.
				tag: "Remove 2nd tank from two-tank group, single entry left",
				mergeThreshold: 2,
				initialTanks: [
					// These will be initially merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 1 }, // remove fuel 2
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 }, // row 0 changed isGroup=true to false
				]
			},
			{
				// Remove a tank from a group with > 2 tanks, triggering a separation as it that
				// would still fall under the merge threshold.
				tag: "Remove 1 tank from group, group breaks up",
				mergeThreshold: 3,
				initialTanks: [
					// These will be initially merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 }, // remove fuel 1
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 3" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 }, // fuel 3 added
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 }, // row 0 changed isGroup=true to false
				]
			},
			{
				// Remove a tank from a group, where model has other tanks, triggering a separation.
				tag: "Remove 1 tank from group, other tanks present, group separates",
				mergeThreshold: 6,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
					{ tankModel: freshWaterTanks, name: "Fresh 1" },
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 3" },
					{ tankModel: freshWaterTanks, isGroup: false, name: "Fresh 1" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 1 },
				]
			},
			{
				// Remove a tank, triggering a separation of a group of another type.
				tag: "Remove 1 tank, group of another type separated",
				mergeThreshold: 6,
				initialTanks: [
					// Fuel tanks will be initially merged into a groups.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
					{ tankModel: wasteWaterTanks, name: "Waste 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
				],
				tanksToRemove: [
					{ tankModel: oilTanks, index: 0 },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 3" },
					{ tankModel: wasteWaterTanks, isGroup: false, name: "Waste 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 1 }, // 1 row inserted
					{ spy: spyRowsRemoved, count: 1 }, // oil tank removed
					{ spy: spyDataChanged, count: 1 }, // row 0 isGroup=true to false
				]
			},
			{
				// Remove a tank from a group, without triggering a separation.
				tag: "Remove 1 tank from group, group remains",
				mergeThreshold: 2,
				initialTanks: [
					// These will be initially merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 },
				],
				expectedTanks: [
					// Group remains, as having two tanks would still reach the threshold.
					{ tankModel: fuelTanks, isGroup: true, name: "" },
				],
				expectedSignals: [
					// No changes expected.
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Remove a tank, without triggering a separation for a different tank type.
				tag: "Remove 1 tank, group of other remains",
				mergeThreshold: 3,
				initialTanks: [
					// Oil tanks will be initially merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
					{ tankModel: oilTanks, name: "Oil 3" },
				],
				tanksToRemove: [
					{ tankModel: fuelTanks, index: 0 },
				],
				expectedTanks: [
					// Oil group remains, as having 3 tanks would still reach the threshold.
					{ tankModel: oilTanks, isGroup: true, name: "" },
				],
				expectedSignals: [
					{ spy: spyCountChanged, count: 1 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 1 }, // fuel row removed
					{ spy: spyDataChanged, count: 0 },
				]
			},
			{
				// Remove a tank, without triggering a separation for any types.
				tag: "Remove 1 tank, all groups remain",
				mergeThreshold: 3,
				initialTanks: [
					// Fuel and oil tanks will be initially merged into two groups.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
					{ tankModel: oilTanks, name: "Oil 3" },
				],
				tanksToRemove: [
					{ tankModel: oilTanks, index: 0 },
				],
				expectedTanks: [
					// Groups remain, as having more than two entries would reach the threshold.
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: oilTanks, isGroup: true, name: "" },
				],
				expectedSignals: [
					 // No changes expected.
					{ spy: spyCountChanged, count: 0 },
					{ spy: spyRowsInserted, count: 0 },
					{ spy: spyRowsRemoved, count: 0 },
					{ spy: spyDataChanged, count: 0 },
				]
			},
		]
	}

	function test_remove(data) {
		allTanks.mergeThreshold = data.mergeThreshold
		for (const initialTank of data.initialTanks) {
			initialTank.tankModel.addDevice(createTank(initialTank.tankModel.type, initialTank.name))
		}
		allTanks.tankModels = [fuelTanks, freshWaterTanks, wasteWaterTanks, oilTanks]

		let expectedSignal
		for (expectedSignal of data.expectedSignals) {
			expectedSignal.spy.clear()
		}
		for (const tankToRemove of data.tanksToRemove) {
			tankToRemove.tankModel.removeAt(tankToRemove.index)
		}

		compare(allTanks.count, data.expectedTanks.length)
		for (let i = 0; i < data.expectedTanks.length; ++i) {
			compare(allTanks.tankModelAt(i), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), data.expectedTanks[i].isGroup, `row=${i}`)
		}
		for (expectedSignal of data.expectedSignals) {
			compare(expectedSignal.spy.count, expectedSignal.count, expectedSignal.spy.signalName)
		}
	}

	function test_move_data() {
		return [
			{
				// Swap 2 tanks by moving the first entry.
				tag: "2 tanks, move first",
				mergeThreshold: 0,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				tanksToRename: [
					{ tankModel: fuelTanks, index: 0, newName: "Fuel 3" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 3" },
				],
				expectedMove: true,
			},
			{
				// Swap 2 tanks by moving the last entry.
				tag: "2 tanks, move last",
				mergeThreshold: 0,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
				],
				tanksToRename: [
					{ tankModel: fuelTanks, index: 1, newName: "Fuel 0" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 0" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
				],
				expectedMove: true,
			},
			{
				// Rename a tank to move it to the end.
				tag: "3 tanks, move first to last",
				mergeThreshold: 0,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				tanksToRename: [
					{ tankModel: fuelTanks, index: 0, newName: "Fuel 4" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 3" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 4" },
				],
				expectedMove: true,
			},
			{
				// Rename a tank to move it to the start.
				tag: "3 tanks, move last to first",
				mergeThreshold: 0,
				initialTanks: [
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				tanksToRename: [
					{ tankModel: fuelTanks, index: 2, newName: "Fuel 0" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 0" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 1" },
					{ tankModel: fuelTanks, isGroup: false, name: "Fuel 2" },
				],
				expectedMove: true,
			},
			{
				// Rename a tank to move it to the start of its series.
				tag: "3 tanks + group, move last to first after group",
				mergeThreshold: 5,
				initialTanks: [
					// Fuel tanks will be merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
					{ tankModel: oilTanks, name: "Oil 1" },
					{ tankModel: oilTanks, name: "Oil 2" },
					{ tankModel: oilTanks, name: "Oil 3" },
				],
				tanksToRename: [
					{ tankModel: oilTanks, index: 2, newName: "Oil 0" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 0" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 1" },
					{ tankModel: oilTanks, isGroup: false, name: "Oil 2" },
				],
				expectedMove: true,
			},
			{
				// Rename a tank within a group; no changes are expected.
				tag: "Rename tank within group",
				mergeThreshold: 3,
				initialTanks: [
					// Fuel tanks will be merged into a group.
					{ tankModel: fuelTanks, name: "Fuel 1" },
					{ tankModel: fuelTanks, name: "Fuel 2" },
					{ tankModel: fuelTanks, name: "Fuel 3" },
				],
				tanksToRename: [
					{ tankModel: fuelTanks, index: 0, newName: "Fuel 4" },
				],
				expectedTanks: [
					{ tankModel: fuelTanks, isGroup: true, name: "" },
				],
				expectedMove: false,
			},
		]
	}

	function test_move(data) {
		allTanks.mergeThreshold = data.mergeThreshold
		for (const initialTank of data.initialTanks) {
			initialTank.tankModel.addDevice(createTank(initialTank.tankModel.type, initialTank.name))
		}
		allTanks.tankModels = [fuelTanks, freshWaterTanks, wasteWaterTanks, oilTanks]

		spyMoved.clear()
		spyCountChanged.clear()
		for (const tankToRename of data.tanksToRename) {
			const tank = tankToRename.tankModel.tankAt(tankToRename.index)
			tank.name = tankToRename.newName
		}

		compare(allTanks.count, data.expectedTanks.length)
		for (let i = 0; i < data.expectedTanks.length; ++i) {
			compare(allTanks.tankModelAt(i), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.tankAt(i)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankRole)?.name ?? "", data.expectedTanks[i].name, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.TankModelRole), data.expectedTanks[i].tankModel, `row=${i}`)
			compare(allTanks.data(allTanks.index(i, 0), AggregateTankModel.IsGroupRole), data.expectedTanks[i].isGroup, `row=${i}`)
		}
		compare(spyMoved.count, data.expectedMove ? 1 : 0)
		compare(spyCountChanged.count, 0)
	}
}
