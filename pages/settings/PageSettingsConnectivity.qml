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
				secondaryText: networkServices.ipAddress
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
				preferredVisible: networkServices.hasBluetoothSupport
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBluetooth.qml", {"title": text})
			}

			ListNavigation {
				//% "Mobile Network"
				text: qsTrId("pagesettingsconnectivity_mobile_network")
				secondaryText: networkServices.mobileNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGsm.qml", {"title": text})
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
