/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "SwitchableOutputGroupModelTest"

	SwitchableOutputGroupModel {
		id: model
	}

	function debugModel() {
		console.log("* Model has", model.count, "groups:")
		for (let i = 0 ; i < model.count; ++i) {
			console.log("\t", model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupRole),
					model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupNameRole))
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

	function test_added_groups_data() {
		return [
			{
				tag: "1 device group with 1 output",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					}
				],
				groups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
			},
			{
				tag: "1 device group with 2 outputs",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/1/Name": "a1",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
						},
					}
				],
				groups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" },
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/1", type: 0, group: "" }
						]
					}
				],
			},
			{
				tag: "2 device groups with 1 output each",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_a_product",
							"SwitchableOutput/0/Name": "a0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					},
					{
						uid: "mock/com.victronenergy.solarcharger.b",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_b_product",
							"SwitchableOutput/0/Name": "b0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					}
				],
				groups: [
					{
						name: "solarcharger_a_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					},
					{
						name: "solarcharger_b_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.b/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
			},
			{
				tag: "2 device groups with 2 outputs each",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_a_product",
							"SwitchableOutput/0/Name": "a0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/1/Name": "a1",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
						},
					},
					{
						uid: "mock/com.victronenergy.solarcharger.b",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_b_product",
							"SwitchableOutput/0/Name": "b0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/1/Name": "b1",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
						},
					}
				],
				groups: [
					{
						name: "solarcharger_a_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" },
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/1", type: 0, group: "" },
						]
					},
					{
						name: "solarcharger_b_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.b/SwitchableOutput/0", type: 0, group: "" },
							{ uid: "mock/com.victronenergy.solarcharger.b/SwitchableOutput/1", type: 0, group: "" },
						]
					},
				]
			},
			{
				tag: "System group",
				devices: [
					{
						uid: "mock/com.victronenergy.system",
						children: {
							"SwitchableOutput/0/Name": "manual1",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Function": 2, // Manual
							"SwitchableOutput/1/Name": "startstop",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
							"SwitchableOutput/1/Settings/Function": 1, // Start/Stop (disallowed from model)
							"SwitchableOutput/2/Name": "manual2",
							"SwitchableOutput/2/State": 0,
							"SwitchableOutput/2/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/2/Settings/Type": 0,
							"SwitchableOutput/2/Settings/Function": 2, // Manual
						},
					}
				],
				groups: [
					{
						outputs: [
							{ uid: "mock/com.victronenergy.system/SwitchableOutput/0", type: 0, group: "" },
							{ uid: "mock/com.victronenergy.system/SwitchableOutput/2", type: 0, group: "" },
						]
					}
				],
			},
			{
				tag: "1 named group with 1 output",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "group1",
						},
					}
				],
				groups: [
					{
						name: "group1",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "group1" }
						]
					}
				],
			},
			{
				tag: "1 named group with 2 outputs",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a0",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "abc",
							"SwitchableOutput/1/Name": "a1",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
							"SwitchableOutput/1/Settings/Group": "abc",
						},
					}
				],
				groups: [
					{
						name: "abc",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "abc" },
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/1", type: 0, group: "abc", }
						]
					}
				],
			},
		]
	}

	function test_added_groups(data) {
		let i, j
		setDeviceProperties(data.devices)

		compare(model.count, data.groups.length)
		for (i = 0 ; i < data.groups.length; ++i) {
			if (data.groups[i].name) {
				compare(model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupNameRole), data.groups[i].name)
			}
			const group = model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupRole)
			verify(group)
			compare(group.outputs.length, data.groups[i].outputs.length)
			for (j = 0 ; j < data.groups[i].outputs.length; ++j) {
				const outputData = data.groups[i].outputs[j]
				for (const outputPropertyName in outputData) {
					compare(group.outputs[j][outputPropertyName], outputData[outputPropertyName], outputPropertyName)
				}
			}
		}

		removeDevices(data.devices)
		compare(model.count, 0)
	}

	function test_group_changes_data() {
		return [
			{
				tag: "Move output from device group to named group",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					}
				],
				initialGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/Group" : "named group"
				},
				finalGroups: [
					{
						name: "named group",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "named group" }
						]
					}
				],
			},
			{
				tag: "Move output from named group to device group",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "some group",
						},
					}
				],
				initialGroups: [
					{
						name: "some group",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "some group" }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/Group" : ""
				},
				finalGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
			},
			{
				tag: "Device becomes valid after group is created, which changes the group name",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "",
						},
					}
				],
				initialGroups: [
					{
						name: "",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/DeviceInstance" : 0,
					"mock/com.victronenergy.solarcharger.a/ProductName" : "new_product_name",
				},
				finalGroups: [
					{
						name: "new_product_name",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
			},
			{
				tag: "Remove output from device group by setting invalid type",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					}
				],
				initialGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "", allowedInGroupModel: true }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/Type": -1
				},
				finalGroups: [],
			},
			{
				tag: "Remove output from named group by setting invalid type",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "group1",
						},
					}
				],
				initialGroups: [
					{
						name: "group1",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "group1", allowedInGroupModel: true }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/Type": -1
				},
				finalGroups: [],
			},
			{
				tag: "Add output to named group by changing ShowUIControl=1",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "group1",
							"SwitchableOutput/0/Settings/ShowUIControl": 0,
						},
					}
				],
				initialGroups: [],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/ShowUIControl": 1
				},
				finalGroups: [
					{
						name: "group1",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "group1", allowedInGroupModel: true }
						]
					}
				],
			},
			{
				tag: "Add output to device group by changing ShowUIControl=1",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "",
							"SwitchableOutput/0/Settings/ShowUIControl": 0,
						},
					}
				],
				initialGroups: [],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/ShowUIControl": 1
				},
				finalGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "", allowedInGroupModel: true }
						]
					}
				],
			},
			{
				tag: "3 groups, move 2 outputs to same group",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Group": "group 1",
							"SwitchableOutput/1/Name": "b",
							"SwitchableOutput/1/State": 0,
							"SwitchableOutput/1/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/1/Settings/Type": 0,
							"SwitchableOutput/1/Settings/Group": "", // in device group
						},
					},
					{
						uid: "mock/com.victronenergy.system",
						children: {
							"SwitchableOutput/0/Name": "manual1",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
							"SwitchableOutput/0/Settings/Function": 2, // Manual
							"SwitchableOutput/0/Settings/Group": "group 2",
						},
					}
				],
				initialGroups: [
					{
						name: "group 1",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "group 1" }
						]
					},
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/1", type: 0, group: "" }
						]
					},
					{
						name: "group 2",
						outputs: [
							{ uid: "mock/com.victronenergy.system/SwitchableOutput/0", type: 0, group: "group 2" }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/SwitchableOutput/0/Settings/Group" : "group 2"
				},
				finalGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/1", type: 0, group: "" }
						]
					},
					{
						name: "group 2",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "group 2" },
							{ uid: "mock/com.victronenergy.system/SwitchableOutput/0", type: 0, group: "group 2" },
						]
					}
				],
			},
			{
				tag: "Device group, change device name",
				devices: [
					{
						uid: "mock/com.victronenergy.solarcharger.a",
						children: {
							DeviceInstance: 0,
							ProductName: "solarcharger_product",
							"SwitchableOutput/0/Name": "a",
							"SwitchableOutput/0/State": 0,
							"SwitchableOutput/0/Settings/ValidTypes": (1 << 0),
							"SwitchableOutput/0/Settings/Type": 0,
						},
					}
				],
				initialGroups: [
					{
						name: "solarcharger_product",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
				changes: {
					"mock/com.victronenergy.solarcharger.a/CustomName" : "New solarcharger name"
				},
				finalGroups: [
					{
						name: "New solarcharger name",
						outputs: [
							{ uid: "mock/com.victronenergy.solarcharger.a/SwitchableOutput/0", type: 0, group: "" }
						]
					}
				],
			},
		]
	}

	function test_group_changes(data) {
		let i, j, group, outputPropertyName, outputData
		setDeviceProperties(data.devices)

		compare(model.count, data.initialGroups.length)
		for (i = 0 ; i < data.initialGroups.length; ++i) {
			if (data.initialGroups[i].name) {
				compare(model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupNameRole), data.initialGroups[i].name)
			}
			group = model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupRole)
			verify(group)
			compare(group.outputs.length, data.initialGroups[i].outputs.length)
			for (j = 0 ; j < data.initialGroups[i].outputs.length; ++j) {
				const outputData = data.initialGroups[i].outputs[j]
				for (outputPropertyName in outputData) {
					compare(group.outputs[j][outputPropertyName], outputData[outputPropertyName], outputPropertyName)
				}
			}
		}

		for (const propertyChange in data.changes) {
			MockManager.setValue(propertyChange, data.changes[propertyChange])
		}

		compare(model.count, data.finalGroups.length)
		for (i = 0 ; i < data.finalGroups.length; ++i) {
			if (data.finalGroups[i].name) {
				compare(model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupNameRole), data.finalGroups[i].name)
			}
			group = model.data(model.index(i, 0), SwitchableOutputGroupModel.GroupRole)
			verify(group)
			compare(group.outputs.length, data.finalGroups[i].outputs.length)
			for (j = 0 ; j < data.finalGroups[i].outputs.length; ++j) {
				outputData = data.finalGroups[i].outputs[j]
				for (outputPropertyName in outputData) {
					compare(group.outputs[j][outputPropertyName], outputData[outputPropertyName], outputPropertyName)
				}
			}
		}

		removeDevices(data.devices)
		compare(model.count, 0)
	}
}
