/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginDataItemTest"

	PluginDataItem {
		id: dataItem
	}

	PluginDataItem {
		id: deviceItem
	}

	property var createdServiceUids: []

	SignalSpy {
		id: minSpy
		target: dataItem
		signalName: "minChanged"
	}

	SignalSpy {
		id: maxSpy
		target: dataItem
		signalName: "maxChanged"
	}

	function test_minMax_data() {
		return [
			{
				tag: "no uid",
				uid: "",
				limits: {},
				expectedMin: NaN,
				expectedMax: NaN,
			},
			{
				tag: "no limits given",
				uid: "mock/com.victronenergy.test.a/NoLimits",
				limits: {},
				expectedMin: NaN,
				expectedMax: NaN,
			},
			{
				tag: "limits given, with a minimum of 0",
				uid: "mock/com.victronenergy.test.a/Limits",
				limits: { min: 0, max: 32 },
				expectedMin: 0,
				expectedMax: 32,
			},
		]
	}

	function test_minMax(data) {
		if (data.uid !== "") {
			MockManager.setValue(data.uid, 5)
			for (const name in data.limits) {
				MockManager.setProperty(data.uid, name, data.limits[name])
			}
		}
		dataItem.uid = data.uid
		compare(dataItem.min, data.expectedMin)
		compare(dataItem.max, data.expectedMax)
	}

	function cleanup() {
		for (let i = 0; i < createdServiceUids.length; ++i) {
			MockManager.removeValue(createdServiceUids[i])
		}
		createdServiceUids = []
		deviceItem.deviceInstance = -1
		deviceItem.serviceType = ""
		deviceItem.path = ""
	}

	function addDevice(uid, deviceInstance) {
		createdServiceUids.push(uid)
		MockManager.setValue(uid + "/DeviceInstance", deviceInstance)
		MockManager.setValue(uid + "/ProductName", "Plugin data item test")
		MockManager.setValue(uid + "/Dc/0/Voltage", 12.5)
	}

	function test_singleInstanceServiceLeavesDeviceInstanceUnset() {
		compare(deviceItem.deviceInstance, -1)
		deviceItem.serviceType = "settings"
		deviceItem.path = "/Settings/System/AccessLevel"
		compare(deviceItem.uid, "mock/com.victronenergy.settings/Settings/System/AccessLevel")
	}

	function test_deviceInstanceFollowsTheDevice() {
		const lateUid = "mock/com.victronenergy.battery.pdi_late"
		const otherUid = "mock/com.victronenergy.battery.pdi_other"
		const zeroUid = "mock/com.victronenergy.battery.pdi_zero"

		// The device is not on the system yet.
		deviceItem.serviceType = "battery"
		deviceItem.deviceInstance = 9101
		deviceItem.path = "/Dc/0/Voltage"
		compare(deviceItem.uid, "")
		compare(deviceItem.valid, false)

		addDevice(lateUid, 9101)
		compare(deviceItem.uid, lateUid + "/Dc/0/Voltage")
		compare(deviceItem.valid, true)
		compare(deviceItem.value, 12.5)

		// A suffix is part of the service uid. Instance 0 is not serviceUidForType().
		addDevice(zeroUid, 0)
		deviceItem.deviceInstance = 0
		compare(deviceItem.uid, zeroUid + "/Dc/0/Voltage")
		verify(deviceItem.uid !== "mock/com.victronenergy.battery/Dc/0/Voltage")

		// Another device with a different instance is not used.
		addDevice(otherUid, 9102)
		compare(deviceItem.uid, zeroUid + "/Dc/0/Voltage")
		deviceItem.deviceInstance = 9102
		compare(deviceItem.uid, otherUid + "/Dc/0/Voltage")

		deviceItem.path = "/Dc/0/Current"
		compare(deviceItem.uid, otherUid + "/Dc/0/Current")
		deviceItem.path = "/Dc/0/Voltage"

		// An existing device whose instance changes to the one we want.
		deviceItem.deviceInstance = 9107
		compare(deviceItem.uid, "")
		MockManager.setValue(lateUid + "/DeviceInstance", 9107)
		compare(deviceItem.uid, lateUid + "/Dc/0/Voltage")

		MockManager.removeValue(lateUid)
		createdServiceUids = createdServiceUids.filter(uid => uid !== lateUid)
		compare(deviceItem.uid, "")
		compare(deviceItem.valid, false)

		// Naming no device uses the single-instance uid again.
		deviceItem.deviceInstance = -1
		deviceItem.serviceType = "settings"
		deviceItem.path = "/Settings/System/AccessLevel"
		compare(deviceItem.uid, "mock/com.victronenergy.settings/Settings/System/AccessLevel")
	}

	function test_limitsGivenLater() {
		const uid = "mock/com.victronenergy.test.a/LimitsLater"
		MockManager.setValue(uid, 5)
		dataItem.uid = uid
		compare(dataItem.min, NaN)
		compare(dataItem.max, NaN)

		minSpy.clear()
		maxSpy.clear()
		MockManager.setProperty(uid, "min", -5)
		MockManager.setProperty(uid, "max", 32.5)
		compare(minSpy.count, 1)
		compare(maxSpy.count, 1)
		compare(dataItem.min, -5)
		compare(dataItem.max, 32.5)
	}
}
