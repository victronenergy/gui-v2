/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Resolves which registered consumers currently have an allocation
	against one Storage Manager volume, straight from /Allocations -
	shared by EjectDialog and FormatConfirmDialog.
*/
Item {
	id: root

	required property string volumePrefix
	readonly property string storageServiceUid: BackendConnection.serviceUidForType("storage")
	property var consumerNames: []

	visible: false

	VeQuickItem { id: volumeIdItem; uid: root.volumePrefix + "/Id" }

	VeQItemSortTableModel {
		id: allocations
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Allocations"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	function consumerDisplayName(consumer) {
		if (consumer === "vrmlogger") {
			//% "VRM online logging"
			return qsTrId("storagevolumeconsumers_vrm")
		}
		return consumer
	}

	function recomputeConsumerNames() {
		let names = []
		for (let i = 0; i < allocationRepeater.count; ++i) {
			const row = allocationRepeater.itemAt(i)
			if (row && row.matchesThisVolume && row.name) {
				names.push(row.name)
			}
		}
		root.consumerNames = names
	}

	Repeater {
		id: allocationRepeater
		model: VeQItemChildModel {
			model: allocations
			childId: "VolumeId"
		}
		delegate: Item {
			readonly property string allocationPrefix: model.item.itemParent().uid
			readonly property bool matchesThisVolume: model.item.value === volumeIdItem.value
			readonly property string name: root.consumerDisplayName(consumerItem.value || "")

			onMatchesThisVolumeChanged: root.recomputeConsumerNames()
			onNameChanged: root.recomputeConsumerNames()
			Component.onCompleted: root.recomputeConsumerNames()

			VeQuickItem { id: consumerItem; uid: allocationPrefix + "/Consumer" }
		}
		onCountChanged: root.recomputeConsumerNames()
	}
}
