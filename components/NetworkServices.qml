/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VeQuickItem {
	id: root

	property string service
	property string state
	property string method_
	property string macAddress
	property string ipAddress: ""
	property string netmask
	property string gateway
	property string nameserver
	property string strength
	readonly property bool manual: method_ === "manual"
	property bool secured
	property bool favorite
	property bool completed
	readonly property bool hasBluetoothSupport: _hasBluetoothSupport.value
	readonly property string mobileNetworkName: _networkName.valid ? _networkName.value + " " + Utils.simplifiedNetworkType(_networkType.value) : "--"

	property VeQuickItem setValueItem: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Network/SetValue"
	}

	property VeQuickItem _hasBluetoothSupport: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
	}

	property VeQuickItem _networkName: VeQuickItem {
		uid: BackendConnection.serviceUidForType("modem") + "/NetworkName"
	}

	property VeQuickItem _networkType: VeQuickItem {
		uid: BackendConnection.serviceUidForType("modem") + "/NetworkType"
	}

	property string network: "Wired"
	property string tech: "ethernet"
	readonly property bool ready: root.service.length > 0
	readonly property bool wifi: tech === "wifi"

	function performAction(action) {
		setServiceProperty("Action", action)
	}

	function setServiceProperty(item, value) {
		var obj = { Service: root.service };
		obj[item] = value
		setValueItem.setValue(JSON.stringify(obj))
	}

	function setAgent(action) {
		setValueItem.setValue(JSON.stringify({Agent: action}))
	}

	function parseJson() {
		if (!valid || typeof value !== "string") {
			return
		}

		const services = JSON.parse(value)

		let details

		// Find the network service using service identifier
		if (root.service.length > 0) {
			for (const [network, networkDetails] of Object.entries(services[tech])) {
				if (root.service === networkDetails["Service"]) {
					root.network = network // SSID name may have been updated
					details = networkDetails
					break
				}
			}
		} else if (network.length > 0) {
			// If not available use the network name instead (in Ethernet case "Wired")
			details = network && services[tech][network] ? services[tech][network] : undefined
		}

		if (details) {
			root.service = details["Service"]
			state = details["State"]
			method_ = details["Method"]
			ipAddress = details["Address"]
			macAddress = details["Mac"]
			netmask = details["Netmask"]
			gateway = details["Gateway"]
			nameserver = details["Nameservers"][0] || ""
			strength = details["Strength"] || ""
			secured = details["Secured"] === "yes"
			favorite = details["Favorite"] === "yes"
		}
	}

	uid: Global.venusPlatform.serviceUid + "/Network/Services"

	// Only handle changed value after component completion because otherwise <network> may not be set correctly.
	onValueChanged: if (completed) parseJson()
	Component.onCompleted: {
		completed = true
		parseJson()
		if (root.wifi) {
			setAgent("on")
		}
	}

	Component.onDestruction: {
		if (root.wifi)
			setAgent("off")
	}
}

