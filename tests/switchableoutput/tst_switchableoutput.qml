/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "SwitchableOutputTest"

	SwitchableOutput {
		id: output
	}

	function debugOutput(properties) {
		console.log(output.uid)
		for (const propertyName in properties) {
			console.log(propertyName, "=", output[propertyName])
		}
	}

	function setOutputProperties(uid, properties) {
		for (const subPath in properties) {
			MockManager.setValue(uid + "/" + subPath, properties[subPath])
		}
	}

	function test_simple_properties_data() {
		return [
			{
				tag: "outputId - numeric",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0 },
				expected: { outputId: "1" },
			},
			{
				tag: "outputId - letter",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/A",
				outputProperties: { "State": 0 },
				expected: { outputId: "A" },
			},

			{
				tag: "serviceUid - system",
				uid: "mock/com.victronenergy.system/SwitchableOutput/A",
				outputProperties: { "State": 0 },
				expected: { serviceUid: "mock/com.victronenergy.system" },
			},
			{
				tag: "serviceUid - other",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/A",
				outputProperties: { "State": 0 },
				expected: { serviceUid: "mock/com.victronenergy.test.a" },
			},

			{
				tag: "state - invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Status": 0 }, // state not set
				expected: { state: 0 },
			},
			{
				tag: "state - 0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 0 },
				expected: { state: 0 },
			},
			{
				tag: "state - 1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 1 },
				expected: { state: 1 },
			},

			{
				tag: "status - invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 0 }, // status not set
				expected: { status: 0 },
			},
			{
				tag: "status - 0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Status": 0 },
				expected: { status: 0 },
			},
			{
				tag: "status - 1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Status": 1 },
				expected: { status: 1 },
			},

			{
				tag: "dimming - invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 0 }, // dimming not set
				expected: { dimming: 0 },
			},
			{
				tag: "dimming - float 1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Dimming": 1.23 },
				expected: { dimming: 1.23 },
			},
			{
				tag: "dimming - float 2",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Dimming": 12345.67 },
				expected: { dimming: 12345.67 },
			},
			{
				tag: "dimming - int 1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Dimming": 1 },
				expected: { dimming: 1 },
			},
			{
				tag: "dimming - int 2",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Dimming": 1234567 },
				expected: { dimming: 1234567 },
			},
			{
				tag: "dimming - zero",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Dimming": 0 },
				expected: { dimming: 0 },
			},

			{
				tag: "type - invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 0 }, // type not set
				expected: { type: -1 },
			},
			{
				tag: "type - -1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": -1 },
				expected: { type: -1 },
			},
			{
				tag: "type - 0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 0 },
				expected: { type: 0 },
			},
			{
				tag: "type - 1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 1 },
				expected: { type: 1 },
			},

			{
				tag: "group - invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "State": 0 }, // group not set
				expected: { group: "" },
			},
			{
				tag: "group - empty",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Group": "" },
				expected: { group: "" },
			},
			{
				tag: "group - non-empty",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Group": "x" },
				expected: { group: "x" },
			},
		]
	}

	function test_simple_properties(data) {
		// Test defaults
		compare(output.uid, "")
		compare(output.outputId, "")
		compare(output.serviceUid, "")
		compare(output.formattedName, "")
		compare(output.state, 0)
		compare(output.status, 0)
		compare(output.dimming, 0)
		compare(output.type, -1)
		compare(output.group, "")
		compare(output.allowedInGroupModel, false)

		// Set test values and verify the properties are correct.
		setOutputProperties(data.uid, data.outputProperties)
		output.uid = data.uid
		compare(output.uid, data.uid)
		for (const propertyName in data.expected) {
			compare(output[propertyName], data.expected[propertyName], propertyName)
		}

		// Clean up
		output.uid = ""
		MockManager.removeValue(data.uid)

		// Test defaults again
		compare(output.uid, "")
		compare(output.outputId, "")
		compare(output.serviceUid, "")
		compare(output.formattedName, "")
		compare(output.state, 0)
		compare(output.status, 0)
		compare(output.dimming, 0)
		compare(output.type, -1)
		compare(output.group, "")
		compare(output.allowedInGroupModel, false)
	}

	function test_allowedInGroupModel_data() {
		return [
			{
				tag: "Type invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/Type": -1, },
				allowedInGroupModel: false,
			},
			{
				tag: "Type valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/Type": 0, },
				allowedInGroupModel: true,
			},

			{
				// If ShowUIControl is not set, but Type is ok, then output is allowed.
				tag: "ShowUIControl not set, type valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/Type": 0 },
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIControl=1, type valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 1, "Settings/Type": 0 },
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIControl=0, type valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 0, "Settings/Type": 0 },
				allowedInGroupModel: false,
			},
			{
				tag: "ShowUIControl=1, type invalid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 1, "Settings/Type": -1 },
				allowedInGroupModel: false,
			},

			{
				tag: "Relay function = manual",
				uid: "mock/com.victronenergy.system/SwitchableOutput/1",
				outputProperties: { "Settings/Type": 0, "Settings/Function": 2 },
				allowedInGroupModel: true,
			},
			{
				tag: "Relay function = start/stop",
				uid: "mock/com.victronenergy.system/SwitchableOutput/1",
				outputProperties: { "Settings/Type": 0, "Settings/Function": 1 },
				allowedInGroupModel: false,
			},
		]
	}

	function test_allowedInGroupModel(data) {
		compare(output.allowedInGroupModel, false)

		setOutputProperties(data.uid, data.outputProperties)
		output.uid = data.uid
		compare(output.uid, data.uid)
		compare(output.allowedInGroupModel, data.allowedInGroupModel)

		// Clean up
		output.uid = ""
		MockManager.removeValue(data.uid)
	}

	function test_formattedName_data() {
		return [
			{
				tag: "use custom name",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "", "Settings/CustomName": "Blah", },
				formattedName: "Blah",
			},
			{
				tag: "no custom name, no group: use /Name",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "" },
				formattedName: "A",
			},
			{
				tag: "no custom name, in group: use device product name",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "test" },
				deviceValues: {
					"mock/com.victronenergy.test.a/ProductName": "Test product",
					"mock/com.victronenergy.test.a/DeviceInstance": 1,
				},
				formattedName: "Test product (1) | A",
			},
			{
				tag: "no custom name, in group: use device custom name",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "test" },
				deviceValues: {
					"mock/com.victronenergy.test.a/ProductName": "Test product",
					"mock/com.victronenergy.test.a/ProductName": "Test custom",
					"mock/com.victronenergy.test.a/DeviceInstance": 1,
				},
				formattedName: "Test custom (1) | A",
			},
		]
	}

	function test_formattedName(data) {
		let propertyName
		compare(output.formattedName, "")

		setOutputProperties(data.uid, data.outputProperties)
		if (data.deviceValues) {
			for (propertyName in data.deviceValues) {
				MockManager.setValue(propertyName, data.deviceValues[propertyName])
			}
		}

		output.uid = data.uid
		compare(output.uid, data.uid)
		compare(output.formattedName, data.formattedName)

		// Clean up
		output.uid = ""
		MockManager.removeValue(data.uid)
		if (data.deviceValues) {
			for (propertyName in data.deviceValues) {
				MockManager.removeValue(propertyName)
			}
		}
	}
}
