/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "GenericInputTest"

	GenericInput {
		id: input
	}

	function debugInput(properties) {
		console.log(input.uid)
		for (const propertyName in properties) {
			console.log(propertyName, "=", input[propertyName])
		}
	}

	function setInputProperties(uid, properties) {
		for (const subPath in properties) {
			MockManager.setValue(uid + "/" + subPath, properties[subPath])
		}
	}

	function test_simple_properties_data() {
		return [
			{
				tag: "channelId - numeric",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Name": "Foo" },
				expected: { channelId: "1" },
			},
			{
				tag: "channelId - letter",
				uid: "mock/com.victronenergy.test.a/GenericInput/A",
				inputProperties: { "Name": "Foo" },
				expected: { channelId: "A" },
			},

			{
				tag: "serviceUid",
				uid: "mock/com.victronenergy.test.a/GenericInput/A",
				inputProperties: { "Name": "Foo" },
				expected: { serviceUid: "mock/com.victronenergy.test.a" },
			},

			{
				tag: "status - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // status not set
				expected: { status: 0 },
			},
			{
				tag: "status - 0",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Status": 0 },
				expected: { status: 0 },
			},
			{
				tag: "status - 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Status": 1 },
				expected: { status: 1 },
			},

			{
				tag: "value - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // value not set
				expected: { value: 0 },
			},
			{
				tag: "value - float 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1.23 },
				expected: { value: 1.23 },
			},
			{
				tag: "value - float 2",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 12345.67 },
				expected: { value: 12345.67 },
			},
			{
				tag: "value - int 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1 },
				expected: { value: 1 },
			},
			{
				tag: "value - int 2",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1234567 },
				expected: { value: 1234567 },
			},
			{
				tag: "value - zero",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" },
				expected: { value: 0 },
			},

			{
				tag: "rangeMin - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // min not set
				expected: { rangeMin: 0 },
			},
			{
				tag: "rangeMin - float",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/RangeMin": 1.23 },
				expected: { rangeMin: 1.23 },
			},

			{
				tag: "rangeMax - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // max not set
				expected: { rangeMax: 100 },
			},
			{
				tag: "rangeMax - float",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/RangeMax": 3.45 },
				expected: { rangeMax: 3.45 },
			},

			{
				tag: "decimals - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" },
				expected: { decimals: 0 },
			},
			{
				tag: "decimals - 0",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Decimals": 0 },
				expected: { decimals: 0 },
			},
			{
				tag: "decimals - 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Decimals": 1 },
				expected: { decimals: 1 },
			},

			{
				tag: "type - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // type not set
				expected: { type: -1 },
			},
			{
				tag: "type - -1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": -1 },
				expected: { type: -1 },
			},
			{
				tag: "type - 0",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 0 },
				expected: { type: 0 },
			},
			{
				tag: "type - 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 1 },
				expected: { type: 1 },
			},

			{
				tag: "group - invalid",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" }, // group not set
				expected: { group: "" },
			},
			{
				tag: "group - empty",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Group": "" },
				expected: { group: "" },
			},
			{
				tag: "group - non-empty",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Group": "x" },
				expected: { group: "x" },
			},
		]
	}

	function test_simple_properties(data) {
		// Test defaults
		compare(input.uid, "")
		compare(input.channelId, "")
		compare(input.serviceUid, "")
		compare(input.formattedName, "")
		compare(input.status, 0)
		compare(input.value, 0)
		compare(input.rangeMin, 0)
		compare(input.rangeMax, 100)
		compare(input.decimals, 0)
		compare(input.type, -1)
		compare(input.group, "")
		compare(input.allowedInGroupModel, false)

		// Set test values and verify the properties are correct.
		setInputProperties(data.uid, data.inputProperties)
		input.uid = data.uid
		compare(input.uid, data.uid)
		for (const propertyName in data.expected) {
			compare(input[propertyName], data.expected[propertyName], propertyName)
		}

		// Clean up
		input.uid = ""
		MockManager.removeValue(data.uid)

		// Test defaults again
		compare(input.uid, "")
		compare(input.channelId, "")
		compare(input.serviceUid, "")
		compare(input.formattedName, "")
		compare(input.status, 0)
		compare(input.value, 0)
		compare(input.rangeMin, 0)
		compare(input.rangeMax, 100)
		compare(input.decimals, 0)
		compare(input.type, -1)
		compare(input.group, "")
		compare(input.allowedInGroupModel, false)
	}

	function test_allowedInGroupModel_data() {
		return [
			{
				tag: "Invalid type",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/Type": -1, },
				hasValidType: false,
				allowedInGroupModel: false,
			},
			{
				tag: "ValidTypes matched",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ValidTypes matched, but Type is out of bounds",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/Type": VenusOS.GenericInput_Type_MaxSupportedType + 1,
					"Settings/ValidTypes": 1 << (VenusOS.GenericInput_Type_MaxSupportedType + 1),
				},
				hasValidType: false,
				allowedInGroupModel: false,
			},
			{
				tag: "ValidTypes matches 1st type",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/Type": 1, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ValidTypes matches 2nd type",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/Type": 2, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ValidTypes not matched for either type",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/Type": 0, "Settings/ValidTypes": ((1 << 1) | (1 << 2)) },
				hasValidType: false,
				allowedInGroupModel: false,
			},

			{
				tag: "ShowUIInput=1, other params valid",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/ShowUIInput": 1, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=0, other params valid",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/ShowUIInput": 0, "Settings/Type": 0, "Settings/ValidTypes": 1 << 0 },
				hasValidType: true,
				allowedInGroupModel: false,
			},
			{
				tag: "ShowUIInput=1, ValidTypes not matched",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: { "Settings/ShowUIInput": 1, "Settings/Type": 0 },
				hasValidType: false,
				allowedInGroupModel: false,
			},
		]
	}

	function test_allowedInGroupModel(data) {
		compare(input.hasValidType, false)
		compare(input.allowedInGroupModel, false)

		setInputProperties(data.uid, data.inputProperties)
		input.uid = data.uid
		compare(input.uid, data.uid)
		compare(input.hasValidType, data.hasValidType)
		compare(input.allowedInGroupModel, data.allowedInGroupModel)

		// Clean up
		input.uid = ""
		MockManager.removeValue(data.uid)
	}

	function test_showUiInput_data() {
		return [
			{
				tag: "ShowUIInput not set",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=Off",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 0, // Off=0
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				allowedInGroupModel: false,
			},
			{
				tag: "ShowUIInput=Always",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 1, // Always=1
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=Local",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 2, // Local=0x2
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				vrm: false,
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=Remote",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 4, // Remote=0x4
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				vrm: true,
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=Local+Remote, local connection",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 6, // Local+Remote = 0x2 | 0x4
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				vrm: false,
				allowedInGroupModel: true,
			},
			{
				tag: "ShowUIInput=Local+Remote, remote connection",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 6, // Local+Remote = 0x2 | 0x4
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				vrm: true,
				allowedInGroupModel: true,
			},
			{
				// If value is invalid, then show the control (just like if ShowUIInput is not set)
				tag: "ShowUIInput=0x5 (invalid)",
				uid: "mock/com.victronenergy.test.a/GenericInput/1",
				inputProperties: {
					"Settings/ShowUIInput": 5,
					"Settings/Type": 0, "Settings/ValidTypes": 1 << 0
				},
				allowedInGroupModel: true,
			},
		]
	}

	function test_showUiInput(data) {
		compare(input.allowedInGroupModel, false)
		if (data.vrm !== undefined) {
			BackendConnection.vrm = data.vrm
		}

		setInputProperties(data.uid, data.inputProperties)
		input.uid = data.uid
		compare(input.uid, data.uid)
		compare(input.allowedInGroupModel, data.allowedInGroupModel)

		// Clean up
		input.uid = ""
		MockManager.removeValue(data.uid)
		BackendConnection.vrm = false
	}

	function test_formattedName_data() {
		return [
			{
				tag: "use custom name",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "", "Settings/CustomName": "Blah", },
				formattedName: "Blah",
			},
			{
				tag: "no custom name, no group: use /Name",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "" },
				formattedName: "A",
			},
			{
				tag: "no custom name, in group: use device product name",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "test" },
				deviceValues: {
					"mock/com.victronenergy.test.a/ProductName": "Test product",
					"mock/com.victronenergy.test.a/DeviceInstance": 1,
				},
				formattedName: "Test product (1) | A",
			},
			{
				tag: "no custom name, in group: use device custom name",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Type": 0, "Name": "A", "Settings/Group": "test" },
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
		compare(input.formattedName, "")

		setInputProperties(data.uid, data.inputProperties)
		if (data.deviceValues) {
			for (propertyName in data.deviceValues) {
				MockManager.setValue(propertyName, data.deviceValues[propertyName])
			}
		}

		input.uid = data.uid
		compare(input.uid, data.uid)
		compare(input.formattedName, data.formattedName)

		// Clean up
		input.uid = ""
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
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Name": "Foo" },
				unitType: VenusOS.Units_None,
				unitText: "",
			},
			{
				tag: "custom unit",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Unit": "test test" },
				unitType: VenusOS.Units_None,
				unitText: "test test",
			},
			{
				tag: "speed",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Unit": "/Speed" },
				unitType: VenusOS.Units_Speed_MetresPerSecond,
				unitText: "/Speed",
			},
			{
				tag: "temperature",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Unit": "/Temperature" },
				unitType: VenusOS.Units_Temperature_Celsius,
				unitText: "/Temperature",
			},
			{
				tag: "volume",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Settings/Unit": "/Volume" },
				unitType: VenusOS.Units_Volume_CubicMetre,
				unitText: "/Volume",
			},
		]
	}

	function test_unit(data) {
		compare(input.unitType, VenusOS.Units_None)
		compare(input.unitText, "")

		setInputProperties(data.uid, data.inputProperties)
		input.uid = data.uid
		compare(input.unitType, data.unitType)
		compare(input.unitText, data.unitText)

		// Clean up
		input.uid = ""
		MockManager.removeValue(data.uid)
	}


	function test_textValue_data() {
		return [
			{
				tag: "no labels",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": "0" },
				textValue: "",
			},
			{
				tag: "low-high: low",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/low-high" },
				textValue: qsTrId("generic_input_label_low"),
			},
			{
				tag: "low-high: high",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/low-high" },
				textValue: qsTrId("generic_input_label_high"),
			},
			{
				tag: "off-on: off",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/off-on" },
				textValue: qsTrId("generic_input_label_off"),
			},
			{
				tag: "off-on: on",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/off-on" },
				textValue: qsTrId("generic_input_label_on"),
			},
			{
				tag: "no-yes: no",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/no-yes" },
				textValue: qsTrId("generic_input_label_no"),
			},
			{
				tag: "no-yes: yes",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/no-yes" },
				textValue: qsTrId("generic_input_label_yes"),
			},
			{
				tag: "open-closed: open",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/open-closed" },
				textValue: qsTrId("generic_input_label_open"),
			},
			{
				tag: "open-closed: closed",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/open-closed" },
				textValue: qsTrId("generic_input_label_closed"),
			},
			{
				tag: "ok-alarm: ok",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/ok-alarm" },
				textValue: qsTrId("generic_input_label_ok"),
			},
			{
				tag: "ok-alarm: alarm",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/ok-alarm" },
				textValue: qsTrId("generic_input_label_alarm"),
			},
			{
				tag: "stopped-running: stopped",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "/stopped-running" },
				textValue: qsTrId("generic_input_label_stopped"),
			},
			{
				tag: "stopped-running: running",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "/stopped-running" },
				textValue: qsTrId("generic_input_label_running"),
			},
			{
				tag: "custom label: option 0",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 0, "Settings/Labels": "off|eco|auto" },
				textValue: "off",
			},
			{
				tag: "custom label: option 1",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": 1, "Settings/Labels": "off|eco|auto" },
				textValue: "eco",
			},
			{
				tag: "custom label: option 2",
				uid: "mock/com.victronenergy.test.a/GenericInput/0",
				inputProperties: { "Value": "2", "Settings/Labels": "off|eco|auto" },
				textValue: "auto",
			},
		]
	}

	function test_textValue(data) {
		compare(input.textValue, "")

		setInputProperties(data.uid, data.inputProperties)
		input.uid = data.uid
		compare(input.textValue, data.textValue)

		// Clean up
		input.uid = ""
		MockManager.removeValue(data.uid)
	}
}
