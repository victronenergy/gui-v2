/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "FilteredDeviceModelTest"

	FilteredDeviceModel {
		id: model
	}

	function findDeviceDataForUid(deviceDataList, uid) {
		for (const deviceData of deviceDataList) {
			if (deviceData.uid === uid) {
				return deviceData
			}
		}
		return {}
	}

	function test_model_data() {
		const devices = [
			{ uid: "mock/com.victronenergy.c.suffix1", deviceInstance: 3, productName: "Y" },
			{ uid: "mock/com.victronenergy.c.suffix2", deviceInstance: 1, productName: "Z" },
			{ uid: "mock/com.victronenergy.c.suffix3", deviceInstance: 2, productName: "X" },
			{ uid: "mock/com.victronenergy.b.suffix1", deviceInstance: 0, productName: "J" },
			{ uid: "mock/com.victronenergy.a.suffix1", deviceInstance: 0, productName: "K" },
		]
		return [
			{
				tag: "no sort/filter",
				sort: 0,
				serviceTypes: [],
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.a.suffix1",
				]
			},
			{
				tag: "sort: ServiceTypeOrder",
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				serviceTypes: ["c", "a", "b"],
				devices: devices,
				expectedUids: [
					// The order of the c services does not matter; this is just the order in
					// which they were inserted.
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.b.suffix1",
				]
			},
			{
				tag: "sort: DeviceInstance",
				sorting: FilteredDeviceModel.DeviceInstance,
				devices: devices,
				expectedUids: [
					// a and b have the same device instance, so model should just order
					// them in their insertion order.
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
				]
			},
			{
				tag: "sort: Name",
				sorting: FilteredDeviceModel.Name,
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
				]
			},
			{
				tag: "sort: ServiceTypeOrder + Name",
				sorting: FilteredDeviceModel.ServiceTypeOrder | FilteredDeviceModel.Name,
				devices: devices,
				serviceTypes: ["a", "b", "c"],
				expectedUids: [
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
				]
			},
			{
				tag: "sort: ServiceType + Device Instance + Name",
				sorting: FilteredDeviceModel.ServiceTypeOrder
						| FilteredDeviceModel.DeviceInstance
						| FilteredDeviceModel.Name,
				serviceTypes: ["a", "b", "c"],
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
				]
			},
			{
				tag: "filter: a only",
				serviceTypes: ["a"],
				devices: devices,
				expectedUids: [ "mock/com.victronenergy.a.suffix1" ]
			},
			{
				tag: "filter: b only",
				serviceTypes: ["b"],
				devices: devices,
				expectedUids: [ "mock/com.victronenergy.b.suffix1" ]
			},
			{
				tag: "filter: c only",
				serviceTypes: ["c"],
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
				]
			},
			{
				tag: "filter: b + c",
				serviceTypes: ["b", "c"],
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.b.suffix1",
				]
			},
			{
				tag: "sort/filter: ServiceType, b + c",
				serviceTypes: ["b", "c"],
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
				]
			},
			{
				tag: "sort/filter: ServiceType + DeviceInstance, b + c",
				serviceTypes: ["b", "c"],
				sorting: FilteredDeviceModel.ServiceTypeOrder | FilteredDeviceModel.DeviceInstance,
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
				]
			},
			{
				tag: "sort/filter: ServiceType + Name, b + c",
				serviceTypes: ["b", "c"],
				sorting: FilteredDeviceModel.ServiceTypeOrder | FilteredDeviceModel.Name,
				devices: devices,
				expectedUids: [
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix3",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
				]
			},
		]
	}

	function test_model(data) {
		let device
		let deviceData
		let expectedDeviceData
		let i

		// Set sort/filter, then add devices and verify model is correct.
		model.serviceTypes = data.serviceTypes ?? []
		model.sorting = data.sorting ?? 0
		for (deviceData of data.devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			deviceData = root.findDeviceDataForUid(data.devices, data.expectedUids[i])
			device = model.deviceAt(i)
			compare(device.serviceUid, deviceData.uid)
			compare(device.deviceInstance, deviceData.deviceInstance)
			compare(device.productName, deviceData.productName)
		}

		// Remove services
		for (deviceData of data.devices) {
			MockManager.removeValue(deviceData.uid)
		}
		compare(model.count, 0)

		// Add devices, without a sort/filter set...
		model.sorting = 0
		model.serviceTypes = []
		for (deviceData of data.devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		// Check all test data is present and in the original order
		for (i = 0 ; i < data.devices.length; ++i) {
			deviceData = data.devices[i]
			device = model.deviceAt(i)
			compare(device.serviceUid, deviceData.uid)
			compare(device.deviceInstance, deviceData.deviceInstance)
			compare(device.productName, deviceData.productName)
		}

		// ...then set sort/filter and check model is updated
		model.serviceTypes = data.serviceTypes ?? []
		model.sorting = data.sorting ?? 0
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			deviceData = root.findDeviceDataForUid(data.devices, data.expectedUids[i])
			device = model.deviceAt(i)
			compare(device.serviceUid, deviceData.uid)
			compare(device.deviceInstance, deviceData.deviceInstance)
			compare(device.productName, deviceData.productName)
		}

		// Remove services
		for (deviceData of data.devices) {
			MockManager.removeValue(deviceData.uid)
		}

		compare(model.count, 0)
		model.serviceTypes = []
		model.sorting = 0
	}

	function test_child_filter_data() {
		const devices = [
			{ uid: "mock/com.victronenergy.generator.a", DeviceInstance: 1, ProductName: "Not enabled" },
			{ uid: "mock/com.victronenergy.generator.b", DeviceInstance: 2, ProductName: "Enabled", Enabled: 1, Active: 0 },
			{ uid: "mock/com.victronenergy.generator.c", DeviceInstance: 3, ProductName: "Active + Enabled", Enabled: 1, Active: 1 },
			{ uid: "mock/com.victronenergy.tank.a", DeviceInstance: 1, ProductName: "Tank" },
			{ uid: "mock/com.victronenergy.vebus.a", DeviceInstance: 0, ProductName: "Inverter/charger instance=0" },
			{ uid: "mock/com.victronenergy.vebus.b", DeviceInstance: 1, ProductName: "Inverter/charger instance=1" },
		]
		return [
			{
				tag: "Generators with Enabled=1",
				devices: devices,
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				serviceTypes: ["generator"],
				childFilterIds: { "generator": ["Enabled"] },
				childFilterFunction: (device, childItems) => {
					return childItems["Enabled"]?.value === 1
				},
				expectedUids: [
					"mock/com.victronenergy.generator.b",
					"mock/com.victronenergy.generator.c",
				],
				expectedUidsWhenFilterFails: [],
			},
			{
				tag: "Generators with Enabled=1, plus any other service type",
				devices: devices,
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				serviceTypes: ["generator", "tank", "vebus"],
				childFilterIds: { "generator": ["Enabled"] },
				childFilterFunction: (device, childItems) => {
					return childItems["Enabled"]?.value === 1
				},
				expectedUids: [
					"mock/com.victronenergy.generator.b",
					"mock/com.victronenergy.generator.c",
					"mock/com.victronenergy.tank.a",
					"mock/com.victronenergy.vebus.a",
					"mock/com.victronenergy.vebus.b",
				],
				expectedUidsWhenFilterFails: [
					"mock/com.victronenergy.tank.a",
					"mock/com.victronenergy.vebus.a",
					"mock/com.victronenergy.vebus.b",
				],
			},
			{
				tag: "Generators with Active=1 and Enabled=1",
				devices: devices,
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				serviceTypes: ["generator"],
				childFilterIds: { "generator": ["Active", "Enabled"] },
				childFilterFunction: (device, childItems) => {
					return childItems["Enabled"]?.value === 1 && childItems["Active"]?.value === 1
				},
				expectedUids: [
					"mock/com.victronenergy.generator.c",
				],
				expectedUidsWhenFilterFails: [],
			},
			{
				tag: "Generators with Active=1 and Enabled=1, vebus with DeviceInstance > 0, and any tank",
				devices: devices,
				sorting: FilteredDeviceModel.ServiceTypeOrder,
				serviceTypes: ["generator", "vebus", "tank"],
				childFilterIds: { "generator": ["Enabled", "Active"], "vebus": ["DeviceInstance"] },
				childFilterFunction: (device, childItems) => {
					if (device.serviceType === "generator") {
						return childItems["Enabled"]?.value === 1 && childItems["Active"]?.value === 1
					} else if (device.serviceType === "vebus") {
						return childItems["DeviceInstance"]?.value > 0
					} else {
						// This should not happen; the callback should not be called for tanks.
						return false
					}
				},
				expectedUids: [
					"mock/com.victronenergy.generator.c",
					"mock/com.victronenergy.vebus.b",
					"mock/com.victronenergy.tank.a",
				],
				expectedUidsWhenFilterFails: [
					"mock/com.victronenergy.tank.a",
				],
			},
		]
	}

	function test_child_filter(data) {
		let device
		let deviceData
		let i
		let propertyName

		// Set sort/filter, then add devices and verify model is correct.
		model.childFilterIds = data.childFilterIds
		model.childFilterFunction = data.childFilterFunction
		model.sorting = data.sorting
		model.serviceTypes = data.serviceTypes ?? []
		for (deviceData of data.devices) {
			for (propertyName in deviceData) {
				if (propertyName !== "uid") {
					MockManager.setValue(deviceData.uid + "/" + propertyName, deviceData[propertyName])
				}
			}
		}
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			compare(model.deviceAt(i).serviceUid, data.expectedUids[i])
		}

		// Remove services
		for (deviceData of data.devices) {
			MockManager.removeValue(deviceData.uid)
		}
		compare(model.count, 0)

		// Add devices, without a sort/filter set...
		model.childFilterIds = {}
		model.childFilterFunction = undefined
		model.sorting = 0
		model.serviceTypes = []
		for (deviceData of data.devices) {
			for (propertyName in deviceData) {
				if (propertyName !== "uid") {
					MockManager.setValue(deviceData.uid + "/" + propertyName, deviceData[propertyName])
				}
			}
		}
		// Check all test data is present and in the original order
		for (i = 0 ; i < data.devices.length; ++i) {
			compare(model.deviceAt(i).serviceUid, data.devices[i].uid)
		}

		// ...then set sort/filter and check model is updated
		model.childFilterIds = data.childFilterIds
		model.childFilterFunction = data.childFilterFunction
		model.sorting = data.sorting
		model.serviceTypes = data.serviceTypes ?? []
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			compare(model.deviceAt(i).serviceUid, data.expectedUids[i])
		}

		// Now, go through the child values and set them to undefined. The model should detect that
		// the child values have changed, and invalidate itself, and now the filter functions should
		// fail.
		let serviceType
		let childId
		for (serviceType in data.childFilterIds) {
			for (deviceData of data.devices) {
				if (deviceData.uid.indexOf("com.victronenergy." + serviceType) >= 0) {
					for (childId of data.childFilterIds[serviceType]) {
						MockManager.setValue(deviceData.uid + "/" + childId, undefined)
					}
				}
			}
		}
		compare(model.count, data.expectedUidsWhenFilterFails.length)
		for (i = 0 ; i < data.expectedUidsWhenFilterFails.length; ++i) {
			compare(model.deviceAt(i).serviceUid, data.expectedUidsWhenFilterFails[i])
		}

		// Now restore the original values, and the filter functions should pass again.
		for (deviceData of data.devices) {
			for (propertyName in deviceData) {
				if (propertyName !== "uid") {
					MockManager.setValue(deviceData.uid + "/" + propertyName, deviceData[propertyName])
				}
			}
		}
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			compare(model.deviceAt(i).serviceUid, data.expectedUids[i])
		}

		// Remove services
		for (deviceData of data.devices) {
			MockManager.removeValue(deviceData.uid)
		}
		compare(model.count, 0)

		model.childFilterIds = {}
		model.childFilterFunction = undefined
		model.sorting = 0
		model.serviceTypes = []
	}
}
