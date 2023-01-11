/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root // TODO: update this UI when a design is available

	property string settings: "com.victronenergy.settings"
	property string gateway: "com.victronenergy.fronius"

	DataPoint {
		id: autoDetectItem

		source: gateway + "/AutoDetect"
	}

	DataPoint {
		id: scanProgressItem

		source: gateway + "/ScanProgress"
	}

	SettingsListView {
		model: ObjectModel {
			SettingsListNavigationItem {
				//% "Inverters"
				text: qsTrId("page_settings_fronius_inverters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusInverters.qml", {"title": text})
			}

			SettingsListButton {
				//% "Find PV inverters"
				text: qsTrId("page_settings_fronius_find_pv_inverters")
				secondaryText: autoDetectItem.value ? CommonWords.scanning.arg(scanProgressItem.value) : CommonWords.press_to_scan
				onClicked: autoDetectItem.setValue(autoDetectItem.value === 0 ? 1 : 0)
			}

			SettingsListNavigationItem {
				//% "Detected IP addresses"
				text: qsTrId("page_settings_fronius_detected_ip_addresses")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusShowIpAddresses.qml", {"title": text})
			}

			SettingsListNavigationItem {
				//% "Add IP address manually"
				text: qsTrId("page_settings_fronius_add_ip_address_manually")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusSetIpAddresses.qml", {"title": text})
			}

			SettingsListPortField {
				//% "TCP port"
				text: qsTrId("page_settings_fronius_tcp_port")
				visible: value !== 80
				source: settings + "/Settings/Fronius/PortNumber"
			}

			SettingsListSwitch {
				text: CommonWords.automatic_scanning
				source: settings + "/Settings/Fronius/AutoScan"
			}
		}
	}
}
