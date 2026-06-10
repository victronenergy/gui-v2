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

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0

			ListText {
				//% "Device name"
				text: qsTrId("settings_shelly_device_name")
				dataItem.uid: root.deviceUid + "/Name"
			}

			ListText {
				text: CommonWords.serial_number
				dataItem.uid: root.deviceUid + "/Mac"
			}

			SectionHeader {
				//% "Channels"
				text: qsTrId("settings_shelly_channels")
			}
		}

		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.IdRole
			filterRegExp: "[0-9]+"
			model: VeQItemTableModel {
				uids: [ root.deviceUid ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: ListSwitch {
			id: channelDelegate

			required property int index
			required property string uid
			required property string id

			leftPadding: leftInset + spacing + typeIcon.width + spacing
			//: %1 = channel number
			//% "Channel %1"
			text: qsTrId("settings_shelly_channel").arg(id)
			dataItem.uid: uid + "/Enabled"
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
				uid: channelDelegate.uid ? channelDelegate.uid + "/Type" : ""
			}
		}
	}
}
