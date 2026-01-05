/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("eebus")

	// Get a list of channels from all devices on the shelly service. For example, here we have
	// a device "Demo_000000001" with "Name", "Ski" and "Trusted" values
	//  com.victronenergy.eebus/Devices/Demo_000000001/AutoAccept
	//  com.victronenergy.eebus/Devices/Demo_000000001/Brand
	//	com.victronenergy.eebus/Devices/Demo_000000001/Host
	//	com.victronenergy.eebus/Devices/Demo_000000001/Model
	//	com.victronenergy.eebus/Devices/Demo_000000001/Name
	//	com.victronenergy.eebus/Devices/Demo_000000001/Ski
	//	com.victronenergy.eebus/Devices/Demo_000000001/Trusted
	//	com.victronenergy.eebus/Devices/Demo_000000001/Type
	VeQItemSortTableModel {
		id: channelModel
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "\/Devices\/(?:\\w+)\/Trusted$"
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

				readonly property string deviceUid: buddy.itemParent()?.uid ?? ""
				readonly property string name: nameItem.value

				sortValue: buddy.valid ? "" : name

				VeQuickItem {
					id: nameItem
					uid: channelSortDelegate.deviceUid + "/Name"
				}

				VeQuickItem {
					id: trustedItem
					uid: channelSortDelegate.deviceUid + "/Trusted"
				}
			}
		}
	}

	GradientListView {
		id: eebusListView

		header: SettingsColumn {
			width: parent?.width ?? 0

			ListText {
				text: "Local SKI"
				secondaryText: dataItem.value
				dataItem.uid: root.serviceUid + "/LocalSki"
				preferredVisible: dataItem.valid
			}

			ListQrCode {
				text: "QR Code for pairing"
				qrData: pairingQRCode.value
				preferredVisible: pairingQRCode.valid

				VeQuickItem {
					id: pairingQRCode
					uid: root.serviceUid + "/PairingQrCode"
				}
			}

			SectionHeader {
				text: CommonWords.discovered_devices
			}
		}
		model: sortedChannelModel
		delegate: ListSwitch {
			text: sortValue
			dataItem.uid: buddy.uid
			secondaryText: ski.valid ? "SKI: " + ski.value : ""
			writeAccessLevel: VenusOS.User_AccessType_User

			VeQuickItem {
				id: ski
				uid: buddy.itemParent()?.uid + "/Ski"
			}
		}
	}
}
