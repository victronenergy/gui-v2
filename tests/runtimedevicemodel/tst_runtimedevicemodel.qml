/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "RuntimeDeviceModelTest"

	function test_disconnect() {
		const devices = [
			{ uid: "mock/com.victronenergy.a.suffix1", deviceInstance: 0, productName: "A" },
			{ uid: "mock/com.victronenergy.b.suffix2", deviceInstance: 0, productName: "B" },
			{ uid: "mock/com.victronenergy.c.suffix3", deviceInstance: 0, productName: "C" },
		]

		let deviceData
		let device
		let i

		// Add the devices
		for (deviceData of devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		compare(RuntimeDeviceModel.count, devices.length)
		for (i = 0 ; i < devices.length; ++i) {
			device = RuntimeDeviceModel.deviceAt(i)
			compare(device.serviceUid, devices[i].uid)
			compare(device.deviceInstance, devices[i].deviceInstance)
			compare(device.productName, devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.DeviceRole), device)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), true)
		}
		compare(RuntimeDeviceModel.disconnectedDeviceCount, 0)

		// Disconnect them; the entries should still be there, but with connected=false.
		for (i = 0 ; i < devices.length; ++i) {
			MockManager.removeValue(devices[i].uid)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.DeviceRole), null)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), false)
			compare(RuntimeDeviceModel.deviceAt(i), null)
		}
		compare(RuntimeDeviceModel.count, devices.length)
		compare(RuntimeDeviceModel.disconnectedDeviceCount, devices.length)

		// Reconnect them and verify details are correct again.
		for (deviceData of devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		for (i = 0 ; i < devices.length; ++i) {
			device = RuntimeDeviceModel.deviceAt(i)
			compare(device.serviceUid, devices[i].uid)
			compare(device.deviceInstance, devices[i].deviceInstance)
			compare(device.productName, devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.DeviceRole), device)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), true)
		}
		compare(RuntimeDeviceModel.disconnectedDeviceCount, 0)

		// Remove disconnected devices, and verify they are removed from the RuntimeDeviceModel.
		for (i = 0 ; i < devices.length; ++i) {
			MockManager.removeValue(devices[i].uid)
		}
		compare(RuntimeDeviceModel.count, devices.length)
		compare(RuntimeDeviceModel.disconnectedDeviceCount, devices.length)
		RuntimeDeviceModel.removeDisconnectedDevices()
		compare(RuntimeDeviceModel.count, 0)
	}

	function test_cachedName() {
		const devices = [
			{ uid: "mock/com.victronenergy.a.suffix1", deviceInstance: 0, productName: "A", customName: "AA" },
			{ uid: "mock/com.victronenergy.b.suffix2", deviceInstance: 0, productName: "B", customName: "BB" },
			{ uid: "mock/com.victronenergy.c.suffix3", deviceInstance: 0, productName: "C", customName: "CC" },
		]

		let deviceData
		let device
		let i

		// Add the devices
		for (deviceData of devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		compare(RuntimeDeviceModel.count, devices.length)
		for (i = 0 ; i < devices.length; ++i) {
			device = RuntimeDeviceModel.deviceAt(i)
			compare(device.name, devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].productName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), true)
		}
		compare(RuntimeDeviceModel.disconnectedDeviceCount, 0)

		// Set the custom name; verify this is the new cached name, as custom name takes precedence
		// over product name.
		for (i = 0 ; i < devices.length; ++i) {
			device = RuntimeDeviceModel.deviceAt(i)
			MockManager.setValue(devices[i].uid + "/CustomName", devices[i].customName)
			compare(device.name, devices[i].customName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].customName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), true)
		}
		compare(RuntimeDeviceModel.disconnectedDeviceCount, 0)

		// Disconnect, and verify the custom name is still there as the cached name.
		for (i = 0 ; i < devices.length; ++i) {
			MockManager.removeValue(devices[i].uid)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.DeviceRole), null)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.CachedDeviceNameRole), devices[i].customName)
			compare(RuntimeDeviceModel.data(RuntimeDeviceModel.index(i, 0), RuntimeDeviceModel.ConnectedRole), false)
		}
		compare(RuntimeDeviceModel.count, devices.length)
		compare(RuntimeDeviceModel.disconnectedDeviceCount, devices.length)

		// Remove all devices
		for (i = 0 ; i < devices.length; ++i) {
			MockManager.removeValue(devices[i].uid)
		}
		RuntimeDeviceModel.removeDisconnectedDevices()
		compare(RuntimeDeviceModel.count, 0)
		compare(RuntimeDeviceModel.disconnectedDeviceCount, 0)
	}
}
