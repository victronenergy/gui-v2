/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
		model: DelegateComponentModel {
			DelegateComponent {
				ListNavigation {
					//% "Inverters"
					text: qsTrId("page_settings_fronius_inverters")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusInverters.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListButton {
					//% "Find PV inverters"
					text: qsTrId("page_settings_fronius_find_pv_inverters")
					secondaryText: autoDetectItem.value ? CommonWords.scanning.arg(scanProgressItem.value || 0) : CommonWords.scan_action
					writeAccessLevel: VenusOS.User_AccessType_User
					onClicked: autoDetectItem.setValue(autoDetectItem.value === 0 ? 1 : 0)
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Detected IP addresses"
					text: qsTrId("page_settings_fronius_detected_ip_addresses")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusShowIpAddresses.qml", {"title": text})
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Add IP address manually"
					text: qsTrId("page_settings_fronius_add_ip_address_manually")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusSetIpAddresses.qml", {"title": text})
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Fronius/PortNumber" }
				preferredVisible: dataItem.value !== 80
				ListPortField {
					//% "TCP port"
					text: qsTrId("page_settings_fronius_tcp_port")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/PortNumber"
				}
			}

			DelegateComponent {
				ListSwitch {
					text: CommonWords.automatic_scanning
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/AutoScan"
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Modbus port and unit ID settings"
					text: qsTrId("page_settings_fronius_modbus_settings")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFroniusModbus.qml", {"title": text})
				}
			}
		}
	}
}
