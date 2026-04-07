/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
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

				sortValue: buddy.valid ? "" : (childChannelModel.rowCount === 1 ? name : "%1 - %2".arg(name).arg(channelId))

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

				// Provides a model of the channels for this device.
				// TODO rework this whole page to use a custom C++ model, to avoid having to build
				// sub-models like this within the delegates. See issue #2924.
				VeQItemSortTableModel {
					id: childChannelModel
					dynamicSortFilter: true
					filterRole: VeQItemTableModel.IdRole
					filterRegExp: "[0-9]+"
					model: VeQItemTableModel {
						uids: [ channelSortDelegate.deviceUid ]
						flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
					}
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
				text: CommonWords.discovered_devices
				opacity: shellyListView.count > 0 ? 1 : 0 // set opacity instead of visible to avoid binding loop
			}
		}
		model: sortedChannelModel
		delegate: ListSwitch {
			leftPadding: horizontalContentPadding + typeIcon.width + spacing
			text: sortValue
			dataItem.uid: buddy.uid
			writeAccessLevel: VenusOS.User_AccessType_User

			CP.ColorImage {
				id: typeIcon

				anchors {
					left: parent.left
					leftMargin: parent.horizontalContentPadding
					verticalCenter: parent.verticalCenter
				}
				width: Theme.geometry_icon_size_medium
				height: Theme.geometry_icon_size_medium
				color: Theme.color_font_primary
				opacity: status === Image.Ready ? 1 : 0 // keep space even if no icon is available, to maintain vertical alignments
				source: {
					switch (typeItem.value) {
					case "switch": return "qrc:/images/icon_switchdev_32.svg"
					case "em1": return "qrc:/images/icon_energymeter_1f_32.svg"
					case "em": return "qrc:/images/icon_energymeter_3f_32.svg"
					default: return ""
					}
				}
			}

			VeQuickItem {
				id: typeItem

				readonly property string deviceUid: buddy.itemParent()?.uid ?? ""

				uid: deviceUid ? deviceUid + "/Type" : ""
			}
		}
	}
}
