/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("shelly")

	// Get a list of all devices on the shelly service, sorted by name.
	VeQItemSortTableModel {
		id: sortedShellyDeviceModel

		filterRole: VeQItemTableModel.ValueRole
		sortColumn: childValues.sortValueColumn
		dynamicSortFilter: true

		model: VeQItemChildModel {
			id: childValues
			model: VeQItemTableModel {
				uids: [ root.serviceUid + "/Devices" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
			sortDelegate: VeQItemSortDelegate {
				id: deviceSortDelegate

				readonly property string deviceUid: buddy?.uid ?? ""
				readonly property string name: nameItem.value || "%1 [%2]".arg(modelItem.value).arg(macItem.value)

				sortValue: buddy.valid ? "" : name
				VeQuickItem {
					id: macItem
					uid: deviceSortDelegate.deviceUid + "/Mac"
				}

				VeQuickItem {
					id: modelItem
					uid: deviceSortDelegate.deviceUid + "/Model"
				}

				VeQuickItem {
					id: nameItem
					uid: deviceSortDelegate.deviceUid + "/Name"
				}
			}
		}
	}

	GradientListView {
		id: shellyListView

		header: SettingsColumn {
			width: parent?.width ?? 0

			ListButton {
				//% "Refresh devices"
				text: qsTrId("settings_shelly_refresh_devices")
				//% "Refresh"
				secondaryText: qsTrId("settings_shelly_refresh")
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: refreshItem.setValue(1)

				VeQuickItem {
					id: refreshItem
					uid: root.serviceUid + "/Refresh"
				}
			}

			ListNavigation {
				//% "Add IP address manually"
				text: qsTrId("page_settings_shelly_add_ip_address_manually")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsShellySetIpAddresses.qml", {"title": text, bindPrefix: root.serviceUid})
			}

			SectionHeader {
				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				text: CommonWords.discovered_devices
				opacity: shellyListView.count > 0 ? 1 : 0 // set opacity instead of visible to avoid binding loop
			}
		}
		model: sortedShellyDeviceModel
		delegate: ListNavigation {
			text: sortValue
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsShellyDevice.qml", {
					deviceUid: buddy?.uid ?? "",
					title: text,
				})
			}
		}
	}
}
