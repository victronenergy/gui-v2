/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
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
				allowed: networkServices.hasBluetoothSupport
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
				allowed: tailscale.isValid

				VeQuickItem {
					id: tailscale
					uid: Global.systemSettings.serviceUid + "/Settings/Services/Tailscale/Enabled"
				}
			}

			ListNavigation {
				//% "GPS"
				text: qsTrId("settings_gps")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGpsList.qml", {"title": text})
			}

			ListNavigation {
				//% "BMS-Can"
				text: qsTrId("settings_bms_can")
				onClicked: console.log("TODO - find out what goes on this page")
			}

			ListNavigation {
				//% "VE.Can"
				text: qsTrId("settings_ve_can")
				onClicked: console.log("TODO - find out what goes on this page")
			}
		}
	}

	NetworkServices {
		id: networkServices
	}
}
