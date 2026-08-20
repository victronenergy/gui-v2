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
		model: DelegateComponentModel {
			DelegateComponent {
				ListSwitch {
					text: CommonWords.automatic_scanning
					dataItem.uid: root.settings + "/AutoScan"
				}
			}

			DelegateComponent {
				property bool userHasWriteAccess: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
				preferredVisible: userHasWriteAccess
				ListButton {
					//% "Scan for devices"
					text: qsTrId("page_settings_modbus_scan_for_devices")
					secondaryText: scanItem.value ? CommonWords.scanning.arg(Math.round(scanProgressItem.value || 0)) : CommonWords.scan_action
					onClicked: scanItem.setValue(!scanItem.value)
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Saved devices"
					text: qsTrId("page_settings_modbus_saved_devices")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusDevices.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					text: CommonWords.discovered_devices
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusDiscovered.qml", {"title": text})
				}
			}
		}
	}
}
