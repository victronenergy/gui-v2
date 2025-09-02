/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "SolarYieldModelTest"

	SolarYieldModel {
		id: model
	}

	function debugModel() {
		console.log("* Model firstDay:", model.firstDay, "lastDay:", model.lastDay, "count:", model.count)
		for (let i = 0 ; i < model.count; ++i) {
			console.log("\tDay", model.data(model.index(i, 0), SolarYieldModel.DayRole),
						"Yield:", model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole))
		}
	}

	function roleFromName(roleName) {
		switch (roleName) {
		case "day": return SolarYieldModel.DayRole
		case "yieldKwh": return SolarYieldModel.YieldKwhRole
		default: return ""
		}
	}

	function setDeviceProperties(devices) {
		for (const deviceData of devices) {
			const uid = deviceData.uid
			for (const subPath in deviceData.children) {
				MockManager.setValue(uid + "/" + subPath, deviceData.children[subPath])
			}
		}
	}

	function removeDevices(devices) {
		for (const deviceData of devices) {
			MockManager.removeValue(deviceData.uid)
		}
	}

	function test_yield_data() {
		return [
			{
				tag: "solarcharger - 0 days, then add 1 day",
				firstDay: 0,
				lastDay: 0,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 1,
							"History/Daily/0/Yield": 0.3,
						},
					}
				],
				updatedExpectedData: [
					{ day: 0, yieldKwh: 0.3 },
				]
			},
			{
				tag: "solarcharger - 1 day",
				firstDay: 0,
				lastDay: 0,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 1,
							"History/Daily/0/Yield": 0.1,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{ day: 0, yieldKwh: 0.1 },
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Daily/0/Yield": 0.2,
						},
					}
				],
				updatedExpectedData: [
					{ day: 0, yieldKwh: 0.2 },
				]
			},
			{
				tag: "solarcharger - 2 days, then change yields",
				firstDay: 0,
				lastDay: 1,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Yield": 0.1,
							"History/Daily/1/Yield": 0.3,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{ day: 0, yieldKwh: 0.1 },
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Daily/0/Yield": 0.11,
							"History/Daily/1/Yield": 0.3,
						},
					}
				],
				updatedExpectedData: [
					{ day: 0, yieldKwh: 0.11 },
					{ day: 1, yieldKwh: 0.3 },
				]
			},
			{
				tag: "solarcharger, multi, inverter - 5 days",
				firstDay: 0,
				lastDay: 4,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Yield": 0.1,
							"History/Daily/1/Yield": 0.2,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					},
					{
						uid: "mock/com.victronenergy.multi.a",
						children: {
							"History/Overall/DaysAvailable": 3,
							"History/Daily/0/Yield": 0.2,
							"History/Daily/1/Yield": 0.3,
							"History/Daily/2/Yield": 0.4,
							DeviceInstance: 0,
							ProductName: "multi_product",
						},
					},
					{
						uid: "mock/com.victronenergy.inverter.a",
						children: {
							DeviceInstance: 0,
							ProductName: "inverter_product",
						},
					},
				],
				expectedData: [
					{ day: 0, yieldKwh: 0.3 },
					{ day: 1, yieldKwh: 0.5 },
					{ day: 2, yieldKwh: 0.4 },
					{ day: 3, yieldKwh: 0 },
					{ day: 4, yieldKwh: 0 },
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.inverter.a",
						children: {
							"History/Overall/DaysAvailable": 5,
							"History/Daily/0/Yield": 0.5,
							"History/Daily/1/Yield": 0.6,
							"History/Daily/2/Yield": 0.7,
							"History/Daily/3/Yield": 0.8,
							"History/Daily/4/Yield": 0.9,
						},
					}
				],
				updatedExpectedData: [
					{ day: 0, yieldKwh: 0.8 },
					{ day: 1, yieldKwh: 1.1 },
					{ day: 2, yieldKwh: 1.1 },
					{ day: 3, yieldKwh: 0.8 },
					{ day: 4, yieldKwh: 0.9 },
				]
			},
		]
	}

	function test_yield(data) {
		let i

		// Add the test devices
		setDeviceProperties(data.devices)
		model.firstDay = data.firstDay
		model.lastDay = data.lastDay
		compare(model.count, data.lastDay - data.firstDay + 1)

		// Verify the yields are correct for each day.
		for (i = 0 ; i < data.expectedData.length; ++i) {
			compare(model.data(model.index(i, 0), SolarYieldModel.DayRole), data.expectedData[i]["day"])
			compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), data.expectedData[i]["yieldKwh"], "Day " + i)
		}

		// Make any necessary data changes and verify again.
		if (data.updatedDevices) {
			setDeviceProperties(data.updatedDevices)
			for (i = 0 ; i < data.updatedExpectedData.length; ++i) {
				compare(model.data(model.index(i, 0), SolarYieldModel.DayRole), data.updatedExpectedData[i]["day"])
				compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), data.updatedExpectedData[i]["yieldKwh"], "Day " + i)
			}
		}

		// Clean up
		removeDevices(data.devices)

		// The model count should remain the same, but all yields are now 0
		compare(model.count, data.lastDay - data.firstDay + 1)
		for (i = 0 ; i < data.expectedData.length; ++i) {
			compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), 0)
		}

		// Run the initial test again, but this time the test devices are added after the first/last
		// day is already set.
		setDeviceProperties(data.devices)
		for (i = 0 ; i < data.expectedData.length; ++i) {
			compare(model.data(model.index(i, 0), SolarYieldModel.DayRole), data.expectedData[i]["day"])
			compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), data.expectedData[i]["yieldKwh"], "Day " + i)
		}
		removeDevices(data.devices)

		model.firstDay = -1
		model.lastDay = -1
	}

	function test_days_data() {
		return [
			{
				tag: "today only",
				firstDay: 0,
				lastDay: 0,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Yield": 0.1,
							"History/Daily/1/Yield": 0.2,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{ day: 0, yieldKwh: 0.1 },
				],
			},
			{
				tag: "tomorrow only",
				firstDay: 1,
				lastDay: 1,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Yield": 0.1,
							"History/Daily/1/Yield": 0.2,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{ day: 1, yieldKwh: 0.2 },
				],
			},
			{
				tag: "Days 3-6",
				firstDay: 3,
				lastDay: 6,
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 3,
							"History/Daily/0/Yield": 0.1,
							"History/Daily/1/Yield": 0.2,
							"History/Daily/2/Yield": 0.3,
							"History/Daily/3/Yield": 0.4,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					},
					{
						uid: "mock/com.victronenergy.multi.a",
						children: {
							"History/Overall/DaysAvailable": 8,
							"History/Daily/0/Yield": 0.5,
							"History/Daily/1/Yield": 0.6,
							"History/Daily/2/Yield": 0.7,
							"History/Daily/3/Yield": 0.8,
							"History/Daily/4/Yield": 0.9,
							"History/Daily/5/Yield": 1.0,
							"History/Daily/6/Yield": 1.1,
							"History/Daily/7/Yield": 1.2,
							DeviceInstance: 0,
							ProductName: "multi_product",
						},
					},
				],
				expectedData: [
					{ day: 3, yieldKwh: 1.2 },  // solarcharger + multi
					{ day: 4, yieldKwh: 0.9 },  // multi only
					{ day: 5, yieldKwh: 1.0 },  // multi only
					{ day: 6, yieldKwh: 1.1 },  // multi only
				],
				updatedDevicesToRemove: [
					{ uid: "mock/com.victronenergy.solarcharger.a" }
				],
				updatedExpectedData: [
					{ day: 3, yieldKwh: 0.8 },  // multi only
					{ day: 4, yieldKwh: 0.9 },  // multi only
					{ day: 5, yieldKwh: 1.0 },  // multi only
					{ day: 6, yieldKwh: 1.1 },  // multi only
				]
			},
		]
	}

	function test_days(data) {
		let i

		// Add the test devices.
		setDeviceProperties(data.devices)

		// The first/last day defaults to -1, so the model count should be empty.
		compare(model.count, 0)

		// Set the days, to trigger population of the model roles.
		model.firstDay = data.firstDay
		model.lastDay = data.lastDay
		compare(model.count, data.lastDay - data.firstDay + 1)

		for (i = 0 ; i < data.expectedData.length; ++i) {
			compare(model.data(model.index(i, 0), SolarYieldModel.DayRole), data.expectedData[i]["day"])
			compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), data.expectedData[i]["yieldKwh"], "Day " + i)
		}

		// Make any necessary data changes and verify again.
		if (data.updatedDevicesToRemove) {
			removeDevices(data.updatedDevicesToRemove)
			for (i = 0 ; i < data.updatedExpectedData.length; ++i) {
				compare(model.data(model.index(i, 0), SolarYieldModel.DayRole), data.updatedExpectedData[i]["day"])
				compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), data.updatedExpectedData[i]["yieldKwh"], "Day " + i)
			}
		}

		// Clean up
		removeDevices(data.devices)

		// The model count should remain the same, but all yields are now 0
		compare(model.count, data.lastDay - data.firstDay + 1)
		for (i = 0 ; i < data.expectedData.length; ++i) {
			compare(model.data(model.index(i, 0), SolarYieldModel.YieldKwhRole), 0)
		}

		model.firstDay = -1
		model.lastDay = -1
	}
}
