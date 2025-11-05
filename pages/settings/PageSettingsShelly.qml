/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("shelly")

	// Get a list of channels from all devices on the shelly service. For example, here we have
	// a device "E465B8B6F444" with "Mac" and "Name" values, and three channels (0-2) with
	// "Enabled" states that can be toggled by the delegates in this list view.
	//  com.victronenergy.shelly/Devices/E465B8B6F444/Mac
	//  com.victronenergy.shelly/Devices/E465B8B6F444/Name
	//  com.victronenergy.shelly/Devices/E465B8B6F444/0/Enabled
	//  com.victronenergy.shelly/Devices/E465B8B6F444/1/Enabled
	//  com.victronenergy.shelly/Devices/E465B8B6F444/2/Enabled
	VeQItemSortTableModel {
		id: channelModel
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "\/Devices\/(?:\\w+)\/\\w+/Enabled$"
		model: VeQItemTableModel {
			uids: [ root.serviceUid + "/Devices" ]
			// Ideally we could set depth=1 to only add the channel paths, but this is fine
			// for now, and there are not too many paths below the /Devices level anyway.
			flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	VeQItemSortTableModel {
		id: sortedChannelModel

		filterRole: VeQItemTableModel.ValueRole
		sortColumn: childValues.sortValueColumn
		dynamicSortFilter: true

		model: VeQItemChildModel {
			id: childValues
			model: channelModel
			sortDelegate: VeQItemSortDelegate {
				id: channelSortDelegate

				readonly property string channelUid: buddy.itemParent()?.uid ?? ""
				readonly property string channelId: channelUid.substr(channelUid.lastIndexOf('/') + 1)
				readonly property string deviceUid: buddy.itemParent()?.itemParent()?.uid ?? ""
				readonly property string name: nameItem.value || "%1 [%2]".arg(modelItem.value).arg(macItem.value)

				sortValue: buddy.valid ? "" : (channelTwoItem.valid ? "%1 - %2".arg(name).arg(channelId) : name)

				// If there's a path for channel 2, it means there is more than one channel, so show the channel ID in the list.
				VeQuickItem {
					id: channelTwoItem
					uid: channelSortDelegate.deviceUid + "/2/Enabled"
				}

				VeQuickItem {
					id: macItem
					uid: channelSortDelegate.deviceUid + "/Mac"
				}

				VeQuickItem {
					id: modelItem
					uid: channelSortDelegate.deviceUid + "/Model"
				}

				VeQuickItem {
					id: nameItem
					uid: channelSortDelegate.deviceUid + "/Name"
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
				//% "Press to refresh"
				secondaryText: qsTrId("settings_shelly_press_to_refresh")
				onClicked: refreshItem.setValue(1)

				VeQuickItem {
					id: refreshItem
					uid: root.serviceUid + "/Refresh"
				}
			}

			SectionHeader {
				text: CommonWords.discovered_devices
				opacity: shellyListView.count > 0 ? 1 : 0 // set opacity instead of visible to avoid binding loop
			}
		}
		model: sortedChannelModel
		delegate: ListSwitch {
			text: sortValue
			dataItem.uid: buddy.uid
		}
	}
}
