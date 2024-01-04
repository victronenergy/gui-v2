/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Utils
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root // TODO: update this UI when a design is available

	readonly property string froniusServiceUid: BackendConnection.serviceUidForType("fronius")

	VeQuickItem {
		id: autoDetectItem

		uid: root.froniusServiceUid + "/AutoDetect"
	}

	VeQuickItem {
		id: scanProgressItem

		uid: root.froniusServiceUid + "/ScanProgress"
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
				visible: dataItem.value !== 80
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/PortNumber"
			}

			ListSwitch {
				text: CommonWords.automatic_scanning
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/AutoScan"
			}
		}
	}
}
