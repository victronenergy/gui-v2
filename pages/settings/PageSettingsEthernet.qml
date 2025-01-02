/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView
		model: networkServices.ready ? connectedModel : disconnectedModel
	}

	ObjectModel {
		id: disconnectedModel

		ListText {
			text: CommonWords.state
			secondaryText: networkServices.wifi
					 //% "Connection lost"
					? qsTrId("settings_tcpip_connection_lost")
					 //% "Unplugged"
					: qsTrId("settings_tcpip_connection_unplugged")
		}
	}

	ObjectModel {
		id: connectedModel

		ListText {
			text: CommonWords.state
			secondaryText: Utils.connmanServiceState(networkServices.state)
		}

		// TODO: Report MAC address (BSSID) of Wi-Fi networks (see Venus issue #364)
		ListText {
			//% "MAC address"
			text: qsTrId("settings_tcpip_mac_address")
			secondaryText: networkServices.macAddress
			allowed: !networkServices.wifi
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
					if (optionModel[i].value === networkServices.method_) {
						return i
					}
				}
				return -1
			}

			enabled: userHasReadAccess
			allowed: defaultAllowed

			onOptionClicked: function(index) {
				networkServices.setServiceProperty("Method", optionModel[index].value)
			}
		}

		ListIpAddressField {
			enabled: method.userHasWriteAccess && networkServices.manual
			textField.text: networkServices.ipAddress
			saveInput: function() { networkServices.setServiceProperty("Address", textField.text) }
		}

		ListIpAddressField {
			//% "Netmask"
			text: qsTrId("settings_tcpip_netmask")
			enabled: method.userHasWriteAccess && networkServices.manual
			textField.text: networkServices.netmask
			saveInput: function() { networkServices.setServiceProperty("Netmask", textField.text) }
		}

		ListIpAddressField {
			//% "Gateway"
			text: qsTrId("settings_tcpip_gateway")
			enabled: method.userHasWriteAccess && networkServices.manual
			textField.text: networkServices.gateway
			saveInput: function() { networkServices.setServiceProperty("Gateway", textField.text) }
		}

		ListIpAddressField {
			//% "DNS server"
			text: qsTrId("settings_tcpip_dns_server")
			enabled: method.userHasWriteAccess && networkServices.manual
			textField.text: networkServices.nameserver
			saveInput: function() { networkServices.setServiceProperty("Nameserver", textField.text) }
		}

		ListText {
			id: linklocal

			//% "Link-local IP address"
			text: qsTrId("settings_tcpip_link_local")
			allowed: !networkServices.wifi
			dataItem.uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/LinkLocalIpAddress"
		}
	}

	NetworkServices {
		id: networkServices
	}
}
