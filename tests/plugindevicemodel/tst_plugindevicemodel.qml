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

	name: "PluginDeviceModelTest"

	property var createdServiceUids: []

	PluginDeviceModel {
		id: tanks

		serviceTypes: ["tank"]
	}

	Repeater {
		id: tankRepeater

		model: tanks

		delegate: Item {
			required property int index
			required property string serviceUid
			required property string serviceType
			required property int deviceInstance
			required property string name
			required property int productId
		}
	}

	SignalSpy {
		id: countSpy

		target: tanks
		signalName: "countChanged"
	}

	SignalSpy {
		id: availableServiceTypesSpy

		target: tanks
		signalName: "availableServiceTypesChanged"
	}

	SignalSpy {
		id: resetSpy

		target: tanks
		signalName: "modelReset"
	}

	PluginDeviceModel {
		id: changedDuringUpdate

		// Called when count changes, which happens during an update.
		property var changeDuringUpdate: null

		serviceTypes: ["tank"]
		onCountChanged: {
			if (changeDuringUpdate) {
				changeDuringUpdate()
			}
		}
	}

	function addDevice(uid, deviceInstance, productName, customName, productId) {
		createdServiceUids.push(uid)
		MockManager.setValue(uid + "/DeviceInstance", deviceInstance)
		if (productName !== undefined) {
			MockManager.setValue(uid + "/ProductName", productName)
		}
		if (customName !== undefined) {
			MockManager.setValue(uid + "/CustomName", customName)
		}
		if (productId !== undefined) {
			MockManager.setValue(uid + "/ProductId", productId)
		}
	}

	function expectRow(index, uid, serviceType, deviceInstance, name, productId) {
		compare(tanks.serviceUidAt(index), uid)
		compare(tanks.serviceTypeAt(index), serviceType)
		compare(tanks.deviceInstanceAt(index), deviceInstance)
		compare(tanks.nameAt(index), name)
		compare(tanks.productIdAt(index), productId)

		tryCompare(tankRepeater, "count", tanks.count)
		const item = tankRepeater.itemAt(index)
		verify(item !== null)
		compare(item.serviceUid, uid)
		compare(item.serviceType, serviceType)
		compare(item.deviceInstance, deviceInstance)
		compare(item.name, name)
		compare(item.productId, productId)
	}

	function cleanup() {
		changedDuringUpdate.changeDuringUpdate = null
		changedDuringUpdate.serviceTypes = ["tank"]
		tanks.requiredPaths = []
		for (let i = 0; i < createdServiceUids.length; ++i) {
			MockManager.removeValue(createdServiceUids[i])
		}
		createdServiceUids = []
		tanks.serviceTypes = ["tank"]
	}

	function test_emptyUntilADeviceHasAName() {
		compare(tanks.count, 0)
		compare(tanks.serviceUidAt(0), "")
		compare(tanks.deviceInstanceAt(0), -1)
		compare(tanks.productIdAt(-1), -1)

		const uid = "mock/com.victronenergy.tank.pdm_unnamed"
		addDevice(uid, 4)
		compare(tanks.count, 0)

		MockManager.setValue(uid + "/ProductName", "Unnamed until now")
		compare(tanks.count, 1)
		expectRow(0, uid, "tank", 4, "Unnamed until now", 0)
	}

	function test_listsMatchingDevicesByName() {
		const zUid = "mock/com.victronenergy.tank.pdm_z"
		const aUid = "mock/com.victronenergy.tank.pdm_a"
		const batteryUid = "mock/com.victronenergy.battery.pdm_m"
		addDevice(zUid, 2, "Z tank", undefined, 0xA1)
		addDevice(batteryUid, 1, "M battery")
		addDevice(aUid, 9, "A tank")

		compare(tanks.count, 2)
		expectRow(0, aUid, "tank", 9, "A tank", 0)
		expectRow(1, zUid, "tank", 2, "Z tank", 0xA1)
	}

	function test_customNameIsUsedAndResorts() {
		const uid = "mock/com.victronenergy.tank.pdm_custom"
		const otherUid = "mock/com.victronenergy.tank.pdm_other"
		addDevice(uid, 1, "Z product", "M custom")
		addDevice(otherUid, 2, "Other tank")
		expectRow(0, uid, "tank", 1, "M custom", 0)

		countSpy.clear()
		MockManager.setValue(uid + "/CustomName", "A custom")
		compare(countSpy.count, 0)
		expectRow(0, uid, "tank", 1, "A custom", 0)
		expectRow(1, otherUid, "tank", 2, "Other tank", 0)

		MockManager.setValue(uid + "/CustomName", "")
		expectRow(1, uid, "tank", 1, "Z product", 0)
	}

	function test_productIdChangeUpdatesTheRow() {
		const uid = "mock/com.victronenergy.tank.pdm_product"
		addDevice(uid, 3, "Product tank")
		expectRow(0, uid, "tank", 3, "Product tank", 0)

		MockManager.setValue(uid + "/ProductId", 262)
		expectRow(0, uid, "tank", 3, "Product tank", 262)
	}

	function test_sameInstanceAreBothListed() {
		const firstUid = "mock/com.victronenergy.tank.pdm_same_b"
		const secondUid = "mock/com.victronenergy.tank.pdm_same_a"
		addDevice(firstUid, 5, "Same B")
		addDevice(secondUid, 5, "Same A")

		compare(tanks.count, 2)
		expectRow(0, secondUid, "tank", 5, "Same A", 0)
		expectRow(1, firstUid, "tank", 5, "Same B", 0)
		verify(tanks.serviceUidAt(0) !== tanks.serviceUidAt(1))
	}

	function test_removal() {
		const stayUid = "mock/com.victronenergy.tank.pdm_stay"
		const goneUid = "mock/com.victronenergy.tank.pdm_gone"
		addDevice(stayUid, 1, "Stays")
		addDevice(goneUid, 2, "Goes")
		compare(tanks.count, 2)

		MockManager.removeValue(goneUid)
		createdServiceUids = createdServiceUids.filter(function(uid) { return uid !== goneUid })
		compare(tanks.count, 1)
		expectRow(0, stayUid, "tank", 1, "Stays", 0)
	}

	function test_serviceTypesChange() {
		const tankUid = "mock/com.victronenergy.tank.pdm_switch"
		const batteryUid = "mock/com.victronenergy.battery.pdm_switch"
		addDevice(tankUid, 1, "Switch tank")
		addDevice(batteryUid, 2, "Switch battery", undefined, 12)
		compare(tanks.count, 1)

		tanks.serviceTypes = ["battery"]
		compare(tanks.count, 1)
		expectRow(0, batteryUid, "battery", 2, "Switch battery", 12)

		tanks.serviceTypes = ["tank", "battery"]
		compare(tanks.count, 2)
		expectRow(0, batteryUid, "battery", 2, "Switch battery", 12)
		expectRow(1, tankUid, "tank", 1, "Switch tank", 0)
	}

	function test_emptyServiceTypesListsEveryDeviceButNotSettings() {
		const tankUid = "mock/com.victronenergy.tank.pdm_all"
		const batteryUid = "mock/com.victronenergy.battery.pdm_all"
		addDevice(tankUid, 1, "All tank")
		addDevice(batteryUid, 1, "All battery")
		const settingsUid = "mock/com.victronenergy.settings/Settings/PluginDeviceModel/Test"
		createdServiceUids.push(settingsUid)
		MockManager.setValue(settingsUid, 1)

		tanks.serviceTypes = []
		compare(tanks.count, 2)
		expectRow(0, batteryUid, "battery", 1, "All battery", 0)
		expectRow(1, tankUid, "tank", 1, "All tank", 0)
		for (let i = 0; i < tanks.count; ++i) {
			verify(tanks.serviceTypeAt(i) !== "settings")
		}
	}

	function test_availableServiceTypes() {
		compare(tanks.availableServiceTypes, [])

		const tankUid = "mock/com.victronenergy.tank.pdm_types"
		const secondTankUid = "mock/com.victronenergy.tank.pdm_types_2"
		const batteryUid = "mock/com.victronenergy.battery.pdm_types"
		const solarUid = "mock/com.victronenergy.solarcharger.pdm_types"
		addDevice(tankUid, 1, "Types tank")
		addDevice(batteryUid, 2, "Types battery")
		// Without a name, this is not a device yet.
		addDevice(solarUid, 3)
		const settingsUid = "mock/com.victronenergy.settings/Settings/PluginDeviceModel/Types"
		createdServiceUids.push(settingsUid)
		MockManager.setValue(settingsUid, 1)

		// serviceTypes is ["tank"], but the types of every device are listed.
		compare(tanks.count, 1)
		compare(tanks.availableServiceTypes, ["battery", "tank"])

		availableServiceTypesSpy.clear()
		addDevice(secondTankUid, 4, "Second tank")
		compare(availableServiceTypesSpy.count, 0)
		compare(tanks.availableServiceTypes, ["battery", "tank"])

		MockManager.setValue(solarUid + "/ProductName", "Types solar")
		compare(availableServiceTypesSpy.count, 1)
		compare(tanks.availableServiceTypes, ["battery", "solarcharger", "tank"])

		MockManager.removeValue(batteryUid)
		createdServiceUids = createdServiceUids.filter(function(uid) { return uid !== batteryUid })
		compare(availableServiceTypesSpy.count, 2)
		compare(tanks.availableServiceTypes, ["solarcharger", "tank"])
	}

	function test_requiredPaths() {
		const levelUid = "mock/com.victronenergy.tank.pdm_level"
		const nestedUid = "mock/com.victronenergy.tank.pdm_nested"
		const plainUid = "mock/com.victronenergy.tank.pdm_plain"
		const batteryUid = "mock/com.victronenergy.battery.pdm_level"
		addDevice(levelUid, 1, "Level tank")
		addDevice(nestedUid, 2, "Nested tank")
		addDevice(plainUid, 3, "Plain tank")
		addDevice(batteryUid, 4, "Level battery")
		MockManager.setValue(levelUid + "/Level", 50)
		MockManager.setValue(nestedUid + "/Level", 20)
		MockManager.setValue(nestedUid + "/Pv/0/V", 12)
		MockManager.setValue(batteryUid + "/Level", 70)
		compare(tanks.count, 3)

		// A device without the path is not listed.
		tanks.requiredPaths = ["Level"]
		compare(tanks.count, 2)
		expectRow(0, levelUid, "tank", 1, "Level tank", 0)
		expectRow(1, nestedUid, "tank", 2, "Nested tank", 0)

		// The leading slash is optional.
		tanks.requiredPaths = ["/Level"]
		compare(tanks.count, 2)
		expectRow(0, levelUid, "tank", 1, "Level tank", 0)
		expectRow(1, nestedUid, "tank", 2, "Nested tank", 0)

		// Every path needs a valid value, and a path can have several parts.
		tanks.requiredPaths = ["Level", "Pv/0/V"]
		compare(tanks.count, 1)
		expectRow(0, nestedUid, "tank", 2, "Nested tank", 0)

		// A path whose value becomes invalid removes the device.
		tanks.requiredPaths = ["Level"]
		countSpy.clear()
		MockManager.setValue(levelUid + "/Level", undefined)
		compare(countSpy.count, 1)
		compare(tanks.count, 1)
		expectRow(0, nestedUid, "tank", 2, "Nested tank", 0)

		// A path whose value becomes valid adds the device.
		MockManager.setValue(plainUid + "/Level", 10)
		compare(countSpy.count, 2)
		compare(tanks.count, 2)
		expectRow(0, nestedUid, "tank", 2, "Nested tank", 0)
		expectRow(1, plainUid, "tank", 3, "Plain tank", 0)

		// The paths apply to every service type.
		tanks.serviceTypes = ["tank", "battery"]
		compare(tanks.count, 3)
		expectRow(0, batteryUid, "battery", 4, "Level battery", 0)
		expectRow(1, nestedUid, "tank", 2, "Nested tank", 0)
		expectRow(2, plainUid, "tank", 3, "Plain tank", 0)

		// An empty list does not filter.
		tanks.requiredPaths = []
		compare(tanks.count, 4)
		expectRow(1, levelUid, "tank", 1, "Level tank", 0)
	}

	function test_delegatesOfDevicesThatStayAreKept() {
		const bUid = "mock/com.victronenergy.tank.pdm_keep_b"
		const cUid = "mock/com.victronenergy.tank.pdm_keep_c"
		const dUid = "mock/com.victronenergy.tank.pdm_keep_d"
		addDevice(bUid, 1, "B tank")
		addDevice(dUid, 2, "D tank")
		expectRow(0, bUid, "tank", 1, "B tank", 0)
		expectRow(1, dUid, "tank", 2, "D tank", 0)
		const bItem = tankRepeater.itemAt(0)
		const dItem = tankRepeater.itemAt(1)
		resetSpy.clear()

		// A new device is inserted between them.
		addDevice(cUid, 3, "C tank")
		expectRow(1, cUid, "tank", 3, "C tank", 0)
		verify(tankRepeater.itemAt(0) === bItem)
		verify(tankRepeater.itemAt(2) === dItem)

		// A renamed device moves.
		MockManager.setValue(bUid + "/CustomName", "Z tank")
		expectRow(2, bUid, "tank", 1, "Z tank", 0)
		verify(tankRepeater.itemAt(1) === dItem)
		verify(tankRepeater.itemAt(2) === bItem)

		// A device that gets a required path is inserted.
		MockManager.setValue(dUid + "/Level", 20)
		tanks.requiredPaths = ["Level"]
		expectRow(0, dUid, "tank", 2, "D tank", 0)
		verify(tankRepeater.itemAt(0) === dItem)
		MockManager.setValue(cUid + "/Level", 10)
		expectRow(0, cUid, "tank", 3, "C tank", 0)
		verify(tankRepeater.itemAt(1) === dItem)

		compare(resetSpy.count, 0)
	}

	function test_changesMadeDuringUpdatesAreApplied() {
		addDevice("mock/com.victronenergy.tank.pdm_chain", 1, "Chain tank")
		addDevice("mock/com.victronenergy.battery.pdm_chain", 2, "Chain battery")
		addDevice("mock/com.victronenergy.solarcharger.pdm_chain", 3, "Chain solar")
		compare(changedDuringUpdate.count, 1)
		const changes = [["tank", "battery", "solarcharger"], ["solarcharger"]]
		changedDuringUpdate.changeDuringUpdate = function() {
			if (changes.length > 0) {
				changedDuringUpdate.serviceTypes = changes.shift()
			}
		}

		// This changes count, which changes serviceTypes, which changes count, and so on.
		changedDuringUpdate.serviceTypes = ["tank", "battery"]
		tryCompare(changedDuringUpdate, "count", 1)
		compare(changedDuringUpdate.serviceTypeAt(0), "solarcharger")
	}

	function test_aChangeDuringEveryUpdateStopsWithAWarning() {
		addDevice("mock/com.victronenergy.tank.pdm_loop", 1, "Loop tank")
		addDevice("mock/com.victronenergy.battery.pdm_loop_a", 2, "Loop battery A")
		addDevice("mock/com.victronenergy.battery.pdm_loop_b", 3, "Loop battery B")
		compare(changedDuringUpdate.count, 1)
		let updates = 0
		changedDuringUpdate.changeDuringUpdate = function() {
			updates++
			changedDuringUpdate.serviceTypes = changedDuringUpdate.count === 1 ? ["battery"] : ["tank"]
		}

		ignoreWarning(new RegExp("Loop detected: the model was changed during 3 updates in a row"))
		changedDuringUpdate.serviceTypes = ["battery"]
		tryVerify(function() { return updates === 3 })
		wait(0)
		wait(0)
		compare(updates, 3)

		// A change from outside an update updates the model again.
		changedDuringUpdate.changeDuringUpdate = null
		addDevice("mock/com.victronenergy.tank.pdm_loop_2", 4, "Loop tank 2")
		compare(changedDuringUpdate.count, 2)
		compare(changedDuringUpdate.serviceTypeAt(0), "tank")
		compare(changedDuringUpdate.serviceTypeAt(1), "tank")
	}
}
