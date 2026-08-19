/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DelegateComponentModel {
	id: root

	required property NetworkServices networkServices
	required property NetworkServices ethernetNetworkServices

	DelegateComponent {
		preferredVisible: networkServices.wifi
		ListText {
			//% "Name"
			text: qsTrId("settings_tcpip_name")
			secondaryText: !networkServices.wifi
					 //% "Wired"
					? qsTrId("settings_tcpip_wired")
					 //% "[Hidden]"
					: networkServices.network || qsTrId("settings_tcpip_hidden")
		}
	}

	DelegateComponent {
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.disconnected
				 && !networkServices.favorite && networkServices.secured
		ListTextField {
			text: CommonWords.password
			maximumLength: 63
			writeAccessLevel: VenusOS.User_AccessType_User
			saveInput: function() {
				var obj = {
					Service: networkServices.service,
					Action: "connect",
					Passphrase: secondaryText
				}
				var json = JSON.stringify(obj);
				networkServices.setValueItem.setValue(json)
			}
		}
	}

	DelegateComponent {
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.disconnected
				 && (networkServices.favorite || !networkServices.secured)
		ListButton {
			//% "Connect to network?"
			text: qsTrId("settings_tcpip_connect_to_network")
			//% "Connect"
			secondaryText: qsTrId("settings_tcpip_connect")
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: networkServices.performAction("connect")
		}
	}

	DelegateComponent {
		preferredVisible: networkServices.ready && networkServices.wifi && networkServices.favorite
		ListButton {
			id: forgetNetworkButton

			//% "Forget network?"
			text: qsTrId("settings_tcpip_forget_network")
			//% "Forget"
			secondaryText: qsTrId("settings_tcpip_forget")
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
	}

	DelegateComponent {
		preferredVisible: networkServices.wifi
		ListQuantity {
			text: CommonWords.signal_strength
			value: networkServices.strength
			unit: VenusOS.Units_Percentage
		}
	}

	DelegateComponent {
		ListText {
			text: CommonWords.state
			secondaryText: Utils.connmanServiceState(networkServices.networkState)
		}
	}

	DelegateComponent {
		ListText {
			//% "MAC address"
			text: qsTrId("settings_tcpip_mac_address")
			secondaryText: networkServices.macAddress
		}
	}

	DelegateComponent {
		id: methodDC
		property bool userHasWriteAccess: Global.systemSettings.canAccess(VenusOS.User_AccessType_User)
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
	}

	DelegateComponent {
		id: ethernetGatewayEnabledDC
		dataItem: VeQuickItem { uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/GatewayEnabled" }
		property bool checked: dataItem.value === true
		preferredVisible: !networkServices.wifi
		ListSwitch {
			id: ethernetGatewayEnabled

			//% "Allow using ethernet for internet access"
			text: qsTrId("settings_tcpip_ethernet_gateway_enabled")
			dataItem.uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/GatewayEnabled"
			writeAccessLevel: VenusOS.User_AccessType_User
			valueTrue: true
			valueFalse: false
			updateDataOnClick: false

			onClicked: {
				if (!ethernetGatewayEnabledDC.checked) {
					ethernetGatewayEnabled.toggleDataValue()
				} else {
					Global.dialogLayer.open(disableEthernetGatewayComponent)
				}
			}

			Component {
				id: disableEthernetGatewayComponent

				ModalWarningDialog {
					dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
					//% "Disable internet access over ethernet?"
					title: qsTrId("settings_tcpip_disable_ethernet_gateway")
					//% "This will disconnect the device from VRM, unless it can connect to VRM over WiFi. Are you sure that you want to disable internet access over ethernet?"
					description: qsTrId("settings_tcpip_disable_ethernet_gateway_confirm")
					onAccepted: ethernetGatewayEnabled.toggleDataValue()
				}
			}
		}
	}

	DelegateComponent {
		ListIpAddressField {
			interactive: networkServices.manual
			writeAccessLevel: VenusOS.User_AccessType_User
			secondaryText: networkServices.ipAddress
			saveInput: function() { networkServices.setServiceProperty("Address", secondaryText) }
		}
	}

	DelegateComponent {
		ListIpAddressField {
			//% "Netmask"
			text: qsTrId("settings_tcpip_netmask")
			interactive: methodDC.userHasWriteAccess && networkServices.manual
			writeAccessLevel: VenusOS.User_AccessType_User
			secondaryText: networkServices.netmask
			saveInput: function() { networkServices.setServiceProperty("Netmask", secondaryText) }
		}
	}

	DelegateComponent {
		id: wifiGatewayEnabledDC
		dataItem: VeQuickItem { uid: networkServices.wifi ? Global.venusPlatform.serviceUid + "/Network/Wifi/GatewayEnabled" : "" }
		preferredVisible: networkServices.wifi
			? (wifiGatewayEnabledDC.dataItem.valid
				&& wifiGatewayEnabledDC.dataItem.value === true
				&& (ethernetNetworkServices.ipAddress.length === 0 || !ethernetGatewayEnabledDC.checked))
			: ethernetGatewayEnabledDC.checked
		ListIpAddressField {
			//% "Gateway"
			text: qsTrId("settings_tcpip_gateway")
			interactive: methodDC.userHasWriteAccess && networkServices.manual
			// if we are connected to both wifi and ethernet,
			// if we are currently showing a wifi settings page
			// we should hide the gateway field if the ethernet gateway is also enabled,
			// because the system will override the wifi gateway address to null
			// in order to prefer routing traffic via the ethernet gateway.
			writeAccessLevel: VenusOS.User_AccessType_User
			secondaryText: networkServices.gateway
			saveInput: function() { networkServices.setServiceProperty("Gateway", secondaryText) }
		}
	}

	DelegateComponent {
		ListIpAddressField {
			//% "DNS server"
			text: qsTrId("settings_tcpip_dns_server")
			interactive: methodDC.userHasWriteAccess && networkServices.manual
			writeAccessLevel: VenusOS.User_AccessType_User
			secondaryText: networkServices.nameserver
			saveInput: function() { networkServices.setServiceProperty("Nameserver", secondaryText) }
		}
	}

	DelegateComponent {
		preferredVisible: !networkServices.wifi
		ListSwitch {
			//% "Enable Link-local"
			text: qsTrId("settings_tcpip_ethernet_linklocal_enabled")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/EthernetLinkLocal"
			writeAccessLevel: VenusOS.User_AccessType_User
		}
	}

	DelegateComponent {
		preferredVisible: !networkServices.wifi
		ListText {
			id: linklocal

			//% "Link-local IP address"
			text: qsTrId("settings_tcpip_link_local")
			dataItem.uid: Global.venusPlatform.serviceUid + "/Network/Ethernet/LinkLocalIpAddress"
		}
	}
}
