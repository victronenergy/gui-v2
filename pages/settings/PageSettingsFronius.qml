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

	GradientListView {
		model: ObjectModel {
			ListNavigationItem {
				//% "Inverters"
				text: qsTrId("page_settings_fronius_inverters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusInverters.qml", {"title": text})
			}

			ListButton {
				//% "Find PV inverters"
				text: qsTrId("page_settings_fronius_find_pv_inverters")
				secondaryText: autoDetectItem.value ? CommonWords.scanning.arg(scanProgressItem.value) : CommonWords.press_to_scan
				onClicked: autoDetectItem.setValue(autoDetectItem.value === 0 ? 1 : 0)
			}

			ListNavigationItem {
				//% "Detected IP addresses"
				text: qsTrId("page_settings_fronius_detected_ip_addresses")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusShowIpAddresses.qml", {"title": text})
			}

			ListNavigationItem {
				//% "Add IP address manually"
				text: qsTrId("page_settings_fronius_add_ip_address_manually")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusSetIpAddresses.qml", {"title": text})
			}

			ListPortField {
				//% "TCP port"
				text: qsTrId("page_settings_fronius_tcp_port")
				visible: dataValue !== 80
				dataSource: settings + "/Settings/Fronius/PortNumber"
			}

			ListSwitch {
				text: CommonWords.automatic_scanning
				dataSource: settings + "/Settings/Fronius/AutoScan"
			}
		}
	}
}
