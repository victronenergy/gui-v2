/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	readonly property string serviceUid: "mock/com.victronenergy.shelly"
	readonly property string devicesUid: serviceUid + "/Devices"

	name: "ShellyDeviceModelTest"

	ShellyDeviceModel {
		id: model
	}

	SortedShellyDeviceModel {
		id: sortedModel
		sourceModel: model
	}

	Component {
		id: shellyDeviceModelComponent

		ShellyDeviceModel {}
	}

	SignalSpy {
		id: rowsInsertedSpy
		target: model
		signalName: "rowsInserted"
	}

	SignalSpy {
		id: rowsRemovedSpy
		target: model
		signalName: "rowsRemoved"
	}

	SignalSpy {
		id: dataChangedSpy
		target: model
		signalName: "dataChanged"
	}

	SignalSpy {
		id: countChangedSpy
		target: model
		signalName: "countChanged"
	}

	function deviceUid(id) {
		return devicesUid + "/" + id
	}

	// Sets the values for a device. 'channels' is a list of /<channel>/Enabled values.
	function setDevice(id, device) {
		const uid = deviceUid(id)
		MockManager.setValue(uid + "/Model", device.model)
		MockManager.setValue(uid + "/Name", device.name)
		if (device.mac !== undefined) {
			MockManager.setValue(uid + "/Mac", device.mac)
		}
		if (device.reachable !== undefined) {
			MockManager.setValue(uid + "/Reachable", device.reachable)
		}
		if (device.supported !== undefined) {
			MockManager.setValue(uid + "/Supported", device.supported)
		}
		MockManager.setValue(uid + "/Ip", "192.168.1.1")
		for (let i = 0; i < (device.channels || []).length; ++i) {
			MockManager.setValue(uid + "/" + i + "/Enabled", device.channels[i])
			MockManager.setValue(uid + "/" + i + "/Type", "switch")
		}
	}

	function defaultDevices() {
		return {
			"AAA111": { model: "ShellyPlusPlugS", name: "Kitchen", mac: "11:11:11:aa:aa:aa", reachable: 1, supported: 1, channels: [1, 0, 1] },
			"BBB222": { model: "ShellyPro3EM", name: "", mac: "22:22:22:bb:bb:bb", reachable: 0, supported: 1, channels: [0] },
			"CCC333": { model: "ShellyUnknown", name: "Garage", mac: "33:33:33:cc:cc:cc", reachable: 1, supported: 0, channels: [] },
		}
	}

	function setupDevices(devices) {
		devices = devices === undefined ? defaultDevices() : devices
		for (const id of Object.keys(devices)) {
			setDevice(id, devices[id])
		}
		MockManager.setValue(serviceUid + "/Refresh", 0)
		tryCompare(model, "count", Object.keys(devices).length)
	}

	function roleValue(m, row, role) {
		return m.data(m.index(row, 0), role)
	}

	function findRow(id) {
		for (let i = 0; i < model.rowCount(); ++i) {
			if (roleValue(model, i, ShellyDeviceModel.UidRole) === deviceUid(id)) {
				return i
			}
		}
		return -1
	}

	function sortedNames() {
		let names = []
		for (let i = 0; i < sortedModel.rowCount(); ++i) {
			names.push(roleValue(sortedModel, i, ShellyDeviceModel.NameRole))
		}
		return names
	}

	function trySortedNames(expected) {
		tryVerify(() => sortedNames().join(",") === expected, 5000,
				"sorted names: '" + sortedNames().join(",") + "' expected: '" + expected + "'")
	}

	function init() {
		setupDevices()
		rowsInsertedSpy.clear()
		rowsRemovedSpy.clear()
		dataChangedSpy.clear()
		countChangedSpy.clear()
	}

	function cleanup() {
		if (MockManager.value(serviceUid + "/Refresh") !== undefined) {
			MockManager.removeValue(serviceUid)
		}
		tryCompare(model, "count", 0)
		compare(model.rowCount(), 0)
	}

	function test_roles() {
		const devices = defaultDevices()
		compare(model.count, Object.keys(devices).length)
		compare(model.rowCount(), Object.keys(devices).length)

		let row = findRow("AAA111")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "Kitchen")
		compare(roleValue(model, row, ShellyDeviceModel.ReachableRole), true)
		compare(roleValue(model, row, ShellyDeviceModel.SupportedRole), true)
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 2)

		row = findRow("BBB222")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.ReachableRole), false)
		compare(roleValue(model, row, ShellyDeviceModel.SupportedRole), true)
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 0)

		row = findRow("CCC333")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "Garage")
		compare(roleValue(model, row, ShellyDeviceModel.ReachableRole), true)
		compare(roleValue(model, row, ShellyDeviceModel.SupportedRole), false)
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 0)
	}

	function test_invalidRow() {
		compare(roleValue(model, -1, ShellyDeviceModel.NameRole), undefined)
		compare(roleValue(model, model.count, ShellyDeviceModel.NameRole), undefined)
	}

	function test_nameFallback_data() {
		return [
			{ tag: "empty name", name: "", mac: "aa:bb", expected: "ShellyPro3EM [aa:bb]" },
			{ tag: "invalid name", name: null, mac: "aa:bb", expected: "ShellyPro3EM [aa:bb]" },
			{ tag: "invalid name and mac", name: null, mac: null, expected: "ShellyPro3EM []" },
		]
	}

	function test_nameFallback(data) {
		// When a name is set, it is used.
		MockManager.setValue(deviceUid("BBB222") + "/Name", "Shed")
		tryVerify(() => roleValue(model, findRow("BBB222"), ShellyDeviceModel.NameRole) === "Shed")

		// When there is no name, the name is "<model> [<mac>]". Changes to /Mac do not trigger an
		// update by themselves, so set it before the /Name change.
		MockManager.setValue(deviceUid("BBB222") + "/Mac", data.mac)
		MockManager.setValue(deviceUid("BBB222") + "/Name", data.name)
		tryCompare(model, "count", Object.keys(defaultDevices()).length)
		tryVerify(() => roleValue(model, findRow("BBB222"), ShellyDeviceModel.NameRole) === data.expected)
	}

	function test_invalidModelExcluded() {
		// A device without a valid /Model is not included.
		MockManager.setValue(deviceUid("DDD444") + "/Name", "No model")
		MockManager.setValue(deviceUid("DDD444") + "/0/Enabled", 1)
		wait(50)
		compare(model.count, Object.keys(defaultDevices()).length)
		compare(findRow("DDD444"), -1)
		compare(rowsInsertedSpy.count, 0)

		// Changes to /Model do not trigger an update by themselves, so the device is not added yet.
		MockManager.setValue(deviceUid("DDD444") + "/Model", "ShellyPlus1")
		wait(50)
		compare(findRow("DDD444"), -1)
		compare(rowsInsertedSpy.count, 0)

		// It is added once /Model is valid and a watched value changes.
		MockManager.setValue(deviceUid("DDD444") + "/Supported", 1)
		tryCompare(model, "count", Object.keys(defaultDevices()).length + 1)
		const row = findRow("DDD444")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "No model")
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 1)
		compare(rowsInsertedSpy.count, 1)
		compare(countChangedSpy.count, 1)
	}

	function test_addDevice() {
		setDevice("DDD444", { model: "ShellyPlus1", name: "Pump", mac: "44:44", reachable: 1, supported: 1, channels: [1] })
		tryCompare(model, "count", Object.keys(defaultDevices()).length + 1)

		const row = findRow("DDD444")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "Pump")
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 1)

		// Values set at the same time should be batched into a single insertion.
		compare(rowsInsertedSpy.count, 1)
		compare(rowsRemovedSpy.count, 0)
		compare(countChangedSpy.count, 1)
	}

	function test_optionalPathsMissing() {
		// /Reachable and /Supported default to true if they are not present.
		setDevice("DDD444", { model: "ShellyPlus1", name: "Pump", mac: "44:44", channels: [1] })
		tryCompare(model, "count", Object.keys(defaultDevices()).length + 1)

		const row = findRow("DDD444")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.ReachableRole), true)
		compare(roleValue(model, row, ShellyDeviceModel.SupportedRole), true)
	}

	function test_macMissing() {
		// If /Mac is not present and there is no name, the name falls back to "<model> []".
		setDevice("DDD444", { model: "ShellyPlus1", name: "", reachable: 1, supported: 1, channels: [1] })
		tryCompare(model, "count", Object.keys(defaultDevices()).length + 1)

		const row = findRow("DDD444")
		verify(row >= 0)
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "ShellyPlus1 []")
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 1)
	}

	function test_optionalPathsInvalidated_data() {
		return [
			{ tag: "reachable", path: "Reachable", role: ShellyDeviceModel.ReachableRole },
			{ tag: "supported", path: "Supported", role: ShellyDeviceModel.SupportedRole },
		]
	}

	function test_optionalPathsInvalidated(data) {
		// If /Reachable or /Supported becomes invalid, it defaults to true.
		MockManager.setValue(deviceUid("BBB222") + "/" + data.path, 0)
		tryVerify(() => roleValue(model, findRow("BBB222"), data.role) === false)
		MockManager.setValue(deviceUid("BBB222") + "/" + data.path, null)
		tryVerify(() => roleValue(model, findRow("BBB222"), data.role) === true)
	}

	function test_removeDevice() {
		MockManager.removeValue(deviceUid("BBB222"))
		tryCompare(model, "count", Object.keys(defaultDevices()).length - 1)
		compare(findRow("BBB222"), -1)
		verify(findRow("AAA111") >= 0)
		verify(findRow("CCC333") >= 0)
		compare(rowsRemovedSpy.count, 1)
		compare(rowsInsertedSpy.count, 0)
		compare(countChangedSpy.count, 1)
	}

	function test_scan() {
		// When a scan is done, the device values are invalidated but the items still exist.
		for (const id of Object.keys(defaultDevices())) {
			for (const path of ["Model", "Name", "Mac", "Reachable", "Supported"]) {
				MockManager.setValue(deviceUid(id) + "/" + path, null)
			}
		}
		tryCompare(model, "count", 0)
		compare(rowsRemovedSpy.count, Object.keys(defaultDevices()).length)
		compare(countChangedSpy.count, 1)
		compare(sortedModel.rowCount(), 0)

		// When the scan completes, the devices are added again.
		setupDevices()
		compare(rowsInsertedSpy.count, Object.keys(defaultDevices()).length)
		trySortedNames("Kitchen,ShellyPro3EM [22:22:22:bb:bb:bb],Garage")
	}

	function test_updateDevice_data() {
		return [
			{ tag: "name", path: "Name", value: "Office", role: ShellyDeviceModel.NameRole, expected: "Office" },
			{ tag: "reachable", path: "Reachable", value: 0, role: ShellyDeviceModel.ReachableRole, expected: false },
			{ tag: "supported", path: "Supported", value: 0, role: ShellyDeviceModel.SupportedRole, expected: false },
			{ tag: "channel disabled", path: "0/Enabled", value: 0, role: ShellyDeviceModel.EnabledChannelCountRole, expected: 1 },
			{ tag: "channel enabled", path: "1/Enabled", value: 1, role: ShellyDeviceModel.EnabledChannelCountRole, expected: 3 },
			{ tag: "channel added", path: "5/Enabled", value: 1, role: ShellyDeviceModel.EnabledChannelCountRole, expected: 3 },
			{ tag: "channel invalidated", path: "2/Enabled", value: null, role: ShellyDeviceModel.EnabledChannelCountRole, expected: 1 },
		]
	}

	function test_updateDevice(data) {
		MockManager.setValue(deviceUid("AAA111") + "/" + data.path, data.value)
		tryVerify(() => roleValue(model, findRow("AAA111"), data.role) === data.expected)

		// An in-place update should emit a single dataChanged for the device, and not
		// remove or re-insert any rows.
		compare(model.count, Object.keys(defaultDevices()).length)
		compare(rowsRemovedSpy.count, 0)
		compare(rowsInsertedSpy.count, 0)
		compare(countChangedSpy.count, 0)
		compare(dataChangedSpy.count, 1)
		compare(dataChangedSpy.signalArguments[0][0].row, findRow("AAA111"))
	}

	function test_multipleUpdatesBatched() {
		// Several changes to the same device should be batched into a single dataChanged.
		MockManager.setValue(deviceUid("AAA111") + "/Name", "Lounge")
		MockManager.setValue(deviceUid("AAA111") + "/Reachable", 0)
		MockManager.setValue(deviceUid("AAA111") + "/1/Enabled", 1)
		tryVerify(() => dataChangedSpy.count > 0)
		wait(50)

		const row = findRow("AAA111")
		compare(roleValue(model, row, ShellyDeviceModel.NameRole), "Lounge")
		compare(roleValue(model, row, ShellyDeviceModel.ReachableRole), false)
		compare(roleValue(model, row, ShellyDeviceModel.EnabledChannelCountRole), 3)
		compare(dataChangedSpy.count, 1)
	}

	function test_removeChannel() {
		MockManager.removeValue(deviceUid("AAA111") + "/2")
		tryVerify(() => roleValue(model, findRow("AAA111"), ShellyDeviceModel.EnabledChannelCountRole) === 1)
		compare(dataChangedSpy.count, 1)
		compare(rowsRemovedSpy.count, 0)
	}

	function test_nonChannelChildrenIgnored() {
		// Only numeric child paths are channels.
		MockManager.setValue(deviceUid("AAA111") + "/Other/Enabled", 1)
		MockManager.setValue(deviceUid("AAA111") + "/Enabled", 1)
		wait(50)
		compare(roleValue(model, findRow("AAA111"), ShellyDeviceModel.EnabledChannelCountRole), 2)
		compare(dataChangedSpy.count, 0)
	}

	function test_unchangedData() {
		// Changes to values that are not in the model, or re-setting identical values, should not
		// modify the model.
		MockManager.setValue(deviceUid("AAA111") + "/Ip", "192.168.1.2")
		MockManager.setValue(deviceUid("AAA111") + "/0/Type", "em")
		MockManager.setValue(deviceUid("AAA111") + "/Mac", "99:99:99:99:99:99")
		MockManager.setValue(deviceUid("AAA111") + "/Model", "ShellyPlusPlugS2")
		wait(50)

		compare(model.count, Object.keys(defaultDevices()).length)
		compare(rowsRemovedSpy.count, 0)
		compare(rowsInsertedSpy.count, 0)
		compare(dataChangedSpy.count, 0)
		compare(countChangedSpy.count, 0)
	}

	function test_sorted() {
		// Supported devices are sorted first, then unsupported devices, each sorted by name.
		compare(sortedModel.rowCount(), model.rowCount())
		compare(sortedNames(), ["Kitchen", "ShellyPro3EM [22:22:22:bb:bb:bb]", "Garage"])
	}

	function test_sortedAfterSupportedChange() {
		MockManager.setValue(deviceUid("CCC333") + "/Supported", 1)
		trySortedNames("Garage,Kitchen,ShellyPro3EM [22:22:22:bb:bb:bb]")

		MockManager.setValue(deviceUid("AAA111") + "/Supported", 0)
		trySortedNames("Garage,ShellyPro3EM [22:22:22:bb:bb:bb],Kitchen")
	}

	function test_sortedAfterRename() {
		MockManager.setValue(deviceUid("AAA111") + "/Name", "Attic")
		trySortedNames("Attic,ShellyPro3EM [22:22:22:bb:bb:bb],Garage")

		MockManager.setValue(deviceUid("BBB222") + "/Name", "Basement")
		trySortedNames("Attic,Basement,Garage")
	}

	function test_sortedAfterAddAndRemove() {
		setDevice("DDD444", { model: "ShellyPlus1", name: "Boathouse", mac: "44:44", reachable: 1, supported: 1, channels: [1] })
		MockManager.removeValue(deviceUid("CCC333"))
		trySortedNames("Boathouse,Kitchen,ShellyPro3EM [22:22:22:bb:bb:bb]")
	}

	function test_serviceRemoved() {
		MockManager.removeValue(serviceUid)
		tryCompare(model, "count", 0)
		compare(sortedModel.rowCount(), 0)
		compare(rowsRemovedSpy.count, Object.keys(defaultDevices()).length)
		compare(countChangedSpy.count, 1)
	}

	function test_serviceReAdded() {
		MockManager.removeValue(serviceUid)
		tryCompare(model, "count", 0)

		// When the service is added again, the model is rebound to the new service.
		setupDevices()
		trySortedNames("Kitchen,ShellyPro3EM [22:22:22:bb:bb:bb],Garage")

		// Changes to the new service are reflected in the model.
		MockManager.setValue(deviceUid("AAA111") + "/Name", "Lounge")
		tryVerify(() => roleValue(model, findRow("AAA111"), ShellyDeviceModel.NameRole) === "Lounge")
		MockManager.setValue(deviceUid("AAA111") + "/0/Enabled", 0)
		tryVerify(() => roleValue(model, findRow("AAA111"), ShellyDeviceModel.EnabledChannelCountRole) === 1)
	}

	function test_serviceRemovedRepeatedly() {
		for (let i = 0; i < 3; ++i) {
			MockManager.removeValue(serviceUid)
			tryCompare(model, "count", 0)
			setupDevices()
		}
		compare(rowsInsertedSpy.count, 3 * Object.keys(defaultDevices()).length)
		compare(rowsRemovedSpy.count, 3 * Object.keys(defaultDevices()).length)
	}

	function test_createdWithExistingService() {
		// A model created after the service exists is populated immediately.
		const newModel = createTemporaryObject(shellyDeviceModelComponent, root)
		verify(newModel)
		compare(newModel.count, Object.keys(defaultDevices()).length)
	}

	function test_createdWithoutService() {
		MockManager.removeValue(serviceUid)
		tryCompare(model, "count", 0)

		// A model created before the service exists binds to it once it is added.
		const newModel = createTemporaryObject(shellyDeviceModelComponent, root)
		verify(newModel)
		wait(50)
		compare(newModel.count, 0)

		setupDevices()
		tryCompare(newModel, "count", Object.keys(defaultDevices()).length)

		// It is cleared again when the service is removed.
		MockManager.removeValue(serviceUid)
		tryCompare(newModel, "count", 0)
	}
}
