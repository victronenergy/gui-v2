/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick
import Victron.VenusOS

TestCase {
	id: root
	name: "AggregateDeviceModelTest"

	BaseDevice {
		id: deviceA
		serviceUid: "mock/com.victronenergy.test.a"
		productName: "Device A"
		name: productName
		objectName: name
		deviceInstance: 0
	}
	BaseDevice {
		id: deviceB
		serviceUid: "mock/com.victronenergy.test.b"
		productName: "Device B"
		name: productName
		objectName: name
		deviceInstance: 1
	}
	BaseDevice {
		id: deviceC
		serviceUid: "mock/com.victronenergy.test.c"
		productName: "Device C"
		name: productName
		objectName: name
		deviceInstance: 2
	}

	BaseDeviceModel {
		id: deviceModelA
		modelId: "deviceModelA"
		sortBy: BaseDeviceModel.NoSort
	}
	BaseDeviceModel {
		id: deviceModelB
		modelId: "deviceModelB"
		sortBy: BaseDeviceModel.NoSort
	}

	AggregateDeviceModel {
		id: aggModel
	}

	function init() {
		aggModel.retainDevices = false
		aggModel.sourceModels = []
		aggModel.sortBy = AggregateDeviceModel.NoSort
		deviceModelA.clear()
		deviceModelB.clear()
	}

	function test_sourceModels() {
		compare(aggModel.sourceModels, [])
		compare(aggModel.count, 0)

		aggModel.sourceModels = [deviceModelA, deviceModelB]
		compare(aggModel.sourceModels, [deviceModelA, deviceModelB])
		compare(aggModel.count, 0)

		// Verify devices from source models are aggregated into this model
		deviceModelA.addDevice(deviceA)
		compare(aggModel.count, 1)
		deviceModelA.addDevice(deviceB)
		compare(aggModel.count, 2)
		deviceModelB.addDevice(deviceC)
		compare(aggModel.count, 3)

		// Duplicate devices from different models are still aggregated into this model.
		deviceModelB.addDevice(deviceA)
		compare(aggModel.count, 4)
	}

	function test_deviceAt(data) {
		deviceModelA.addDevice(deviceA)
		deviceModelA.addDevice(deviceB)
		deviceModelB.addDevice(deviceC)
		aggModel.sourceModels = [deviceModelA, deviceModelB]
		compare(aggModel.count, 3)

		compare(aggModel.deviceAt(0), deviceA)
		compare(aggModel.deviceAt(1), deviceB)
		compare(aggModel.deviceAt(2), deviceC)

		deviceModelA.removeDevice(deviceB.serviceUid)
		compare(aggModel.deviceAt(0), deviceA)
		compare(aggModel.deviceAt(1), deviceC)
		deviceModelA.removeDevice(deviceA.serviceUid)
		compare(aggModel.deviceAt(0), deviceC)
	}

	function test_sortBy_data() {
		return [
			{
				tag: "sort=NoSort",
				sortBy: AggregateDeviceModel.NoSort,
				sorted: [deviceC, deviceA, deviceB] // sorted by the order of insertion
			},
			{
				tag: "sort=SortByDeviceName",
				sortBy: AggregateDeviceModel.SortByDeviceName,
				sorted: [deviceA, deviceB, deviceC] // alphabetical order of device name
			},
			{
				tag: "sort=SortBySourceModel",
				sortBy: AggregateDeviceModel.SortBySourceModel,
				sorted: [deviceC, deviceB, deviceA] // Model A items, then Model B items
			},
			{
				tag: "sort=SortBySourceModel|SortByDeviceName",
				sortBy: AggregateDeviceModel.SortBySourceModel | AggregateDeviceModel.SortByDeviceName,
				sorted: [deviceB, deviceC, deviceA] // Ordered Model A names, then ordered Model B names
			},
		]
	}

	function test_sortBy(data) {
		aggModel.sortBy = data.sortBy
		aggModel.sourceModels = [deviceModelA, deviceModelB]
		deviceModelA.addDevice(deviceC)
		deviceModelB.addDevice(deviceA)
		deviceModelA.addDevice(deviceB)

		compare(aggModel.deviceAt(0), data.sorted[0])
		compare(aggModel.deviceAt(1), data.sorted[1])
		compare(aggModel.deviceAt(2), data.sorted[2])
	}

	function test_retainDevices_data() {
		return [
			{ tag: "retainDevices=true", retainDevices: true },
			{ tag: "retainDevices=false", retainDevices: false },
		]
	}

	function test_retainDevices(data) {
		aggModel.retainDevices = data.retainDevices

		aggModel.sourceModels = [deviceModelA]
		deviceModelA.addDevice(deviceA)
		deviceModelA.addDevice(deviceB)
		compare(aggModel.count, 2)

		deviceModelA.removeDevice(deviceA.serviceUid)
		compare(aggModel.count, aggModel.retainDevices ? 2 : 1)
		compare(aggModel.deviceAt(0), aggModel.retainDevices ? null : deviceB)
		compare(aggModel.deviceAt(1), aggModel.retainDevices ? deviceB : null)

		deviceModelA.removeDevice(deviceB.serviceUid)
		compare(aggModel.count, aggModel.retainDevices ? 2 : 0)
		compare(aggModel.deviceAt(0), null)
		compare(aggModel.deviceAt(1), null)
	}

	function removeDisconnectedDevices() {
		aggModel.retainDevices = true

		deviceModelA.addDevice(deviceA)
		deviceModelA.addDevice(deviceB)
		aggModel.sourceModels = [deviceModelA]

		const deviceAInstance = deviceA.deviceInstance
		const deviceBInstance = deviceB.deviceInstance

		// Disconnect deviceA
		deviceA.deviceInstance = -1
		compare(aggModel.disconnectedDeviceCount, 1)
		compare(aggModel.count, 2)
		aggModel.removeDisconnectedDevices()
		compare(aggModel.disconnectedDeviceCount, 0)
		compare(aggModel.count, 1)

		// Disconnect deviceB
		deviceB.deviceInstance = -1
		compare(aggModel.disconnectedDeviceCount, 1)
		compare(aggModel.count, 1)
		aggModel.removeDisconnectedDevices()
		compare(aggModel.disconnectedDeviceCount, 0)
		compare(aggModel.count, 1)

		// Reconnect, and disconnect both devices by removing them from their models.
		deviceA.deviceInstance = deviceAInstance
		deviceB.deviceInstance = deviceBInstance
		compare(aggModel.count, 2)
		compare(aggModel.disconnectedDeviceCount, 0)
		deviceModelA.removeDevice(deviceA.serviceUid)
		deviceModelA.removeDevice(deviceB.serviceUid)
		compare(aggModel.count, 2)
		compare(aggModel.disconnectedDeviceCount, 2)
		aggModel.removeDisconnectedDevices()
		compare(aggModel.count, 0)
		compare(aggModel.disconnectedDeviceCount, 0)
	}

	function test_disconnectedDeviceCount() {
		aggModel.retainDevices = true

		deviceModelA.addDevice(deviceA)
		deviceModelA.addDevice(deviceB)
		aggModel.sourceModels = [deviceModelA]

		compare(aggModel.count, 2)
		compare(aggModel.disconnectedDeviceCount, 0)

		const deviceAInstance = deviceA.deviceInstance
		const deviceBInstance = deviceB.deviceInstance

		// Disconnect deviceA and deviceB
		deviceA.deviceInstance = -1
		compare(aggModel.disconnectedDeviceCount, 1)
		deviceB.deviceInstance = -1
		compare(aggModel.disconnectedDeviceCount, 2)

		// Reconnect deviceA and deviceB
		deviceA.deviceInstance = deviceAInstance
		compare(aggModel.disconnectedDeviceCount, 1)
		deviceB.deviceInstance = deviceBInstance
		compare(aggModel.disconnectedDeviceCount, 0)

		// Disconnect deviceA and remove it from the device model.
		// It should remain in the aggregate model as a "disconnected" device...
		compare(deviceModelA.count, 2)
		deviceA.deviceInstance = -1
		deviceModelA.removeDevice(deviceA.serviceUid)
		compare(deviceModelA.count, 1)
		compare(aggModel.disconnectedDeviceCount, 1)
		compare(aggModel.count, 2)

		// ... then reinsert into device model.
		// It should reappear in the aggregate model, and disconnectedDeviceCount should upate.
		deviceA.deviceInstance = deviceAInstance
		deviceModelA.addDevice(deviceA)
		compare(aggModel.disconnectedDeviceCount, 0)
		compare(aggModel.count, 2)
	}
}
