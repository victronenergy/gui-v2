/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "AllDevicesModelTest"

	function test_model_data() {
		return [
			{
				tag: "one device",
				devices: [
					{ uid: "mock/com.victronenergy.test.a", deviceInstance: 0, productName: "A", valid: true }
				],
			},
			{
				tag: "two devices",
				devices: [
					{ uid: "mock/com.victronenergy.test.a", deviceInstance: 10, productName: "A", valid: true },
					{ uid: "mock/com.victronenergy.test.b", deviceInstance: 20, customName: "B", valid: true },
				]
			},
			{
				tag: "different device types and one with custom+product name",
				devices: [
					{ uid: "mock/com.victronenergy.test.a", deviceInstance: 10, productName: "A", valid: true },
					{ uid: "mock/com.victronenergy.test2.a", deviceInstance: 20, customName: "B", valid: true },
					{ uid: "mock/com.victronenergy.test3.a", deviceInstance: 10, productName: "C", customName: "CC", valid: true },
				]
			},
			{
				tag: "some invalid devices",
				devices: [
					{ uid: "mock/com.victronenergy.test.a", deviceInstance: 10, valid: false }, // no product/custom name
					{ uid: "mock/com.victronenergy.test.b", customName: "B", valid: false }, // no device instance
					{ uid: "mock/com.victronenergy.test.c", deviceInstance: 11, customName: "C", valid: true },
					{ uid: "mock/com.victronenergy.test.d", productName: "D", valid: false }, // no device instance
				]
			},
		]
	}

	function test_model(data) {
		let i
		let validDevices = []
		let device
		let deviceData

		// Add devices. On the first data test, this will start the model with pre-populated values.
		for (deviceData of data.devices) {
			if (deviceData.deviceInstance !== undefined) {
				MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			}
			if (deviceData.productName !== undefined) {
				MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
			}
			if (deviceData.customName !== undefined) {
				MockManager.setValue(deviceData.uid + "/CustomName", deviceData.customName)
			}
			if (deviceData.valid) {
				validDevices.push(deviceData)
			}

			// Service should always be in AllServiceModel, even if it is not in AllDevicesModel
			// (which only contains services that look like devices).
			verify(AllServicesModel.indexOf(deviceData.uid) >= 0)
			compare(AllDevicesModel.indexOf(deviceData.uid) >= 0, deviceData.valid)
		}

		compare(AllDevicesModel.count, validDevices.length)
		for (i = 0 ; i < validDevices.length; ++i) {
			device = AllDevicesModel.data(AllDevicesModel.index(i, 0), AllDevicesModel.DeviceRole)
			compare(device.serviceUid, validDevices[i].uid)
			compare(device.deviceInstance, validDevices[i].deviceInstance)
			compare(device.productName, validDevices[i].productName ?? "")
			compare(device.customName, validDevices[i].customName ?? "")
			compare(device.name, validDevices[i].customName || validDevices[i].productName)
		}

		// Remove valid devices
		let expectedCount = validDevices.length
		for (deviceData of validDevices) {
			MockManager.removeValue(deviceData.uid)
			compare(AllDevicesModel.indexOf(deviceData.uid), -1)
			compare(AllDevicesModel.count, --expectedCount)
		}
		compare(AllDevicesModel.count, 0)

		// Add a device
		const uid = "mock/com.victronenergy.test"
		MockManager.setValue(uid + "/DeviceInstance", 0)
		compare(AllDevicesModel.indexOf(uid), -1) // device is not yet valid
		MockManager.setValue(uid + "/ProductName", "Blah")
		compare(AllDevicesModel.indexOf(uid), 0) // device is now valid
		MockManager.setValue(uid + "/ProductName", "")
		compare(AllDevicesModel.indexOf(uid), -1) // device is invalid again
		MockManager.setValue(uid + "/CustomName", "Blah")
		compare(AllDevicesModel.indexOf(uid), 0) // device is now valid
		MockManager.setValue(uid + "/DeviceInstance", -1)
		compare(AllDevicesModel.indexOf(uid), -1) // device is invalid again
		MockManager.removeValue(uid)
		compare(AllDevicesModel.indexOf(uid), -1) // device does not exist
	}
}
