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

		model: VisibleItemModel {
			ListNavigation {
				id: ethernetItem
				//% "Ethernet"
				text: qsTrId("pagesettingsconnectivity_ethernet")
				secondaryText: networkServices.ipAddress
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEthernet.qml", {"title": Qt.binding(function() { return ethernetItem.text })})
			}

			ListNavigation {
				id: wifiItem
				//% "Wi-Fi"
				text: qsTrId("pagesettingsconnectivity_wifi")
				secondaryText: wifiModel.connectedNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsWifi.qml", {"title": Qt.binding(function() { return wifiItem.text })})
				WifiModel {
					id: wifiModel
				}
			}

			ListNavigation {
				id: bluetoothItem
				//% "Bluetooth"
				text: qsTrId("pagesettingsconnectivity_bluetooth")
				preferredVisible: networkServices.hasBluetoothSupport
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBluetooth.qml", {"title": Qt.binding(function() { return bluetoothItem.text })})
			}

			ListNavigation {
				id: gsmItem
				//% "Mobile Network"
				text: qsTrId("pagesettingsconnectivity_mobile_network")
				secondaryText: networkServices.mobileNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGsm.qml", {"title": Qt.binding(function() { return gsmItem.text })})
			}

			SettingsListHeader { }

			ListNavigation {
				id: tailscaleItem
				//% "Tailscale (remote VPN access)"
				text: qsTrId("settings_services_tailscale_remote_vpn_access")
				secondaryText: tailscale.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsTailscale.qml", { title: Qt.binding(function() { return tailscaleItem.text }) })
				}
				preferredVisible: tailscale.valid

				VeQuickItem {
					id: tailscale
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"
				}
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: canInterfaceRepeater.count > 0

				Repeater {
					id: canInterfaceRepeater
					model: canInterfaces.value || []
					delegate: ListNavigation {
						id: canInterfaceDelegate
						text: modelData["name"] || ""
						secondaryText: canbusProfile.profileText
						onClicked: Global.pageManager.pushPage(canBusComponent, { title: Qt.binding(function() { return canInterfaceDelegate.text }), canbusProfile: canbusProfile })

						Component {
							id: canBusComponent

							PageSettingsCanbus { }
						}

						CanbusProfile {
							id: canbusProfile

							gateway: modelData["interface"]
							canConfig: modelData["config"]
						}
					}
				}

				VeQuickItem {
					id: canInterfaces
					uid: Global.venusPlatform.serviceUid + "/CanBus/Interfaces"
					// eg. value: [{"config":1,"interface":"can1","name":"BMS-Can port"},{"config":0,"interface":"can0","name":"VE.Can port"}]
				}
			}

			ListSwitch {
				//% "CAN-bus over TCP/IP (Debug)"
				text: qsTrId("settings_services_canbus_over_tcpip_debug")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Socketcand"
				showAccessLevel: VenusOS.User_AccessType_Service
			}
		}
	}

	NetworkServices {
		id: networkServices
	}
}
