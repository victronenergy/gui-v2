/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string network: "Wired"
	property string tech: "ethernet"

	property alias service: service.service
	readonly property bool ready: root.service.length > 0

	readonly property bool _wifi: tech === "wifi"
	readonly property bool _disconnected: service.state === "idle" || service.state === "failure"

	function performAction(action) {
		setServiceProperty("Action", action)
	}

	function setServiceProperty(item, value) {
		var obj = { Service: service.service };
		obj[item] = value
		setValueItem.setValue(JSON.stringify(obj))
	}

	function setAgent(action) {
		setValueItem.setValue(JSON.stringify({Agent: action}))
	}

	VeQuickItem {
		id: service

		uid: Global.venusPlatform.serviceUid + "/Network/Services"

		property string service
		property string state
		property string method_
		property string macAddress
		property string ipAddress
		property string netmask
		property string gateway
		property string nameserver
		property string strength
		readonly property bool manual: method_ === "manual"
		property bool secured
		property bool favorite
		property bool completed

		// Only handle changed value after component completion because otherwise <network> may not be set correctly.
		onValueChanged: if (completed) parseJson()
		Component.onCompleted: {
			completed = true
			parseJson()
			if (root._wifi) {
				setAgent("on")
			}
		}

		Component.onDestruction: {
			if (root._wifi)
				setAgent("off")
		}

		function parseJson() {
			if (!isValid || typeof value !== "string") {
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
	}

	VeQuickItem {
		id: setValueItem
		uid: Global.venusPlatform.serviceUid + "/Network/SetValue"
	}

	GradientListView {
		id: settingsListView
		model: root.ready ? connectedModel : disconnectedModel
	}

	ObjectModel {
		id: disconnectedModel

		ListTextItem {
			text: CommonWords.state
			secondaryText: root._wifi
					 //% "Connection lost"
					? qsTrId("settings_tcpip_connection_lost")
					 //% "Unplugged"
					: qsTrId("settings_tcpip_connection_unplugged")
		}
	}

	ObjectModel {
		id: connectedModel

		ListTextItem {
			text: CommonWords.state
			secondaryText: Utils.connmanServiceState(service.state)
		}

		ListTextItem {
			//% "Name"
			text: qsTrId("settings_tcpip_name")
			secondaryText: !root._wifi
					 //% "Wired"
					? qsTrId("settings_tcpip_wired")
					 //% "[Hidden]"
					: root.network || qsTrId("settings_tcpip_hidden")
			allowed: root._wifi
		}

		ListTextField {
			text: CommonWords.password
			textField.maximumLength: 63
			allowed: root.ready && root._wifi && root._disconnected
					 && !service.favorite && service.secured
			writeAccessLevel: VenusOS.User_AccessType_User
			saveInput: function() {
				var obj = {
					Service: service.service,
					Action: "connect",
					Passphrase: textField.text
				}
				var json = JSON.stringify(obj);
				setValueItem.setValue(json)
			}
		}

		ListButton {
			//% "Connect to network?"
			text: qsTrId("settings_tcpip_connect_to_network")
			//% "Connect"
			button.text: qsTrId("settings_tcpip_connect")
			allowed: root.ready && root._wifi && root._disconnected
					 && (service.favorite || !service.secured)
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: performAction("connect")
		}

		ListButton {
			id: forgetNetworkButton

			//% "Forget network?"
			text: qsTrId("settings_tcpip_forget_network")
			//% "Forget"
			button.text: qsTrId("settings_tcpip_forget")
			allowed: root.ready && root._wifi && service.favorite
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: Global.dialogLayer.open(forgetNetworkDialogComponent)

			Component {
				id: forgetNetworkDialogComponent

				ModalWarningDialog {
					dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
					title: forgetNetworkButton.text
					//% "Are you sure that you want to forget this network?"
					description: qsTrId("settings_tcpip_forget_confirm")
					onAccepted: performAction("remove")
				}
			}
		}

		ListQuantityItem {
			text: CommonWords.signal_strength
			value: service.strength
			unit: VenusOS.Units_Percentage
			allowed: root._wifi
		}

		// TODO: Report MAC address (BSSID) of Wi-Fi networks (see Venus issue #364)
		ListTextItem {
			//% "MAC address"
			text: qsTrId("settings_tcpip_mac_address")
			secondaryText: service.macAddress
			allowed: !root._wifi
		}

		ListRadioButtonGroup {
			id: method

			//% "IP configuration"
			text: qsTrId("settings_tcpip_ip_config")
			writeAccessLevel: VenusOS.User_AccessType_User
			optionModel: [
				//% "Automatic"
				{ display: qsTrId("settings_tcpip_auto"), value: "dhcp" },
				//% "Manual"
				{ display: qsTrId("settings_tcpip_manual"), value: "manual" },
				//% "Off"
				{ display: qsTrId("settings_tcpip_off"), value: "off", readOnly: true },
				//% "Fixed"
				{ display: qsTrId("settings_tcpip_fixed"), value: "fixed", readOnly: true },
			]
			currentIndex: {
				for (let i = 0; i < optionModel.length; ++i) {
					if (optionModel[i].value === service.method_) {
						return i
					}
				}
				return -1
			}

			enabled: userHasReadAccess
			allowed: defaultAllowed

			onOptionClicked: function(index) {
				setServiceProperty("Method", optionModel[index].value)
			}
		}

		ListIpAddressField {
			enabled: method.userHasWriteAccess && service.manual
			textField.text: service.ipAddress
			saveInput: function() { setServiceProperty("Address", textField.text) }
		}

		ListIpAddressField {
			//% "Netmask"
			text: qsTrId("settings_tcpip_netmask")
			enabled: method.userHasWriteAccess && service.manual
			textField.text: service.netmask
			saveInput: function() { setServiceProperty("Netmask", textField.text) }
		}

		ListIpAddressField {
			//% "Gateway"
			text: qsTrId("settings_tcpip_gateway")
			enabled: method.userHasWriteAccess && service.manual
			textField.text: service.gateway
			saveInput: function() { setServiceProperty("Gateway", textField.text) }
		}

		ListIpAddressField {
			//% "DNS server"
			text: qsTrId("settings_tcpip_dns_server")
			enabled: method.userHasWriteAccess && service.manual
			textField.text: service.nameserver
			saveInput: function() { setServiceProperty("Nameserver", textField.text) }
		}

		ListTextItem {
			id: linklocal

			//% "Link-local IP address"
			text: qsTrId("settings_tcpip_link_local")
			allowed: !root._wifi
			dataItem.uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/LinkLocalIpAddress"
		}
	}
}
