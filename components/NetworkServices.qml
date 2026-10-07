/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VeQuickItem {
	id: root

	property string service
	property string networkState // don't shadow VeQuickItem::state
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
	readonly property bool disconnected: networkState === "idle" || networkState === "failure"

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
		const techServices = services[tech] || {}

		let details

		// Find the network service using service identifier
		if (root.service.length > 0) {
			for (const [network, networkDetails] of Object.entries(techServices)) {
				if (root.service === networkDetails["Service"]) {
					root.network = network // SSID name may have been updated
					details = networkDetails
					break
				}
			}
		} else if (network.length > 0) {
			// If not available use the network name instead (in Ethernet case "Wired")
			details = techServices[network]
		}

		if (details) {
			root.service = details["Service"]
			networkState = details["State"]
			method_ = details["Method"]
			ipAddress = details["Address"]
			macAddress = details["Mac"]
			netmask = details["Netmask"]
			gateway = details["Gateway"]
			nameserver = details["Nameservers"][0] || ""
			strength = details["Strength"] || ""
			secured = details["Secured"] === "yes"
			favorite = details["Favorite"] === "yes"
		} else {
			// The service has gone away, e.g. connman removes the ethernet service when the
			// cable is unplugged. Clear the cached details so that stale values (such as the
			// IP address) are not shown, and so the service is looked up again by name.
			root.service = ""
			networkState = ""
			method_ = ""
			ipAddress = ""
			macAddress = ""
			netmask = ""
			gateway = ""
			nameserver = ""
			strength = ""
			secured = false
			favorite = false
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

