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
				tag: "State valid, invalid type",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0, "Settings/Type": -1, },
				hasValidType: false,
				allowedInGroupModel: false,
			},
			{
				tag: "State valid, ValidTypes matched",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "State valid, ValidTypes matched, but Type is out of bounds",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: {
					"State": 0,
					"Settings/Type": VenusOS.SwitchableOutput_Type_MaxSupportedType + 1,
					"Settings/ValidTypes": 1 << (VenusOS.SwitchableOutput_Type_MaxSupportedType + 1),
				},
				hasValidType: false,
				allowedInGroupModel: false,
			},
			{
				tag: "Dimming valid but no State, ValidTypes matched",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Dimming": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "Neither State nor Dimming valid, ValidTypes matched",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: false,
			},

			{
				tag: "ValidTypes matches 1st type",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0, "Settings/Type": 1, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ValidTypes matches 2nd type",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0, "Settings/Type": 2, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ValidTypes not matched for either type",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "State": 0, "Settings/Type": 0, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: false,
				allowedInGroupModel: false,
			},

			{
				tag: "ShowUIControl=1, other params valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 1, "State": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIControl=0, other params valid",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 0, "State": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: false,
			},
			{
				tag: "ShowUIControl=1, ValidTypes not matched",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/1",
				outputProperties: { "Settings/ShowUIControl": 1, "State": 0, "Settings/Type": 0 },
				hasValidType: false,
				allowedInGroupModel: false,
			},

			{
				tag: "Relay function = manual, other params valid",
				uid: "mock/com.victronenergy.system/SwitchableOutput/1",
				outputProperties: { "Settings/Function": 2, "State": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "Relay function = start/stop, other params valid",
				uid: "mock/com.victronenergy.system/SwitchableOutput/1",
				outputProperties: { "Settings/Function": 1, "State": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0},
				hasValidType: true,
				allowedInGroupModel: false,
			},
		]
	}

	function test_allowedInGroupModel(data) {
		compare(output.hasValidType, false)
		compare(output.allowedInGroupModel, false)

		setOutputProperties(data.uid, data.outputProperties)
		output.uid = data.uid
		compare(output.uid, data.uid)
		compare(output.hasValidType, data.hasValidType)
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

	function test_unit_data() {
		return [
			{
				tag: "no unit",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { State: 0 }, // add dummy value to ensure output has some properties
				unitType: VenusOS.Units_None,
				unitText: "",
			},
			{
				tag: "custom unit",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Unit": "test test" },
				unitType: VenusOS.Units_None,
				unitText: "test test",
			},
			{
				tag: "speed",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Unit": "\\S" },
				unitType: VenusOS.Units_Speed_MetresPerSecond,
				unitText: "\\S",
			},
			{
				tag: "temperature",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Unit": "\\T" },
				unitType: VenusOS.Units_Temperature_Celsius,
				unitText: "\\T",
			},
			{
				tag: "volume",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "Settings/Unit": "\\V" },
				unitType: VenusOS.Units_Volume_CubicMetre,
				unitText: "\\V",
			},
		]
	}

	function test_unit(data) {
		compare(output.unitType, VenusOS.Units_None)
		compare(output.unitText, "")

		setOutputProperties(data.uid, data.outputProperties)
		output.uid = data.uid
		compare(output.unitType, data.unitType)
		compare(output.unitText, data.unitText)

		// Clean up
		output.uid = ""
		MockManager.removeValue(data.uid)
	}

	function test_decimals_data() {
		return [
			{
				tag: "no Decimals nor StepSize",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { State: 0 }, // add dummy value to ensure output has some properties
				decimals: 0,
			},
			{
				tag: "Decimals=0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/Decimals": 0 },
				decimals: 0,
			},
			{
				tag: "StepSize=0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/StepSize": 0 },
				decimals: 0,
			},
			{
				tag: "Decimals=1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/Decimals": 1 },
				decimals: 1,
			},
			{
				tag: "StepSize=1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/StepSize": 1 },
				decimals: 1,
			},
			{
				tag: "Decimals=0, StepSize=0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/Decimals": 0, "/Settings/StepSize": 0 },
				decimals: 0,
			},
			{
				tag: "Decimals=0, StepSize=1",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/Decimals": 0, "/Settings/StepSize": 1 },
				decimals: 0, // Decimals override
			},
			{
				tag: "Decimals=1, StepSize=0",
				uid: "mock/com.victronenergy.test.a/SwitchableOutput/0",
				outputProperties: { "/Settings/Decimals": 1, "/Settings/StepSize": 0 },
				decimals: 1, // Decimals override
			},
		]
	}

	function test_decimals(data) {
		compare(output.decimals, 0)

		setOutputProperties(data.uid, data.outputProperties)
		output.uid = data.uid
		compare(output.decimals, output.decimals)

		// Clean up
		output.uid = ""
		MockManager.removeValue(data.uid)
	}
}
