/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string service: BackendConnection.serviceUidFromName("com.victronenergy.modbusclient.tcp", 0)
	property string settings: Global.systemSettings.serviceUid + "/Settings/ModbusClient/tcp"

	VeQuickItem {
		id: scanItem

		uid: root.service + "/Scan"
	}

	VeQuickItem {
		id: scanProgressItem

		uid: root.service + "/ScanProgress"
	}


	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				text: CommonWords.automatic_scanning
				dataItem.uid: root.settings + "/AutoScan"
			}

			ListButton {
				//% "Scan for devices"
				text: qsTrId("page_settings_modbus_scan_for_devices")
				secondaryText: scanItem.value ? CommonWords.scanning.arg(Math.round(scanProgressItem.value || 0)) : CommonWords.press_to_scan
				onClicked: scanItem.setValue(!scanItem.value)
				preferredVisible: userHasWriteAccess
			}

			ListNavigation {
				//% "Saved devices"
				text: qsTrId("page_settings_modbus_saved_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusDevices.qml", {"title": root.title})
			}

			ListNavigation {
				//% "Discovered devices"
				text: qsTrId("page_settings_modbus_discovered_devices")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusDiscovered.qml", {"title": root.title})
			}
		}
	}
}
