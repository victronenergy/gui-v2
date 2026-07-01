/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "IOChannelProxyModelTest"

	Component {
		id: outputModelComponent

		IOChannelProxyModel {
			sourceModel: VeQItemTableModel {
				uids: [ "mock/com.victronenergy.acload.abc/SwitchableOutput" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
	}

	Component {
		id: inputModelComponent

		IOChannelProxyModel {
			sourceModel: VeQItemTableModel {
				uids: [ "mock/com.victronenergy.acload.abc/GenericInput" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}
	}

	function setChannelProperties(channelProperties) {
		for (const channelData of channelProperties) {
			const uid = channelData.uid
			for (const subPath in channelData.children) {
				MockManager.setValue(uid + "/" + subPath, channelData.children[subPath])
			}
		}
	}

	function removeChannels(channelProperties) {
		for (const channelData of channelProperties) {
			MockManager.removeValue(channelData.uid)
		}
	}

	function debugModel(model) {
		console.log("Model (%1) items:".arg(model.count))
		for (let i = 0; i < model.count; i++) {
			const uid = model.data(model.index(i, 0), IOChannelProxyModel.UidRole)
			const name = model.data(model.index(i, 0), IOChannelProxyModel.NameRole)
			console.log("\t%1: uid=%2 name=%3".arg(i).arg(uid).arg(name))
		}
	}

	function test_noFilter_data() {
		return [
			{
				tag: "channel with Name: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0" },
					}
				],
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],

				// If name is removed, channel becomes hidden.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Name", value: "" },
				changedChannels: [],
			},
			{
				tag: "channel without Name: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "State": 0 },
					}
				],
				initialChannels: [],

				// If name is set, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Name", value: "something" },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "something" }],
			},
			{
				tag: "2 channelProperties, 1 with Name: 1 shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "channel0" },
					},
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/1",
						children: { "State": 0 },
					}
				],
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "channel0" }],

				// If name is set, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/1/Name", value: "something" },
				changedChannels: [
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "channel0" },
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/1", "name": "something" },
				],
			},
		]
	}

	function test_noFilter(data) {
		setChannelProperties(data.channelProperties)
		const model = outputModelComponent.createObject(root, { filterType: IOChannelProxyModel.NoFilter })

		let i
		compare(model.count, data.initialChannels.length)
		for (i = 0; i < data.initialChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.initialChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.initialChannels[i].name)
		}

		MockManager.setValue(data.change.path, data.change.value)
		compare(model.count, data.changedChannels.length)
		for (i = 0; i < data.changedChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.changedChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.changedChannels[i].name)
		}

		removeChannels(data.channelProperties)
		compare(model.sourceModel.rowCount, 0)
		compare(model.count, 0)
	}

	function test_manualFunctionFilter_data() {
		return [
			{
				tag: "manual function channel: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: {
							"Name": "manual1",
							"Settings/Function": VenusOS.SwitchableOutput_Function_Manual,
						},
					}
				],
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "manual1" }],

				// If function changes to non-manual, channel becomes hidden.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/Function", value: VenusOS.SwitchableOutput_Function_GeneratorStartStop },
				changedChannels: [],
			},
			{
				tag: "non-manual function channel: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: {
							"Name": "startstop",
							"Settings/Function": VenusOS.SwitchableOutput_Function_GeneratorStartStop,
						},
					}
				],
				initialChannels: [],

				// If function changes to manual, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/Function", value: VenusOS.SwitchableOutput_Function_Manual },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "startstop" }],
			},
			{
				tag: "mix of manual and non-manual",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: {
							"Name": "manual1",
							"Settings/Function": VenusOS.SwitchableOutput_Function_Manual,
						},
					},
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/1",
						children: {
							"Name": "alarm1",
							"Settings/Function": VenusOS.SwitchableOutput_Function_Alarm,
						},
					},
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/2",
						children: {
							"Name": "manual2",
							"Settings/Function": VenusOS.SwitchableOutput_Function_Manual,
						},
					}
				],
				initialChannels: [
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "manual1" },
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/2", "name": "manual2" },
				],

				// If function changes to manual, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/1/Settings/Function", value: VenusOS.SwitchableOutput_Function_Manual },
				changedChannels: [
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/1", "name": "alarm1" },
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "manual1" },
					{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/2", "name": "manual2" },
				],
			},
		]
	}

	function test_manualFunctionFilter(data) {
		const model = outputModelComponent.createObject(root, { filterType: IOChannelProxyModel.ManualFunction })
		setChannelProperties(data.channelProperties)

		let i
		compare(model.count, data.initialChannels.length)
		for (i = 0; i < data.initialChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.initialChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.initialChannels[i].name)
		}

		MockManager.setValue(data.change.path, data.change.value)
		compare(model.count, data.changedChannels.length)
		for (i = 0; i < data.changedChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.changedChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.changedChannels[i].name)
		}

		removeChannels(data.channelProperties)
		compare(model.sourceModel.rowCount, 0)
		compare(model.count, 0)
	}

	function test_userConfigurable_inputs_data() {
		return [
			{
				tag: "DigitalInputMode=1 with User access: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/GenericInput/0",
						children: { "Name": "input0", "Settings/DigitalInputMode": 1 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/GenericInput/0", "name": "input0" }],

				// If mode changes to 0 (disabled), channel becomes hidden.
				change: { path: "mock/com.victronenergy.acload.abc/GenericInput/0/Settings/DigitalInputMode", value: 0 },
				changedChannels: [],
			},
			{
				tag: "DigitalInputMode=0 with User access: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/GenericInput/0",
						children: { "Name": "input0", "Settings/DigitalInputMode": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [],

				// If mode changes to 1, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/GenericInput/0/Settings/DigitalInputMode", value: 1 },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/GenericInput/0", "name": "input0" }],
			},
			{
				tag: "DigitalInputMode=0 with Installer access: shown (no filtering)",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/GenericInput/0",
						children: { "Name": "input0", "Settings/DigitalInputMode": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_Installer,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/GenericInput/0", "name": "input0" }],

				// If access level changes to User, channel becomes hidden.
				change: { accessLevel: VenusOS.User_AccessType_User },
				changedChannels: [],
			},
		]
	}

	function test_userConfigurable_inputs(data) {
		const model = inputModelComponent.createObject(root, { filterType: IOChannelProxyModel.UserConfigurable })
		setChannelProperties(data.channelProperties)
		MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel", data.accessLevel)

		let i
		compare(model.count, data.initialChannels.length)
		for (i = 0; i < data.initialChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.initialChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.initialChannels[i].name)
		}

		if (data.change.path !== undefined) {
			MockManager.setValue(data.change.path, data.change.value)
		}
		if (data.change.accessLevel !== undefined) {
			MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel", data.change.accessLevel)
		}

		tryCompare(model, "count", data.changedChannels.length)
		for (i = 0; i < data.changedChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.changedChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.changedChannels[i].name)
		}

		removeChannels(data.channelProperties)
		compare(model.sourceModel.rowCount, 0)
		compare(model.count, 0)
	}

	function test_userConfigurable_outputs_data() {
		return [
			{
				tag: "SwitchMode=0 (Disabled) with User: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [],

				// If mode changes to 1, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/SwitchMode", value: 1 },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],
			},
			{
				tag: "SwitchMode=0 (Disabled) with Installer: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_Installer,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],

				// If access level changes to User, channel becomes hidden.
				change: { accessLevel: VenusOS.User_AccessType_User },
				changedChannels: [],
			},
			{
				tag: "SwitchMode=2 (Switching) with User: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 2 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],

				// If mode changes to 0 (disabled), channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/SwitchMode", value: 0 },
				changedChannels: [],
			},
			{
				tag: "SwitchMode=1 (PermanentOn), FuseDetection=0 with User: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 1, "Settings/FuseDetection": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [],

				// If FuseDetection changes to 1, channel becomes visible.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/FuseDetection", value: 1 },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],
			},
			{
				tag: "SwitchMode=1 (PermanentOn), FuseDetection=0 with Installer: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 1, "Settings/FuseDetection": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_Installer,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],

				// If access level changes to User, channel becomes hidden.
				change: { accessLevel: VenusOS.User_AccessType_User },
				changedChannels: [],
			},
			{
				tag: "SwitchMode=1 (PermanentOn), FuseDetection=1 with User: shown",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/SwitchMode": 1, "Settings/FuseDetection": 1 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],

				// If SwitchMode changes to 0, channel becomes hidden.
				change: { path: "mock/com.victronenergy.acload.abc/SwitchableOutput/0/Settings/SwitchMode", value: 0 },
				changedChannels: [],
			},
			{
				tag: "SwitchMode=invalid, FuseDetection=0 with User: hidden",
				channelProperties: [
					{
						uid: "mock/com.victronenergy.acload.abc/SwitchableOutput/0",
						children: { "Name": "output0", "Settings/FuseDetection": 0 },
					}
				],
				accessLevel: VenusOS.User_AccessType_User,
				initialChannels: [],

				// If access level changes to Installer, channel becomes visible.
				change: { accessLevel: VenusOS.User_AccessType_Installer },
				changedChannels: [{ "uid": "mock/com.victronenergy.acload.abc/SwitchableOutput/0", "name": "output0" }],
			},
		]
	}

	function test_userConfigurable_outputs(data) {
		setChannelProperties(data.channelProperties)
		const model = outputModelComponent.createObject(root, { filterType: IOChannelProxyModel.UserConfigurable })
			MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel", data.accessLevel)

		let i
		compare(model.count, data.initialChannels.length)
		for (i = 0; i < data.initialChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.initialChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.initialChannels[i].name)
		}

		if (data.change.path !== undefined) {
			MockManager.setValue(data.change.path, data.change.value)
		}
		if (data.change.accessLevel !== undefined) {
			MockManager.setValue("mock/com.victronenergy.settings/Settings/System/AccessLevel", data.change.accessLevel)
		}

		tryCompare(model, "count", data.changedChannels.length)
		for (i = 0; i < data.changedChannels.length; ++i) {
			compare(model.data(model.index(i, 0), IOChannelProxyModel.UidRole), data.changedChannels[i].uid)
			compare(model.data(model.index(i, 0), IOChannelProxyModel.NameRole), data.changedChannels[i].name)
		}

		removeChannels(data.channelProperties)
		compare(model.sourceModel.rowCount, 0)
		compare(model.count, 0)
	}
}
