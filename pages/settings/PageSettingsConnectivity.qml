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
				allowed: hasBluetoothSupport.value
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBluetooth.qml", {"title": text})
			}

			ListNavigation {
				//% "Mobile Network"
				text: qsTrId("pagesettingsconnectivity_mobile_network")
				secondaryText: dataItem.isValid ? dataItem.value + " " + Utils.simplifiedNetworkType(networkType.value) : "--"
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsGsm.qml", {"title": text})

				VeQuickItem {
					id: dataItem
					uid: BackendConnection.serviceUidForType("modem") + "/NetworkName"
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
	VeQuickItem {
		id: hasBluetoothSupport
		uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
	}
}
