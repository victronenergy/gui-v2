/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "DeviceTest"

	Component {
		id: deviceComponent
		Device {}
	}

	function test_fromServiceUid_data() {
		return [
			{
				tag: "with instance and product name",
				serviceUid: "mock/com.victronenergy.a.suffix1",
				properties: {
					DeviceInstance: 1,
					ProductName: "Product A",
				}
			},
			{
				tag: "also with custom name and product id",
				serviceUid: "mock/com.victronenergy.a.suffix1",
				properties: {
					DeviceInstance: 2,
					ProductName: "Product B",
					ProductId: 2,
					CustomName: "Custom B",
				}
			},
		]
	}

	function test_fromServiceUid(data) {
		let propertyName

		// Add mock data
		for (propertyName in data.properties) {
			MockManager.setValue(data.serviceUid + "/" + propertyName, data.properties[propertyName])
		}

		// Now create a Device, set the uid and expect the relevant properties to be fetched.
		const device = deviceComponent.createObject(root)
		device.serviceUid = data.serviceUid
		for (propertyName in data.properties) {
			const devicePropertyName = propertyName[0].toLowerCase() + propertyName.substr(1)
			compare(device[devicePropertyName], data.properties[propertyName], propertyName)
		}
		compare(device.name, device.customName || device.productName)

		// Change custom name and check it is updated in the Device.
		MockManager.setValue(data.serviceUid + "/CustomName", "Blah")
		compare(device.customName, "Blah")
		compare(device.name, device.customName)

		// Remove custom name and check the product name is used.
		MockManager.setValue(data.serviceUid + "/CustomName", "")
		compare(device.name, device.productName)

		device.destroy()
	}

	function test_fromServiceTypeDeviceInstance_data() {
		return [
			{
				tag: "data added before device is created",
				serviceType: "b",
				deviceInstance: 1,
				addDataFirst: true,
				properties: {
					DeviceInstance: 1,
					ProductName: "Product A",
				}
			},
			{
				tag: "data added after device is created",
				serviceType: "b",
				deviceInstance: 2,
				addDataFirst: false,
				properties: {
					DeviceInstance: 2,
					ProductName: "Product B",
					ProductId: 2,
					CustomName: "Custom B",
				}
			},
		]
	}

	function test_fromServiceTypeDeviceInstance(data) {
		let propertyName
		const serviceUid = "mock/com.victronenergy.%1.instance%2".arg(data.serviceType).arg(data.deviceInstance)

		// Add a decoy service of the same type with a different device instance, which should
		// not be matched.
		const decoyUid = "mock/com.victronenergy.%1.decoy%2".arg(data.serviceType).arg(data.deviceInstance)
		MockManager.setValue(decoyUid + "/DeviceInstance", data.deviceInstance + 100)
		MockManager.setValue(decoyUid + "/ProductName", "Decoy")

		function addMockData() {
			for (propertyName in data.properties) {
				MockManager.setValue(serviceUid + "/" + propertyName, data.properties[propertyName])
			}
		}

		if (data.addDataFirst) {
			addMockData()
		}

		// Create a Device with the service type and device instance, and expect the serviceUid
		// to be found and the relevant properties to be fetched.
		const device = deviceComponent.createObject(root)
		device.serviceType = data.serviceType
		device.deviceInstance = data.deviceInstance

		if (!data.addDataFirst) {
			compare(device.serviceUid, "")
			addMockData()
		}

		compare(device.serviceUid, serviceUid)
		compare(device.serviceType, data.serviceType)
		for (propertyName in data.properties) {
			const devicePropertyName = propertyName[0].toLowerCase() + propertyName.substr(1)
			compare(device[devicePropertyName], data.properties[propertyName], propertyName)
		}
		compare(device.name, device.customName || device.productName)
		verify(device.valid)

		// Once the serviceUid is set, the serviceType cannot be changed.
		ignoreWarning(/Cannot set serviceType/)
		device.serviceType = "c"
		compare(device.serviceType, data.serviceType)

		device.destroy()
	}
}
