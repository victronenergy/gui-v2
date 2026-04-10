/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("eebus")

	VeQItemSortTableModel {
		id: channelModel
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "\/Devices\/(?:\\w+)\/Trusted$"
		model: VeQItemTableModel {
			uids: [ root.serviceUid + "/Devices" ]
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

			ListSwitch {
				id: enable
				text: CommonWords.enable
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Eebus"
			}

			ListText {
				//% "Local SKI"
				text: qsTrId("eebus_local_ski")
				dataItem.uid: root.serviceUid + "/LocalSki"
				preferredVisible: dataItem.valid
			}

			ListQrCode {
				//% "QR Code for pairing"
				text: qsTrId("eebus_pairing_qr_code")
				qrData: pairingQRCode.valid ? pairingQRCode.value : ""
				preferredVisible: pairingQRCode.valid

				VeQuickItem {
					id: pairingQRCode
					uid: root.serviceUid + "/PairingQrCode"
				}
			}

			SectionHeader {
				text: CommonWords.discovered_devices
				opacity: eebusListView.count > 0 ? 1 : 0
			}
		}
		model: sortedChannelModel
		delegate: ListNavigation {
			id: listDelegate

			required property VeQItem item
			readonly property string uid: item.itemParent().uid

			text: name.value
			secondaryText: trusted.valid && trusted.value === 1 ? "Trusted" : "Untrusted"

			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsEebusDevice.qml",
												   { bindPrefix: listDelegate.uid, title: text })

			VeQuickItem {
				id: name
				uid: listDelegate.uid + "/Name"
			}

			VeQuickItem {
				id: trusted
				uid: listDelegate.uid + "/Trusted"
			}
		}
	}
}
