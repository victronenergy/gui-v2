/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "SolarInputModelTest"

	SolarInputModel {
		id: model
	}

	function roleFromName(roleName) {
		switch (roleName) {
		case "serviceUid": return SolarInputModel.ServiceUidRole
		case "serviceType": return SolarInputModel.ServiceTypeRole
		case "group": return SolarInputModel.GroupRole
		case "enabled": return SolarInputModel.EnabledRole
		case "name": return SolarInputModel.NameRole
		case "todaysYield": return SolarInputModel.TodaysYieldRole
		case "power": return SolarInputModel.PowerRole
		case "current": return SolarInputModel.CurrentRole
		case "voltage": return SolarInputModel.VoltageRole
		default: return ""
		}
	}

	function debugModel() {
		console.log("* Model has", model.count, "inputs:")
		for (let i = 0 ; i < model.count; ++i) {
			console.log("\t", model.data(model.index(i, 0), SolarInputModel.ServiceUidRole))
			for (let role = SolarInputModel.ServiceTypeRole; role <= SolarInputModel.VoltageRole; ++role) {
				console.log("\t\t", model.data(model.index(i, 0), role))
			}
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

	function test_nrOfTrackers_data() {
		return [
			{
				tag: "NrOfTrackers not set",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: { DeviceInstance: 0, ProductName: "solarcharger_product" },
					},
					{
						uid: "mock/com.victronenergy.multi.a",
						children: { DeviceInstance: 0, ProductName: "multi_product" },
					},
					{
						uid: "mock/com.victronenergy.inverter.a",
						children: { DeviceInstance: 0, ProductName: "inverter_product" },
					},
				],
				// For solarcharger, if NrOfTrackers is not present, assume it is 1 and add the
				// devices to the model. For multi/inverter, it must be set in order to add the
				// device to the model.
				expectedData: [
					{ serviceUid: "mock/com.victronenergy.solarcharger.a" },
				],
			},
			{
				tag: "NrOfTrackers=0",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: { NrOfTrackers: 0, DeviceInstance: 0, ProductName: "solarcharger_product" },
					},
					{
						uid: "mock/com.victronenergy.multi.a",
						children: { NrOfTrackers: 0, DeviceInstance: 0, ProductName: "multi_product" },
					},
					{
						uid: "mock/com.victronenergy.inverter.a",
						children: { NrOfTrackers: 0, DeviceInstance: 0, ProductName: "inverter_product" },
					},
				],
				// When NrOfTrackers=0, the device is not added to the model.
				expectedData: [],
			},
			{
				tag: "NrOfTrackers=1",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: { NrOfTrackers: 1, DeviceInstance: 0, ProductName: "solarcharger_product" },
					},
					{
						uid: "mock/com.victronenergy.multi.a",
						children: { NrOfTrackers: 1, DeviceInstance: 0, ProductName: "multi_product" },
					},
					{
						uid: "mock/com.victronenergy.inverter.a",
						children: { NrOfTrackers: 1, DeviceInstance: 0, ProductName: "inverter_product" },
					},
				],
				// When NrOfTrackers=1, the device is added to the model.
				expectedData: [
					{ serviceUid: "mock/com.victronenergy.solarcharger.a" },
					{ serviceUid: "mock/com.victronenergy.multi.a" },
					{ serviceUid: "mock/com.victronenergy.inverter.a" },
				],
			},
		]
	}

	function test_nrOfTrackers(data) {
		setDeviceProperties(data.devices)

		compare(model.count, data.expectedData.length)
		for (let i = 0 ; i < data.expectedData.length; ++i) {
			for (const roleName in data.expectedData[i]) {
				compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
		}

		removeDevices(data.devices)
		compare(model.count, 0)
	}

	function test_trackers_data() {
		return [
			{
				tag: "solarcharger - no trackers",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_product",
						todaysYield: NaN,
						power: NaN,
						current: NaN,
						voltage: NaN,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							CustomName: "solarcharger_customName",
							"History/Overall/DaysAvailable": 1,
							"History/Daily/0/Yield": 10,
							"Yield/Power": 100,
							"Pv/V": 5,
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_customName",
						todaysYield: 10,
						power: 100,
						current: 100 / 5,
						voltage: 5,
					}
				]
			},
			{
				tag: "solarcharger - 1 tracker",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 1,
							"History/Daily/0/Yield": 1,
							"Yield/Power": 200,
							"Pv/V": 20,
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_product",
						todaysYield: 1,
						power: 200,
						current: 200 / 20,
						voltage: 20,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							CustomName: "solarcharger_customName",
							"History/Daily/0/Yield": 11,
							"Yield/Power": 201,
							"Pv/V": 25,
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_customName",
						todaysYield: 11,
						power: 201,
						current: 201 / 25,
						voltage: 25,
					}
				],
			},
			{
				tag: "solarcharger - 1 tracker with name",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"History/Overall/DaysAvailable": 1,
							"History/Daily/0/Yield": 1,
							"Yield/Power": 200,
							"Pv/V": 20,
							"Pv/0/Name": "tracker name",
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_product-tracker name",
						todaysYield: 1,
						power: 200,
						current: 200 / 20,
						voltage: 20,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"Pv/0/Name": "updated tracker name",
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.solarcharger.a",
						serviceType: "solarcharger",
						group: "generic",
						enabled: true,
						name: "solarcharger_product-updated tracker name",
						todaysYield: 1,
						power: 200,
						current: 200 / 20,
						voltage: 20,
					}
				],
			},
			{
				tag: "multi - 2 trackers",
				devices: [
					{
						uid: "mock/com.victronenergy.multi.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Pv/0/Yield": 1,
							"History/Daily/0/Pv/1/Yield": 2.5,
							"Pv/0/P": 100,
							"Pv/1/P": 150,
							"Pv/0/V": 5,
							"Pv/1/V": 10,
							NrOfTrackers: 2,
							DeviceInstance: 0,
							ProductName: "multi_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.multi.a",
						serviceType: "multi",
						group: "generic",
						enabled: true,
						name: "multi_product-#1",
						todaysYield: 1,
						power: 100,
						current: 100 / 5,
						voltage: 5,
					},
					{
						serviceUid: "mock/com.victronenergy.multi.a",
						serviceType: "multi",
						group: "generic",
						enabled: true,
						name: "multi_product-#2",
						todaysYield: 2.5,
						power: 150,
						current: 150 / 10,
						voltage: 10,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.multi.a",
						children: {
							CustomName: "multi_customName",
							"History/Daily/0/Yield": 15,
							"History/Daily/0/Pv/0/Yield": 5,
							"History/Daily/0/Pv/1/Yield": 10,
							"Yield/Power": 1000,
							"Pv/V": 100,
							"Pv/0/P": 500,
							"Pv/1/P": 600,
							"Pv/0/V": 50,
							"Pv/1/V": 60,
							"Pv/1/Name": "2nd tracker",
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.multi.a",
						serviceType: "multi",
						group: "generic",
						enabled: true,
						name: "multi_customName-#1",
						todaysYield: 5,
						power: 500,
						current: 500 / 50,
						voltage: 50,
					},
					{
						serviceUid: "mock/com.victronenergy.multi.a",
						serviceType: "multi",
						group: "generic",
						enabled: true,
						name: "multi_customName-2nd tracker",
						todaysYield: 10,
						power: 600,
						current: 600 / 60,
						voltage: 60,
					}
				],
			},
			{
				tag: "multi - 2 trackers, 1 disabled",
				devices: [
					{
						uid: "mock/com.victronenergy.multi.a",
						children: {
							"History/Overall/DaysAvailable": 2,
							"History/Daily/0/Pv/0/Yield": 1,
							"History/Daily/0/Pv/1/Yield": 2,
							"Pv/0/P": 100,
							"Pv/1/P": 200,
							"Pv/0/V": 10,
							"Pv/1/V": 20,
							"Pv/0/Enabled": 0,
							NrOfTrackers: 2,
							DeviceInstance: 0,
							ProductName: "multi_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.multi.a",
						serviceType: "multi",
						group: "generic",
						enabled: true,
						name: "multi_product-#2",
						todaysYield: 2,
						power: 200,
						current: 200 / 20,
						voltage: 20,
					}
				],
			},
		]
	}

	function test_trackers(data) {
		let i
		let roleName
		setDeviceProperties(data.devices)

		compare(model.count, data.expectedData.length)
		for (i = 0 ; i < data.expectedData.length; ++i) {
			for (roleName in data.expectedData[i]) {
				compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
		}

		if (data.updatedDevices) {
			setDeviceProperties(data.updatedDevices)
			for (i = 0 ; i < data.updatedExpectedData.length; ++i) {
				for (roleName in data.updatedExpectedData[i]) {
					compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.updatedExpectedData[i][roleName], roleName)
				}
			}
		}

		removeDevices(data.devices)
		compare(model.count, 0)
	}

	function test_pvinverters_data() {
		return [
			{
				tag: "pvinverter - single phase",
				devices: [
					{
						uid: "mock/com.victronenergy.pvinverter.a",
						children: {
							"Ac/Power": 100,
							"Ac/L1/Voltage": 10,
							"Ac/L1/Current": 100 / 10,
							DeviceInstance: 0,
							ProductName: "pvinverter_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.pvinverter.a",
						serviceType: "pvinverter",
						group: "pvinverter",
						enabled: true,
						name: "pvinverter_product",
						todaysYield: NaN,
						power: 100,
						current: 100 / 10,
						voltage: 10,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.pvinverter.a",
						children: {
							"Ac/Power": 150,
							"Ac/L1/Voltage": 30,
							"Ac/L1/Current": 150 / 30,
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.pvinverter.a",
						serviceType: "pvinverter",
						group: "pvinverter",
						enabled: true,
						name: "pvinverter_product",
						todaysYield: NaN,
						power: 150,
						current: 150 / 30,
						voltage: 30,
					}
				],
			},
			{
				tag: "pvinverter - multi phase",
				devices: [
					{
						uid: "mock/com.victronenergy.pvinverter.a",
						children: {
							"Ac/Power": 500,
							"Ac/L1/Voltage": 10,
							"Ac/L1/Current": 5,
							"Ac/L2/Voltage": 10,
							"Ac/L2/Current": 6,
							"Ac/L3/Voltage": 10,
							"Ac/L3/Current": 7,
							DeviceInstance: 0,
							ProductName: "pvinverter_product",
						},
					}
				],
				expectedData: [
					{
						serviceUid: "mock/com.victronenergy.pvinverter.a",
						serviceType: "pvinverter",
						group: "pvinverter",
						enabled: true,
						name: "pvinverter_product",
						todaysYield: NaN,
						power: 500,
						current: NaN,
						voltage: NaN,
					}
				],
				updatedDevices: [
					{
						uid: "mock/com.victronenergy.pvinverter.a",
						children: {
							"Ac/Power": 300,
							CustomName: "pvinverter_custom",
						},
					}
				],
				updatedExpectedData: [
					{
						serviceUid: "mock/com.victronenergy.pvinverter.a",
						serviceType: "pvinverter",
						group: "pvinverter",
						enabled: true,
						name: "pvinverter_custom",
						todaysYield: NaN,
						power: 300,
						current: NaN,
						voltage: NaN,
					}
				],
			},
		]
	}

	function test_pvinverters(data) {
		let i
		let roleName
		setDeviceProperties(data.devices)

		compare(model.count, data.expectedData.length)
		for (i = 0 ; i < data.expectedData.length; ++i) {
			for (roleName in data.expectedData[i]) {
				compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
		}

		if (data.updatedDevices) {
			setDeviceProperties(data.updatedDevices)
			for (i = 0 ; i < data.updatedExpectedData.length; ++i) {
				for (roleName in data.updatedExpectedData[i]) {
					compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.updatedExpectedData[i][roleName], roleName)
				}
			}
		}

		removeDevices(data.devices)
		compare(model.count, 0)
	}

}
