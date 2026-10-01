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
	VeQItemSortTableModel {
		id: sortedShellyDeviceModel

		filterRole: VeQItemTableModel.ValueRole
		sortColumn: childValues.sortValueColumn
		dynamicSortFilter: true

		model: VeQItemChildModel {
			id: childValues

			// Get a model of the com.victronenergy.shelly/<x>/Model paths. We need to do this
			// instead of just fetching the /Devices children because those child paths are
			// invalidated when a scan is done, so we need to ensure we only show devices with
			// valid /Model values.
			model: VeQItemSortTableModel {
				dynamicSortFilter: true
				filterFlags: VeQItemSortTableModel.FilterInvalid
				filterRole: VeQItemTableModel.UniqueIdRole
				filterRegExp: "\/Devices\/(?:\\w+)\/Model$"
				model: VeQItemTableModel {
				uids: [ root.serviceUid + "/Devices" ]
					// Ideally we could set depth=1 to only add the channel paths, but this is fine
					// for now, and there are not too many paths below the /Devices level anyway.
					flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
			}
			sortDelegate: VeQItemSortDelegate {
				id: deviceSortDelegate

				readonly property string deviceUid: buddy?.itemParent()?.uid ?? ""
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
			text: sortValue
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsShellyDevice.qml", {
					deviceUid: (buddy?.itemParent()?.uid ?? ""),
					title: text,
				})
			}
		}
	}
}
