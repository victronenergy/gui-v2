/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: model

	readonly property bool valid: servicesItem.valid && scanItem.valid
	readonly property string connectedNetworkName: {
		for (let i = 0; i < count; ++i) {
			let network = get(i)
			if (["ready", "online"].indexOf(network.state) !== -1) {
				return network.network
			}
		}
		if (accessPoint.valid) {
			return accessPoint.value === 1
				//% "Disconnected | AP On"
				? qsTrId("wifimodel_disconnected_ap_on")
				//% "Disconnected | AP Off"
				: qsTrId("wifimodel_disconnected_ap_off")
		}
		//% "Disconnected"
		return qsTrId("wifimodel_disconnected")
	}

	property VeQuickItem servicesItem: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Network/Services"

		// TODO ideally this would be an QAbstractListModel that updates itself progressively,
		// instead of needing to reload the whole model.
		onValueChanged: update()
	}

	property VeQuickItem scanItem: VeQuickItem{
		uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/Scan"
		onValueChanged: update()
	}

	property VeQuickItem accessPoint: VeQuickItem{
		uid: Global.venusPlatform.serviceUid + "/Services/AccessPoint/Enabled"
		onValueChanged: update()
	}

	function update() {
		if (!valid || !scanItem.valid) {
			model.clear()
			return
		}

		/*
			Following config is provided for each network item:

			"Victron": {
				"Service": "/net/connman/service/wifi_5cc5633c7cfa_56696374726f6e_managed_ieee8021x",
				"State": "Disconnected",
				"Strength": "45",
				"Secured": "yes",
				"Favorite": "yes",
				"Address": "192.168.68.62",
				"Gateway": "",
				"Method": "manual",
				"Netmask": "255.255.252.0",
				"Mac": "5C:C5:63:3C:7C:FA",
				"Nameservers": ["193.12.34.56", "193.12.34.57"]
			}
		*/
		const wifis = JSON.parse(servicesItem.value)["wifi"]

		const services = Object.values(wifis)
		  .filter((object) => object && typeof object === "object")
		  .map((object) => object["Service"])

		// Remove networks that have been dropped
		for (var i = 0; i < model.count; i++) {
			if (services.indexOf(model.get(i).service) == -1) {
				model.remove(i)
			}
		}

		i = 0
		for (const [network, details] of Object.entries(wifis)) {
			let service = details["Service"]
			let found = false
			for (let j = 0; j < model.count; j++) {
				// Update existing networks
				if (service && service === model.get(j).service) {
					found = true
					model.set(j, {
						"network": network,
						"service": service,
						"state": details["State"],
						"favorite": details["Favorite"] === "yes"
					})
					break
				}
			}

			// Insert newly discovered networks
			if (!found) {
				// Services are sorted by favorite and signal strength, try to maintain order
				model.insert(i, {
					"network": network,
					"service": service,
					"state": details["State"],
					"favorite": details["Favorite"] === "yes"
				})
			}
			i++
		}
	}

	onValidChanged: update()
}
