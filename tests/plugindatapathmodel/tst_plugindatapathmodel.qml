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

	name: "PluginDataPathModelTest"

	property var createdUids: []

	PluginDataPathModel {
		id: paths
	}

	Repeater {
		id: pathRepeater

		model: paths

		delegate: Item {
			required property int index
			required property string childName
			required property string childPath
			required property string childUid
		}
	}

	PluginDataItem {
		id: dataItem
	}

	PluginDataItem {
		id: deviceDataItem
	}

	SignalSpy {
		id: countSpy

		target: paths
		signalName: "countChanged"
	}

	function setValue(uid, value) {
		createdUids.push(uid)
		MockManager.setValue(uid, value)
	}

	// The model updates its list 100 ms after a change to a descendant of uid.
	function waitForTheUpdateDelay() {
		wait(300)
	}

	// If parentPath is given, each childPath is parentPath + "/" + the child's name. Otherwise each
	// childPath is empty.
	function expectNames(names, parentPath) {
		tryCompare(paths, "count", names.length)
		tryCompare(pathRepeater, "count", names.length)
		for (let i = 0; i < names.length; ++i) {
			const expectedPath = parentPath === undefined ? "" : parentPath + "/" + names[i]
			compare(paths.childNameAt(i), names[i])
			compare(paths.childPathAt(i), expectedPath)
			compare(paths.childUidAt(i), paths.uid.replace(/\/+$/, "") + "/" + names[i])
			const item = pathRepeater.itemAt(i)
			verify(item !== null)
			compare(item.childName, names[i])
			compare(item.childPath, expectedPath)
			compare(item.childUid, paths.childUidAt(i))
		}
	}

	function cleanup() {
		dataItem.uid = ""
		deviceDataItem.deviceInstance = -1
		deviceDataItem.serviceType = ""
		deviceDataItem.path = ""
		paths.deviceInstance = -1
		paths.serviceType = ""
		paths.path = ""
		paths.uid = ""
		for (let i = 0; i < createdUids.length; ++i) {
			MockManager.removeValue(createdUids[i])
		}
		createdUids = []
	}

	function test_emptyUid() {
		compare(paths.uid, "")
		compare(paths.count, 0)
		compare(paths.childNameAt(0), "")
		compare(paths.childPathAt(0), "")
		compare(paths.childUidAt(-1), "")
	}

	function test_listsTheChildrenSorted() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_sorted"
		setValue(uid + "/Soc", 50)
		setValue(uid + "/Dc/0/Voltage", 12.5)
		setValue(uid + "/NrOfTrackers", 3)
		setValue(uid + "/Pv/10/V", 30)
		setValue(uid + "/Pv/2/V", 20)
		setValue(uid + "/Pv/0/V", 10)
		setValue(uid + "/Pv/Name", "Not a number")
		setValue(uid + "/alpha", 1)

		paths.uid = uid
		expectNames(["alpha", "Dc", "NrOfTrackers", "Pv", "Soc"])

		paths.uid = uid + "/Pv"
		expectNames(["0", "2", "10", "Name"])

		// A trailing slash is ignored.
		paths.uid = uid + "/Pv/"
		expectNames(["0", "2", "10", "Name"])

		// A path with a value has no children.
		paths.uid = uid + "/Soc"
		expectNames([])
	}

	function test_aPathThatIsOnlyAskedForIsNotListed() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_asked"
		setValue(uid + "/Soc", 50)
		paths.uid = uid
		expectNames(["Soc"])

		// The data item creates the item for this path, but the system does not have it.
		countSpy.clear()
		dataItem.uid = uid + "/Missing/0/V"
		compare(dataItem.valid, false)
		waitForTheUpdateDelay()
		compare(countSpy.count, 0)
		expectNames(["Soc"])

		// Once the system gives a value to a descendant, it is listed.
		setValue(uid + "/Missing/0/V", 12)
		tryCompare(countSpy, "count", 1)
		expectNames(["Missing", "Soc"])
	}

	function test_aPathWithAnInvalidValueIsListed() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_invalid"
		setValue(uid + "/Empty", undefined)
		paths.uid = uid
		expectNames(["Empty"])
		dataItem.uid = uid + "/Empty"
		compare(dataItem.valid, false)
	}

	function test_addAndRemove() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_changes"
		setValue(uid + "/Soc", 50)
		paths.uid = uid
		expectNames(["Soc"])

		countSpy.clear()
		setValue(uid + "/Dc/0/Voltage", 12.5)
		tryCompare(countSpy, "count", 1)
		expectNames(["Dc", "Soc"])

		MockManager.removeValue(uid + "/Dc")
		createdUids = createdUids.filter(function(createdUid) { return createdUid.indexOf(uid + "/Dc/") !== 0 })
		tryCompare(countSpy, "count", 2)
		expectNames(["Soc"])
	}

	function test_changesCloseTogetherAreOneUpdate() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_burst"
		setValue(uid + "/Soc", 50)
		paths.uid = uid
		expectNames(["Soc"])

		countSpy.clear()
		setValue(uid + "/Dc/0/Voltage", 12.5)
		setValue(uid + "/Mode", 1)
		setValue(uid + "/Yield/Power", 100)
		compare(paths.count, 1)
		expectNames(["Dc", "Mode", "Soc", "Yield"])
		compare(countSpy.count, 1)
	}

	function test_removingTheUidEmptiesTheList() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_removed"
		MockManager.setValue(uid + "/Soc", 50)
		paths.uid = uid
		expectNames(["Soc"])

		MockManager.removeValue(uid)
		tryCompare(paths, "count", 0)
		compare(paths.childNameAt(0), "")
	}

	function test_aRemovedUidIsListedAgainWhenItComesBack() {
		const uid = "mock/com.victronenergy.solarcharger.pdpm_back"
		MockManager.setValue(uid + "/Soc", 50)
		paths.uid = uid
		expectNames(["Soc"])

		MockManager.removeValue(uid)
		tryCompare(paths, "count", 0)
		// Wait, so that the paths come back after the model has created the item again.
		waitForTheUpdateDelay()

		setValue(uid + "/Soc", 60)
		setValue(uid + "/Mode", 1)
		expectNames(["Mode", "Soc"])
	}

	function test_uidChange() {
		const firstUid = "mock/com.victronenergy.solarcharger.pdpm_first"
		const secondUid = "mock/com.victronenergy.solarcharger.pdpm_second"
		setValue(firstUid + "/Soc", 50)
		setValue(secondUid + "/Dc/0/Voltage", 12.5)
		setValue(secondUid + "/Mode", 1)

		paths.uid = firstUid
		expectNames(["Soc"])

		paths.uid = secondUid
		expectNames(["Dc", "Mode"])

		// The first uid is no longer watched.
		countSpy.clear()
		setValue(firstUid + "/Yield/Power", 100)
		waitForTheUpdateDelay()
		compare(countSpy.count, 0)
		expectNames(["Dc", "Mode"])
	}

	function test_serviceTypeAndPath() {
		const serviceUid = "mock/com.victronenergy.settings"
		const uid = serviceUid + "/Settings/PluginDataPathModel"
		setValue(uid + "/B", 1)
		setValue(uid + "/A/X", 2)

		// While only one of them is set, uid is empty.
		paths.serviceType = "settings"
		compare(paths.uid, "")
		compare(paths.count, 0)

		paths.path = "/Settings/PluginDataPathModel"
		compare(paths.uid, uid)
		expectNames(["A", "B"], "/Settings/PluginDataPathModel")

		// The leading slash is optional.
		paths.path = "Settings/PluginDataPathModel/A"
		compare(paths.uid, uid + "/A")
		expectNames(["X"], "/Settings/PluginDataPathModel/A")

		// A trailing slash is ignored.
		paths.path = "/Settings/PluginDataPathModel/"
		compare(paths.uid, uid + "/")
		expectNames(["A", "B"], "/Settings/PluginDataPathModel")

		// A path can be given to a data item.
		dataItem.serviceType = "settings"
		dataItem.path = paths.childPathAt(0) + "/X"
		compare(dataItem.value, 2)
		dataItem.serviceType = ""
		dataItem.path = ""

		// "/" is the top of the service.
		paths.path = "/"
		compare(paths.uid, serviceUid)
		let found = false
		for (let i = 0; i < paths.count; ++i) {
			if (paths.childNameAt(i) === "Settings") {
				found = true
				compare(paths.childPathAt(i), "/Settings")
			}
		}
		verify(found)
		compare(paths.childUidAt(0), serviceUid + "/" + paths.childNameAt(0))

		paths.serviceType = ""
		compare(paths.uid, "")
		compare(paths.count, 0)
	}

	function test_deviceInstance() {
		const serviceUid = "mock/com.victronenergy.battery.pdpm_device"

		// The device is not on the system yet.
		paths.serviceType = "battery"
		paths.deviceInstance = 9201
		paths.path = "/Dc"
		compare(paths.uid, "")
		compare(paths.count, 0)

		createdUids.push(serviceUid)
		MockManager.setValue(serviceUid + "/DeviceInstance", 9201)
		MockManager.setValue(serviceUid + "/ProductName", "Plugin path model test")
		MockManager.setValue(serviceUid + "/Dc/0/Voltage", 10)
		MockManager.setValue(serviceUid + "/Dc/1/Voltage", 20)
		compare(paths.uid, serviceUid + "/Dc")
		expectNames(["0", "1"], "/Dc")

		// A path can be given to a data item with the same serviceType and deviceInstance.
		deviceDataItem.serviceType = paths.serviceType
		deviceDataItem.deviceInstance = paths.deviceInstance
		deviceDataItem.path = paths.childPathAt(1) + "/Voltage"
		compare(deviceDataItem.uid, serviceUid + "/Dc/1/Voltage")
		compare(deviceDataItem.value, 20)

		// "/" is the top of the device's service.
		paths.path = "/"
		compare(paths.uid, serviceUid)
		tryVerify(function() { return paths.count >= 3 })
		const expected = ["DeviceInstance", "ProductName", "Dc"]
		for (let i = 0; i < expected.length; ++i) {
			let found = false
			for (let j = 0; j < paths.count; ++j) {
				if (paths.childNameAt(j) === expected[i]) {
					found = true
					compare(paths.childPathAt(j), "/" + expected[i])
				}
			}
			verify(found, expected[i])
		}

		MockManager.removeValue(serviceUid)
		createdUids = createdUids.filter(uid => uid !== serviceUid)
		compare(paths.uid, "")
		compare(paths.count, 0)
	}
}
