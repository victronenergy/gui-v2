/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	FilteredDeviceModel {
		id: dcGensets
		serviceTypes: ["dcgenset"]
		sorting: FilteredDeviceModel.DeviceInstance
	}

	SortedRuntimeDeviceModel {
		id: sortedRuntimeDeviceModel
		sourceModel: RuntimeDeviceModel
		excludedServiceTypes: dcGensets.count > 1 ? ["dcgenset"] : []
	}

	name: "SortedRuntimeDeviceModelTest"

	function test_sortedRuntimeDeviceModel() {
		function addDevice(dcGenset) {
			MockManager.setValue(dcGenset.uid + "/DeviceInstance", dcGenset.deviceInstance)
			MockManager.setValue(dcGenset.uid + "/ProductName", dcGenset.productName)
		}

		compare(dcGensets.count, 0)

		const devices = [
			{ uid: "mock/com.victronenergy.a.suffix1", deviceInstance: 1, productName: "A" },
			{ uid: "mock/com.victronenergy.a.suffix2", deviceInstance: 2, productName: "B" },
			{ uid: "mock/com.victronenergy.a.suffix3", deviceInstance: 3, productName: "C" },
		]
		const dcgensets = [
			{ uid: "mock/com.victronenergy.dcgenset.001", deviceInstance: 4, productName: "dc genset 1" },
			{ uid: "mock/com.victronenergy.dcgenset.002", deviceInstance: 5, productName: "dc genset 2" },
			{ uid: "mock/com.victronenergy.dcgenset.003", deviceInstance: 6, productName: "dc genset 3" }
		]

		let deviceData
		// Add the devices
		for (deviceData of devices) {
			MockManager.setValue(deviceData.uid + "/DeviceInstance", deviceData.deviceInstance)
			MockManager.setValue(deviceData.uid + "/ProductName", deviceData.productName)
		}
		compare(RuntimeDeviceModel.count, 3)

		addDevice(dcgensets[0])
		compare(sortedRuntimeDeviceModel.count, 4)
		compare(RuntimeDeviceModel.count, 4)

		addDevice(dcgensets[1])
		compare(sortedRuntimeDeviceModel.count, 3)
		compare(RuntimeDeviceModel.count, 5)

		addDevice(dcgensets[2])
		compare(sortedRuntimeDeviceModel.count, 3)
		compare(RuntimeDeviceModel.count, 6)

		for (deviceData of devices) {
			MockManager.removeValue(deviceData.uid)
		}
		for (deviceData of dcgensets) {
			MockManager.removeValue(deviceData.uid)
		}
		RuntimeDeviceModel.removeDisconnectedDevices()
		compare(sortedRuntimeDeviceModel.count, 0)
	}
}
