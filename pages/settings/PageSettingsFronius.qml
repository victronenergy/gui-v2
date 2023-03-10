/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListPage {
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

	listView: GradientListView {
		model: ObjectModel {
			ListNavigationItem {
				//% "Inverters"
				text: qsTrId("page_settings_fronius_inverters")
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/PageSettingsFroniusInverters.qml", {"title": text}, listIndex)
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
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/PageSettingsFroniusShowIpAddresses.qml", {"title": text}, listIndex)
			}

			ListNavigationItem {
				//% "Add IP address manually"
				text: qsTrId("page_settings_fronius_add_ip_address_manually")
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/PageSettingsFroniusSetIpAddresses.qml", {"title": text}, listIndex)
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
