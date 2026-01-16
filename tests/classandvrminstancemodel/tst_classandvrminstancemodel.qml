/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "ClassAndVrmInstanceModelTest"

	Component {
		id: modelComponent
		ClassAndVrmInstanceModel {}
	}

	Component {
		id: sortedModelComponent
		SortedClassAndVrmInstanceModel {}
	}

	Component {
		id: filteredModelComponent
		FilteredClassAndVrmInstanceModel {}
	}

	function debugModel(model) {
		console.log("* Model count:", model.count)
		for (let i = 0 ; i < model.count; ++i) {
			let roleData = []
			for (const roleName of ["valid", "uid", "vrmInstance", "deviceClass", "name"]) {
				roleData.push("%1=%2".arg(roleName).arg(model.data(model.index(i, 0), root.roleFromName(roleName))))
			}
			console.log("\t", roleData.join(", "))
		}
	}

	function roleFromName(roleName) {
		switch (roleName) {
		case "valid": return ClassAndVrmInstanceModel.ValidRole
		case "uid": return ClassAndVrmInstanceModel.UidRole
		case "vrmInstance": return ClassAndVrmInstanceModel.VrmInstanceRole
		case "deviceClass": return ClassAndVrmInstanceModel.DeviceClassRole
		case "name": return ClassAndVrmInstanceModel.NameRole
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

	function test_entries_data() {
		return [
			{
				tag: "1 device",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "",
					}
				],
			},
			{
				tag: "1 device with /CustomName from settings",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
							"CustomName": "My tank",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "My tank",
					}
				],
			},
			{
				tag: "1 device with /CustomName from device",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
						},
					},
					{
						uid: "mock/com.victronenergy.tank.ttyO1",
						children: {
							"DeviceInstance": 1,
							"ProductName": "Test tank",
							"CustomName": "My tank",
						},
					},
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "My tank",
					}
				],
			},
			{
				tag: "Multiple devices",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/B",
						children: {
							"ClassAndVrmInstance": "solarcharger:987",
							"CustomName": "charger",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/C",
						children: {
							"ClassAndVrmInstance": "acload:34",
						},
					},
					{
						uid: "mock/com.victronenergy.acload.ttyO1",
						children: {
							"DeviceInstance": 34,
							"ProductName": "Test AC load",
							"CustomName": "My AC load",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/X",
						children: {
							"ClassAndVrmInstance": "solarcharger:123",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/Y",
						children: {
							"ClassAndVrmInstance": "acload:1001",
						},
					},
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/B/ClassAndVrmInstance",
						vrmInstance: 987,
						deviceClass: "solarcharger",
						name: "charger",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/C/ClassAndVrmInstance",
						vrmInstance: 34,
						deviceClass: "acload",
						name: "My AC load",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/X/ClassAndVrmInstance",
						vrmInstance: 123,
						deviceClass: "solarcharger",
						name: "",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/Y/ClassAndVrmInstance",
						vrmInstance: 1001,
						deviceClass: "acload",
						name: "",
					},
				],
			},
		]
	}

	function test_entries(data) {
		let deviceClass
		setDeviceProperties(data.devices)
		const model = modelComponent.createObject(root)
		debugModel(model)

		compare(model.count, data.expectedData.length)
		let maxVrmInstances = {}
		for (let i = 0 ; i < data.expectedData.length; ++i) {
			for (const roleName in data.expectedData[i]) {
				compare(model.data(model.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
			deviceClass = model.data(model.index(i, 0), root.roleFromName("deviceClass"))
			const vrmInstance = model.data(model.index(i, 0), root.roleFromName("vrmInstance"))
			compare(model.findInstanceUid(deviceClass, vrmInstance), model.data(model.index(i, 0), root.roleFromName("uid")))
			maxVrmInstances[deviceClass] = Math.max(maxVrmInstances[deviceClass] || 0, vrmInstance)
		}
		for (deviceClass in maxVrmInstances) {
			compare(model.maximumVrmInstance(deviceClass), maxVrmInstances[deviceClass])
		}

		removeDevices(data.devices || [])
		compare(model.count, 0)
		model.destroy()
	}

	function test_sorted_data() {
		return [
			{
				tag: "1 device",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "",
					}
				],
			},
			{
				tag: "Compare by custom name",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/B",
						children: {
							"ClassAndVrmInstance": "tank:2",
							"CustomName": "B",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "tank:1",
							"CustomName": "A",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "tank",
						name: "A",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/B/ClassAndVrmInstance",
						vrmInstance: 2,
						deviceClass: "tank",
						name: "B",
					}
				],
			},
			{
				tag: "Compare by device class",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/B",
						children: {
							"ClassAndVrmInstance": "tank:2",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "motordrive:1",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "motordrive",
						name: "",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/B/ClassAndVrmInstance",
						vrmInstance: 2,
						deviceClass: "tank",
						name: "",
					}
				],
			},
			{
				tag: "Compare by vrm instance",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/B",
						children: {
							"ClassAndVrmInstance": "motordrive:2",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "motordrive:1",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "motordrive",
						name: "",
					},
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/B/ClassAndVrmInstance",
						vrmInstance: 2,
						deviceClass: "motordrive",
						name: "",
					}
				],
			},
		];
	}

	function test_sorted(data) {
		setDeviceProperties(data.devices)
		const model = modelComponent.createObject(root)
		const sortedModel = sortedModelComponent.createObject(root)
		sortedModel.sourceModel = model

		compare(sortedModel.rowCount(), data.expectedData.length)
		for (let i = 0 ; i < data.expectedData.length; ++i) {
			for (const roleName in data.expectedData[i]) {
				compare(sortedModel.data(sortedModel.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
		}

		removeDevices(data.devices || [])
		compare(sortedModel.rowCount(), 0)
		sortedModel.destroy()
		model.destroy()
	}

	function test_filtered_data() {
		return [
			{
				tag: "1 device",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "motordrive:1",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "motordrive",
						name: "",
					}
				],
			},
			{
				tag: "1 tank, 1 motordrive",
				devices: [
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/A",
						children: {
							"ClassAndVrmInstance": "motordrive:1",
						},
					},
					{
						uid: "mock/com.victronenergy.settings/Settings/Devices/B",
						children: {
							"ClassAndVrmInstance": "tank:2",
						},
					}
				],
				expectedData: [
					{
						valid: true,
						uid: "mock/com.victronenergy.settings/Settings/Devices/A/ClassAndVrmInstance",
						vrmInstance: 1,
						deviceClass: "motordrive",
						name: "",
					}
				],
			},
		];
	}

	function test_filtered(data) {
		setDeviceProperties(data.devices)
		const model = modelComponent.createObject(root)
		const filteredModel = filteredModelComponent.createObject(root)
		filteredModel.sourceModel = model
		filteredModel.deviceClasses = ["motordrive"]

		compare(filteredModel.rowCount(), data.expectedData.length)
		for (let i = 0 ; i < data.expectedData.length; ++i) {
			for (const roleName in data.expectedData[i]) {
				compare(filteredModel.data(filteredModel.index(i, 0), root.roleFromName(roleName)), data.expectedData[i][roleName], roleName)
			}
		}

		removeDevices(data.devices || [])
		compare(filteredModel.rowCount(), 0)
		filteredModel.destroy()
		model.destroy()
	}
}
