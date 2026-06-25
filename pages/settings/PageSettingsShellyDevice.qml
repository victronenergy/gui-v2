/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	// The root path for the device, e.g. "com.victronenergy.shelly/ABC123"
	required property string deviceUid

	// Get a list of all channels on the device, sorted by name.
	VeQItemSortTableModel {
		id: sortedChannelModel

		filterRole: VeQItemTableModel.ValueRole
		sortColumn: childValues.sortValueColumn
		dynamicSortFilter: true

		model: VeQItemChildModel {
			id: childValues

			// Get a model of the com.victronenergy.shelly/<model>/<channel>/Enabled paths. When a
			// scan is done, all /Devices child paths are invalidated (but still exist) so we must
			// check for valid /Enabled child paths instead of just searching for all /Devices
			// children, as some of those children may no longer be valid.
			model: VeQItemSortTableModel {
				dynamicSortFilter: true
				filterFlags: VeQItemSortTableModel.FilterInvalid
				filterRole: VeQItemTableModel.UniqueIdRole
				filterRegExp: "[0-9]+/Enabled$"
				model: VeQItemTableModel {
				uids: [ root.deviceUid ]
					flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
			}
			sortDelegate: VeQItemSortDelegate {
				id: channelSortDelegate

				readonly property string channelUid: buddy?.itemParent()?.uid ?? ""
				readonly property string name: channelNameItem.value
						//: %1 = channel number
						//% "Channel %1"
						|| qsTrId("settings_shelly_channel").arg(buddy?.itemParent().id ?? "")

				sortValue: buddy.valid ? "" : name

				VeQuickItem {
					id: channelNameItem
					uid: channelSortDelegate.channelUid + "/Name"
				}
			}
		}
	}

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0

			ListText {
				//% "Device name"
				text: qsTrId("settings_shelly_device_name")
				secondaryText: deviceNameItem.value || modelItem.value || ""

				VeQuickItem {
					id: deviceNameItem
					uid: root.deviceUid + "/Name"
				}
				VeQuickItem {
					id: modelItem
					uid: root.deviceUid + "/Model"
				}
			}

			ListText {
				text: CommonWords.serial_number
				dataItem.uid: root.deviceUid + "/Mac"
			}

			ListNavigation {
				id: ipListItem

				text: CommonWords.ip_address
				secondaryText: ipAddressItem.value ?? ""
				preferredVisible: ipAddressItem.valid
				iconSource: "qrc:/images/icon_open_link_32.svg"
				// Link is clickable on local Wasm only, not on VRM.
				interactive: text.length && Qt.platform.os === "wasm" && !BackendConnection.vrm

				onClicked: {
					BackendConnection.openUrl("http://" + ipAddressItem.value)
				}

				VeQuickItem {
					id: ipAddressItem
					uid: root.deviceUid + "/Ip"
				}
			}

			SectionHeader {
				//% "Channels"
				text: qsTrId("settings_shelly_channels")
			}
		}

		model: sortedChannelModel

		delegate: ListSwitch {
			id: channelDelegate

			readonly property string channelUid: buddy?.itemParent()?.uid ?? ""

			leftPadding: leftInset + spacing + typeIcon.width + spacing
			text: sortValue
			dataItem.uid: channelUid + "/Enabled"
			writeAccessLevel: VenusOS.User_AccessType_User

			CP.ColorImage {
				id: typeIcon

				anchors {
					left: parent.left
					leftMargin: parent.leftInset + spacing
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
				uid: channelDelegate.channelUid ? channelDelegate.channelUid + "/Type" : ""
			}
		}
	}
}
