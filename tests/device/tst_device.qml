/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

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
}
