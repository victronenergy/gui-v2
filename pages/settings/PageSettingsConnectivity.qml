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
				text: CommonWords.ethernet
				secondaryText: networkServices.ipAddress
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEthernet.qml")
			}

			ListNavigation {
				text: CommonWords.wifi
				secondaryText: wifiModel.connectedNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsWifi.qml")
				WifiModel {
					id: wifiModel
				}
			}

			ListNavigation {
				text: CommonWords.bluetooth
				preferredVisible: networkServices.hasBluetoothSupport
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBluetooth.qml")
			}

			ListNavigation {
				text: CommonWords.mobile_network
				secondaryText: networkServices.mobileNetworkName
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGsm.qml")
			}

			SettingsListHeader { }

			ListNavigation {
				id: tailscaleItem
				//% "Tailscale (remote VPN access)"
				text: qsTrId("settings_services_tailscale_remote_vpn_access")
				secondaryText: tailscale.value === 1 ? CommonWords.enabled : CommonWords.disabled
				onClicked: Global.pageManager.pushPage(pageSettingsTailscale)
				preferredVisible: tailscale.valid

				VeQuickItem {
					id: tailscale
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"
				}

				Component { id: pageSettingsTailscale; PageSettingsTailscale { title: tailscaleItem.text } }
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
						onClicked: Global.pageManager.pushPage(canBusComponent, { canbusProfile: canbusProfile })

						Component {
							id: canBusComponent

							PageSettingsCanbus { title: canInterfaceDelegate.text }
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
