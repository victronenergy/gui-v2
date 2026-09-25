/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	readonly property string platformUid: "mock/com.victronenergy.platform"
	readonly property string servicesUid: platformUid + "/Network/Services"
	readonly property string scanUid: platformUid + "/Network/Wifi/Scan"
	readonly property string accessPointUid: platformUid + "/Services/AccessPoint/Enabled"

	name: "WifiModelTest"

	WifiModel {
		id: model
	}

	SortedWifiModel {
		id: sortedModel
		sourceModel: model
	}

	Component {
		id: wifiModelComponent

		WifiModel {}
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

	function wifiNetwork(service, state, strength, favorite) {
		return {
			"Address": "",
			"Favorite": favorite ? "yes" : "no",
			"Gateway": "",
			"Mac": "11:22:33:AA:BB:CC",
			"Method": "",
			"Nameservers": [],
			"Netmask": "",
			"Secured": "yes",
			"Service": "/net/connman/service/" + service,
			"State": state,
			"Strength": strength
		}
	}

	// Same set of wifi networks as in data/mock/conf/services/network-wifi-and-ethernet.json
	function defaultWifis() {
		return {
			"": wifiNetwork("wifi_hidden", "idle", 94, false),
			"Network A": wifiNetwork("wifi_a", "idle", 22, false),
			"Network B": wifiNetwork("wifi_b", "idle", 42, false),
			"Network C": wifiNetwork("wifi_c", "ready", 88, true),
			"Network D": wifiNetwork("wifi_d", "idle", 57, false),
		}
	}

	function setWifis(wifis) {
		const services = {
			"ethernet": {
				"Wired": {
					"Address": "192.168.1.1",
					"Service": "/net/connman/service/ethernet_1234556789_cable",
					"State": "ready"
				}
			},
			"wifi": wifis
		}
		MockManager.setValue(servicesUid, JSON.stringify(services))
	}

	function setupNetwork(wifis) {
		MockManager.setValue(scanUid, 0)
		MockManager.setValue(accessPointUid, 0)
		setWifis(wifis === undefined ? defaultWifis() : wifis)
		tryCompare(model, "valid", true)
		tryVerify(() => model.rowCount() === Object.keys(wifis === undefined ? defaultWifis() : wifis).length)
	}

	function roleValue(m, row, role) {
		return m.data(m.index(row, 0), role)
	}

	function findRow(networkName) {
		for (let i = 0; i < model.rowCount(); ++i) {
			if (roleValue(model, i, WifiModel.NetworkRole) === networkName) {
				return i
			}
		}
		return -1
	}

	function sortedNetworkNames() {
		let names = []
		for (let i = 0; i < sortedModel.rowCount(); ++i) {
			names.push(roleValue(sortedModel, i, WifiModel.NetworkRole))
		}
		return names
	}

	function trySortedNames(expected) {
		tryVerify(() => sortedNetworkNames().join(",") === expected, 5000,
				"sorted names: '" + sortedNetworkNames().join(",") + "' expected: '" + expected + "'")
	}

	function init() {
		setupNetwork()
		rowsInsertedSpy.clear()
		rowsRemovedSpy.clear()
		dataChangedSpy.clear()
	}

	function cleanup() {
		MockManager.setValue(servicesUid, null)
		MockManager.setValue(scanUid, null)
		MockManager.setValue(accessPointUid, null)
		tryCompare(model, "valid", false)
		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected"))
		compare(model.rowCount(), 0)
	}

	function test_invalid_data() {
		return [
			{ tag: "services invalid", uid: servicesUid },
			{ tag: "scan invalid", uid: scanUid },
		]
	}

	function test_invalid(data) {
		MockManager.setValue(data.uid, null)
		tryCompare(model, "valid", false)
		compare(model.rowCount(), 0)
		compare(sortedModel.rowCount(), 0)
		compare(model.connectedNetworkName, qsTrId("wifimodel_disconnected_ap_off"))
	}

	function test_roles() {
		const wifis = defaultWifis()
		compare(model.rowCount(), Object.keys(wifis).length)

		for (const networkName of Object.keys(wifis)) {
			const row = findRow(networkName)
			verify(row >= 0, "network '" + networkName + "' not found")
			const details = wifis[networkName]
			compare(roleValue(model, row, WifiModel.ServiceRole), details.Service)
			compare(roleValue(model, row, WifiModel.StateRole), details.State)
			compare(roleValue(model, row, WifiModel.StrengthRole), details.Strength)
			compare(roleValue(model, row, WifiModel.FavoriteRole), details.Favorite === "yes")
		}
	}

	function test_strengthAsString() {
		// The platform may provide strength as a string, e.g. "45".
		let wifis = defaultWifis()
		wifis["Network A"].Strength = "45"
		setWifis(wifis)
		tryVerify(() => roleValue(model, findRow("Network A"), WifiModel.StrengthRole) === 45)
	}

	function test_connectedNetworkName_data() {
		return [
			{ tag: "ready", state: "ready", accessPoint: 0, expected: "Network A" },
			{ tag: "online", state: "online", accessPoint: 0, expected: "Network A" },
			{ tag: "idle, AP off", state: "idle", accessPoint: 0, expected: qsTrId("wifimodel_disconnected_ap_off") },
			{ tag: "idle, AP on", state: "idle", accessPoint: 1, expected: qsTrId("wifimodel_disconnected_ap_on") },
			{ tag: "idle, AP invalid", state: "idle", accessPoint: null, expected: qsTrId("wifimodel_disconnected") },
			{ tag: "failure, AP on", state: "failure", accessPoint: 1, expected: qsTrId("wifimodel_disconnected_ap_on") },
		]
	}

	function test_connectedNetworkName(data) {
		compare(model.connectedNetworkName, "Network C")

		MockManager.setValue(accessPointUid, data.accessPoint)
		setWifis({
			"Network A": wifiNetwork("wifi_a", data.state, 50, false),
			"Network B": wifiNetwork("wifi_b", "idle", 60, false),
		})
		tryCompare(model, "connectedNetworkName", data.expected)
	}

	function test_accessPointToggle() {
		setWifis({ "Network A": wifiNetwork("wifi_a", "idle", 50, false) })
		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected_ap_off"))

		MockManager.setValue(accessPointUid, 1)
		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected_ap_on"))

		MockManager.setValue(accessPointUid, 0)
		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected_ap_off"))
	}

	function test_addNetwork() {
		let wifis = defaultWifis()
		wifis["Network E"] = wifiNetwork("wifi_e", "idle", 70, false)
		setWifis(wifis)

		tryVerify(() => model.rowCount() === Object.keys(wifis).length)
		const row = findRow("Network E")
		verify(row >= 0)
		compare(roleValue(model, row, WifiModel.ServiceRole), "/net/connman/service/wifi_e")
		compare(roleValue(model, row, WifiModel.StrengthRole), 70)
		compare(rowsInsertedSpy.count, 1)
		compare(rowsRemovedSpy.count, 0)
	}

	function test_updateNetwork_data() {
		return [
			{ tag: "strength", key: "Strength", value: 11, role: WifiModel.StrengthRole, expected: 11 },
			{ tag: "state", key: "State", value: "association", role: WifiModel.StateRole, expected: "association" },
			{ tag: "favorite", key: "Favorite", value: "yes", role: WifiModel.FavoriteRole, expected: true },
		]
	}

	function test_updateNetwork(data) {
		let wifis = defaultWifis()
		wifis["Network B"][data.key] = data.value
		setWifis(wifis)

		tryVerify(() => roleValue(model, findRow("Network B"), data.role) === data.expected)
		compare(model.rowCount(), Object.keys(wifis).length)

		// An in-place update should emit a single dataChanged for the network, and not
		// remove or re-insert any rows.
		compare(rowsRemovedSpy.count, 0)
		compare(rowsInsertedSpy.count, 0)
		compare(dataChangedSpy.count, 1)
		compare(dataChangedSpy.signalArguments[0][0].row, findRow("Network B"))
	}

	function test_renameNetwork() {
		// Networks are identified by their service, so a changed name for the same service
		// is an in-place update.
		let wifis = defaultWifis()
		wifis["Network B2"] = wifis["Network B"]
		delete wifis["Network B"]
		setWifis(wifis)

		tryVerify(() => findRow("Network B2") >= 0)
		compare(findRow("Network B"), -1)
		compare(model.rowCount(), Object.keys(wifis).length)
		compare(rowsRemovedSpy.count, 0)
		compare(rowsInsertedSpy.count, 0)
	}

	function test_unchangedData() {
		// Re-publishing identical data should not modify the model.
		let services = JSON.parse(MockManager.value(servicesUid))
		services["ethernet"]["Wired"]["Address"] = "192.168.1.2"
		MockManager.setValue(servicesUid, JSON.stringify(services))
		wait(50)

		compare(model.rowCount(), Object.keys(defaultWifis()).length)
		compare(rowsRemovedSpy.count, 0)
		compare(rowsInsertedSpy.count, 0)
		compare(dataChangedSpy.count, 0)
	}

	function test_removeNetwork() {
		let wifis = defaultWifis()
		delete wifis["Network D"]
		setWifis(wifis)

		tryVerify(() => model.rowCount() === Object.keys(wifis).length)
		compare(findRow("Network D"), -1)
		for (const networkName of Object.keys(wifis)) {
			verify(findRow(networkName) >= 0, "network '" + networkName + "' not found")
		}
		compare(rowsRemovedSpy.count, 1)
		compare(rowsInsertedSpy.count, 0)
	}

	function test_removeConnectedNetwork() {
		let wifis = defaultWifis()
		delete wifis["Network C"]
		setWifis(wifis)

		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected_ap_off"))
		compare(model.rowCount(), Object.keys(wifis).length)
	}

	function test_removeAllNetworks() {
		setWifis({})
		tryVerify(() => model.rowCount() === 0)
		compare(sortedModel.rowCount(), 0)
		verify(model.valid)
		compare(model.connectedNetworkName, qsTrId("wifimodel_disconnected_ap_off"))
	}

	function test_malformedJson() {
		// Invalid JSON is ignored, and the existing networks are retained.
		MockManager.setValue(servicesUid, "{\"wifi\":{")
		wait(50)
		compare(model.rowCount(), Object.keys(defaultWifis()).length)
		compare(model.connectedNetworkName, "Network C")
		compare(rowsRemovedSpy.count, 0)
	}

	function test_missingService() {
		// Entries without a service cannot be identified, so they are ignored rather than
		// being re-inserted on every update.
		let wifis = defaultWifis()
		wifis["No Service"] = wifiNetwork("", "idle", 50, false)
		delete wifis["No Service"].Service
		wifis["Not An Object"] = "invalid"
		setWifis(wifis)
		wait(50)
		setWifis(wifis)
		wait(50)

		compare(model.rowCount(), Object.keys(defaultWifis()).length)
		compare(findRow("No Service"), -1)
		compare(findRow("Not An Object"), -1)
		compare(rowsInsertedSpy.count, 0)
		compare(rowsRemovedSpy.count, 0)
	}

	function test_sorted() {
		// Connected network first, then in order of signal strength.
		compare(sortedModel.rowCount(), model.rowCount())
		compare(sortedNetworkNames(), ["Network C", "", "Network D", "Network B", "Network A"])
	}

	function test_sortedOnlineIsConnected() {
		let wifis = defaultWifis()
		wifis["Network C"].State = "idle"
		wifis["Network A"].State = "online"
		setWifis(wifis)
		trySortedNames("Network A,,Network C,Network D,Network B")
	}

	function test_sortedAfterStrengthChange() {
		let wifis = defaultWifis()
		wifis["Network A"].Strength = 99
		setWifis(wifis)
		trySortedNames("Network C,Network A,,Network D,Network B")

		// A connected network always sorts first, even when it has the weakest signal.
		wifis["Network C"].Strength = 1
		setWifis(wifis)
		trySortedNames("Network C,Network A,,Network D,Network B")
	}

	function test_sortedAfterAddAndRemove() {
		let wifis = defaultWifis()
		wifis["Network E"] = wifiNetwork("wifi_e", "idle", 70, false)
		delete wifis[""]
		setWifis(wifis)
		trySortedNames("Network C,Network E,Network D,Network B,Network A")
	}

	function test_sortedNoConnectedNetwork() {
		let wifis = defaultWifis()
		wifis["Network C"].State = "idle"
		setWifis(wifis)
		trySortedNames(",Network C,Network D,Network B,Network A")
	}

	function test_platformServiceRemoved() {
		compare(model.rowCount(), Object.keys(defaultWifis()).length)

		// When the platform service is removed, the model is cleared.
		MockManager.removeValue(platformUid)
		tryCompare(model, "valid", false)
		compare(model.rowCount(), 0)
		compare(sortedModel.rowCount(), 0)
		compare(model.connectedNetworkName, qsTrId("wifimodel_disconnected"))
	}

	function test_platformServiceReAdded() {
		MockManager.removeValue(platformUid)
		tryCompare(model, "valid", false)
		compare(model.rowCount(), 0)

		// When the platform service is added again, the model is rebound to the new service.
		setupNetwork()
		compare(model.connectedNetworkName, "Network C")
		trySortedNames("Network C,,Network D,Network B,Network A")

		// Changes to the new service are reflected in the model.
		let wifis = defaultWifis()
		wifis["Network E"] = wifiNetwork("wifi_e", "idle", 70, false)
		setWifis(wifis)
		tryVerify(() => findRow("Network E") >= 0)

		MockManager.setValue(accessPointUid, 1)
		wifis["Network C"].State = "idle"
		setWifis(wifis)
		tryCompare(model, "connectedNetworkName", qsTrId("wifimodel_disconnected_ap_on"))
	}

	function test_platformServiceRemovedRepeatedly() {
		for (let i = 0; i < 3; ++i) {
			MockManager.removeValue(platformUid)
			tryCompare(model, "valid", false)
			compare(model.rowCount(), 0)

			setupNetwork()
			compare(model.connectedNetworkName, "Network C")
		}
	}

	function test_createdWithExistingPlatformService() {
		// A model created after the platform service exists binds to it immediately.
		const newModel = createTemporaryObject(wifiModelComponent, root)
		verify(newModel)
		tryCompare(newModel, "valid", true)
		tryCompare(newModel, "connectedNetworkName", "Network C")
		compare(newModel.rowCount(), Object.keys(defaultWifis()).length)
	}

	function test_createdWithoutPlatformService() {
		MockManager.removeValue(platformUid)
		tryCompare(model, "valid", false)

		// A model created before the platform service exists binds to it once it is added.
		const newModel = createTemporaryObject(wifiModelComponent, root)
		verify(newModel)
		wait(50)
		compare(newModel.valid, false)
		compare(newModel.rowCount(), 0)
		compare(newModel.connectedNetworkName, qsTrId("wifimodel_disconnected"))

		setupNetwork()
		tryCompare(newModel, "valid", true)
		tryCompare(newModel, "connectedNetworkName", "Network C")
		compare(newModel.rowCount(), Object.keys(defaultWifis()).length)

		// It is cleared again when the service is removed.
		MockManager.removeValue(platformUid)
		tryCompare(newModel, "valid", false)
		compare(newModel.rowCount(), 0)
	}
}
