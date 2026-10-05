/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("shelly")

	VeQuickItem {
		id: shellyServiceEnabled
		uid: Global.systemSettings.serviceUid + "/Settings/Services/Shelly"
	}

	// Get a list of all devices on the shelly service, sorted by name.
	SortedShellyDeviceModel {
		id: sortedShellyDeviceModel
		sourceModel: ShellyDeviceModel {}
	}

	GradientListView {
		id: shellyListView

		header: SettingsColumn {
			width: parent?.width ?? 0

			ListSwitch {
				//% "Enable Shelly integration"
				text: qsTrId("settings_shelly_integration")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Shelly"
			}

			ListSwitch {
				//% "Automatic device discovery"
				text: qsTrId("settings_shelly_autoscan")
				dataItem.uid: root.serviceUid + "/AutoScan"
				preferredVisible: shellyServiceEnabled.value === 1
			}

			ListNavigation {
				//% "Add IP address manually"
				text: qsTrId("page_settings_shelly_add_ip_address_manually")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsShellySetIpAddresses.qml", {"title": text, bindPrefix: root.serviceUid})
				preferredVisible: shellyServiceEnabled.value === 1
			}

			ListButton {
				//% "Refresh devices"
				text: qsTrId("settings_shelly_refresh_devices")
				//% "Refresh"
				secondaryText: qsTrId("settings_shelly_refresh")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: refreshItem.setValue(1)
				preferredVisible: shellyServiceEnabled.value === 1

				VeQuickItem {
					id: refreshItem
					uid: root.serviceUid + "/Refresh"
				}
			}

			SectionHeader {
				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				text: CommonWords.discovered_devices
				opacity: shellyListView.count > 0 ? 1 : 0 // set opacity instead of visible to avoid binding loop
				preferredVisible: shellyServiceEnabled.value === 1
			}
		}
		model: shellyServiceEnabled.value === 1 ? sortedShellyDeviceModel : null
		delegate: ListNavigation {
			required property string name
			required property string uid

			text: name
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsShellyDevice.qml", {
					deviceUid: uid,
					title: text,
				})
			}
		}
	}
}
