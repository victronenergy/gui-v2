/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	required property NetworkServices networkServices

	ListText {
		//% "Name"
		text: qsTrId("settings_tcpip_name")
		secondaryText: !networkServices.wifi
				 //% "Wired"
				? qsTrId("settings_tcpip_wired")
				 //% "[Hidden]"
				: networkServices.network || qsTrId("settings_tcpip_hidden")
		preferredVisible: networkServices.wifi
	}

	ListTextField {
		text: CommonWords.password
		textField.maximumLength: 63
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.disconnected
				 && !networkServices.favorite && networkServices.secured
		writeAccessLevel: VenusOS.User_AccessType_User
		saveInput: function() {
			var obj = {
				Service: networkServices.service,
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
		secondaryText: qsTrId("settings_tcpip_connect")
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.disconnected
				 && (networkServices.favorite || !networkServices.secured)
		writeAccessLevel: VenusOS.User_AccessType_User
		onClicked: networkServices.performAction("connect")
	}

	ListButton {
		id: forgetNetworkButton

		//% "Forget network?"
		text: qsTrId("settings_tcpip_forget_network")
		//% "Forget"
		secondaryText: qsTrId("settings_tcpip_forget")
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.favorite
		writeAccessLevel: VenusOS.User_AccessType_User
		onClicked: Global.dialogLayer.open(forgetNetworkDialogComponent)

		Component {
			id: forgetNetworkDialogComponent

			ModalWarningDialog {
				dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
				title: forgetNetworkButton.text
				//% "Are you sure that you want to forget this network?"
				description: qsTrId("settings_tcpip_forget_confirm")
				onAccepted: networkServices.performAction("remove")
			}
		}
	}

	ListQuantity {
		text: CommonWords.signal_strength
		value: networkServices.strength
		unit: VenusOS.Units_Percentage
		preferredVisible: networkServices.wifi
	}

	ListText {
		text: CommonWords.state
		secondaryText: Utils.connmanServiceState(networkServices.state)
	}

	ListText {
		//% "MAC address"
		text: qsTrId("settings_tcpip_mac_address")
		secondaryText: networkServices.macAddress
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
		interactive: userHasReadAccess

		onOptionClicked: function(index) {
			networkServices.setServiceProperty("Method", optionModel[index].value)
		}
	}

	ListIpAddressField {
		interactive: networkServices.manual
		textField.text: networkServices.ipAddress
		saveInput: function() { networkServices.setServiceProperty("Address", textField.text) }
	}

	ListIpAddressField {
		//% "Netmask"
		text: qsTrId("settings_tcpip_netmask")
		interactive: method.userHasWriteAccess && networkServices.manual
		textField.text: networkServices.netmask
		saveInput: function() { networkServices.setServiceProperty("Netmask", textField.text) }
	}

	ListIpAddressField {
		//% "Gateway"
		text: qsTrId("settings_tcpip_gateway")
		interactive: method.userHasWriteAccess && networkServices.manual
		textField.text: networkServices.gateway
		saveInput: function() { networkServices.setServiceProperty("Gateway", textField.text) }
	}

	ListIpAddressField {
		//% "DNS server"
		text: qsTrId("settings_tcpip_dns_server")
		interactive: method.userHasWriteAccess && networkServices.manual
		textField.text: networkServices.nameserver
		saveInput: function() { networkServices.setServiceProperty("Nameserver", textField.text) }
	}

	ListText {
		id: linklocal

		//% "Link-local IP address"
		text: qsTrId("settings_tcpip_link_local")
		preferredVisible: !networkServices.wifi
		dataItem.uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/LinkLocalIpAddress"
	}
}
