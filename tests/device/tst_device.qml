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

	function test_fromServiceTypeDeviceInstance_instanceChanged() {
		// Add a valid service with a device instance that does not match the lookup.
		const serviceUid = "mock/com.victronenergy.d.changed"
		MockManager.setValue(serviceUid + "/DeviceInstance", 10)
		MockManager.setValue(serviceUid + "/ProductName", "Product D")

		// Look up a device instance that is not found yet.
		const device = deviceComponent.createObject(root)
		device.serviceType = "d"
		device.deviceInstance = 11
		compare(device.serviceUid, "")

		// When the existing service's device instance changes to match, the lookup finds it.
		MockManager.setValue(serviceUid + "/DeviceInstance", 11)
		compare(device.serviceUid, serviceUid)
		compare(device.productName, "Product D")
		verify(device.valid)

		device.destroy()
	}

	function test_fromServiceTypeDeviceInstance_matchedByModelReset() {
		// Add a valid service with a device instance that does not match the lookup.
		const serviceUid = "mock/com.victronenergy.e.reset"
		MockManager.setValue(serviceUid + "/DeviceInstance", 20)
		MockManager.setValue(serviceUid + "/ProductName", "Product E")

		// Look up a device instance that is not found yet.
		const device = deviceComponent.createObject(root)
		device.serviceType = "e"
		device.deviceInstance = 21
		compare(device.serviceUid, "")

		// Change the device instance to match while the services are being reset. The handler for
		// AllServicesModel::modelReset() is called before AllDevicesModel's C++ handler, so at this
		// point AllDevicesModel has discarded its devices but not yet repopulated them. It does not
		// emit deviceAdded() or deviceInstanceChanged() for the change, so the lookup can only find
		// the service when AllDevicesModel is repopulated and emits modelReset().
		let serviceUidBeforeModelReset
		const resetHandler = servicesResetHandlerComponent.createObject(root, {
			servicesResetCallback: () => {
				MockManager.setValue(serviceUid + "/DeviceInstance", 21)
				serviceUidBeforeModelReset = device.serviceUid
			}
		})
		allDevicesModelResetSpy.clear()
		resetAllServices()
		resetHandler.destroy()

		compare(serviceUidBeforeModelReset, "")
		compare(allDevicesModelResetSpy.count, 1)
		compare(device.serviceUid, serviceUid)
		compare(device.productName, "Product E")
		verify(device.valid)

		device.destroy()
	}

	function test_fromServiceTypeDeviceInstance_addedAfterModelReset() {
		// Add a decoy service of the same type with a different device instance, which should
		// not be matched, before or after the reset.
		const decoyUid = "mock/com.victronenergy.f.decoy"
		MockManager.setValue(decoyUid + "/DeviceInstance", 130)
		MockManager.setValue(decoyUid + "/ProductName", "Decoy")

		// Look up a device instance that is not found yet.
		const device = deviceComponent.createObject(root)
		device.serviceType = "f"
		device.deviceInstance = 30
		compare(device.serviceUid, "")

		// The reset does not produce a match, and the lookup is still pending afterwards.
		allDevicesModelResetSpy.clear()
		resetAllServices()
		compare(allDevicesModelResetSpy.count, 1)
		compare(device.serviceUid, "")

		// When the service is added after the reset, the lookup finds it.
		const serviceUid = "mock/com.victronenergy.f.added"
		MockManager.setValue(serviceUid + "/DeviceInstance", 30)
		MockManager.setValue(serviceUid + "/ProductName", "Product F")
		compare(device.serviceUid, serviceUid)
		compare(device.productName, "Product F")
		verify(device.valid)

		device.destroy()
	}

	// Rebuilds AllServicesModel (and therefore AllDevicesModel) from the current backend producer,
	// as happens when the backend connection changes.
	function resetAllServices() {
		BackendConnection.producerChanged()
	}

	SignalSpy {
		id: allDevicesModelResetSpy
		target: AllDevicesModel
		signalName: "modelReset"
	}

	Component {
		id: servicesResetHandlerComponent

		Connections {
			property var servicesResetCallback

			target: AllServicesModel
			function onModelReset() {
				servicesResetCallback()
			}
		}
	}
}
