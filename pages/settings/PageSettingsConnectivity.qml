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
				//% "Ethernet"
				text: qsTrId("pagesettingsconnectivity_ethernet")
				secondaryText: networkServices.state !== "idle" && networkServices.state !== ""
					? (networkServices.ipAddress ? networkServices.ipAddress : Utils.connmanServiceState(networkServices.state))
					//% "Unplugged"
					: qsTrId("settings_tcpip_connection_unplugged")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEthernet.qml", {"title": text})
			}

			ListNavigation {
				//% "Wi-Fi"
				text: qsTrId("pagesettingsconnectivity_wifi")
				secondaryText: wifiModel.connectedNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsWifi.qml", {"title": text})
				WifiModel {
					id: wifiModel
				}
			}

			ListNavigation {
				//% "Bluetooth"
				text: qsTrId("pagesettingsconnectivity_bluetooth")
				secondaryText: networkServices.hasBluetoothSupport
					? (bluetooth.value === 1 ? CommonWords.enabled : CommonWords.disabled)
					//% "No Bluetooth adapter connected"
					: qsTrId("settings_bluetooth_not_available")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBluetooth.qml", {"title": text})

				VeQuickItem {
					id: bluetooth
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Bluetooth"
				}
			}

			ListNavigation {
				//% "Mobile Network"
				text: qsTrId("pagesettingsconnectivity_mobile_network")
				//% "No cellular modem connected"
				secondaryText: simStatus.valid ? networkServices.mobileNetworkName : qsTrId("page_settings_no_cellular_modem_connected")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGsm.qml", {"title": text})

				VeQuickItem {
					id: simStatus
					uid: BackendConnection.serviceUidForType("modem") + "/SimStatus"
				}
			}

			SettingsListHeader { }

			ListNavigation {
				//% "Tailscale (remote VPN access)"
				text: qsTrId("settings_services_tailscale_remote_vpn_access")
				secondaryText: tailscale.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsTailscale.qml", { title: text })
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
						text: modelData["name"] || ""
						secondaryText: canbusProfile.profileText
						onClicked: Global.pageManager.pushPage(canBusComponent, { title: text, canbusProfile: canbusProfile })

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
