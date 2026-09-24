/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Storage Manager volume picker for the VRM online logging buffer (vrm-cache role).

	Lists adopted (Lifecycle == AdoptedPersistent), currently available/active volumes published
	by com.victronenergy.storage, and
	shows shared use with a coloured indicator rather than enumerating consumers in text.
	Selecting a volume writes its stable Id to
	/Settings/Vrmlogger/StorageVolumeId - a Settings leaf, not a raw device/mount path,
	and not a direct call to Storage Manager's /Management D-Bus methods: GUIv2's
	VeQItem layer can only get/set BusItem leaves (plus the one hand-built AddSetting bridge for
	the settings service - see ve_qitems_dbus.cpp). Storage Manager's own
	vrmlogger consumer watches this setting and requests the corresponding allocation.

	Eject/release scope decision for this phase: choosing "Not set" below clears the setting (the
	GUI-observable equivalent of ReleaseAllocationSet for the vrm-cache role). It does not perform
	a bounded quiesce/unmount transaction. PageSettingsFirmwareOffline.qml's
	ListMountStateButton (shared Storage_MountState-based Eject) is intentionally left untouched;
	only this page's storage-selection surface moves to Storage Manager for this phase.
*/
Page {
	id: root

	readonly property string storageServiceUid: BackendConnection.serviceUidForType("storage")
	readonly property string currentVolumeId: storageVolumeIdSetting.value || ""

	VeQuickItem {
		id: storageVolumeIdSetting

		uid: Global.systemSettings.serviceUid + "/Settings/Vrmlogger/StorageVolumeId"
	}

	property VeQItemSortTableModel volumes: VeQItemSortTableModel {
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Volumes"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	// Used to look up whether any other Ready consumer references a volume.
	property VeQItemSortTableModel allocations: VeQItemSortTableModel {
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Allocations"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	property var sharedVolumeIds: []

	function _recomputeSharedVolumeIds() {
		let ids = []
		for (let i = 0; i < allocationRepeater.count; ++i) {
			const row = allocationRepeater.itemAt(i)
			if (row && row.isReadyForOtherConsumer && row.allocationVolumeId) {
				ids.push(row.allocationVolumeId)
			}
		}
		root.sharedVolumeIds = ids
	}

	function volumeIsShared(volumeId) {
		return root.sharedVolumeIds.indexOf(volumeId) >= 0
	}

	// Invisible: joins each /Allocations/<N> object against its Consumer/State/VolumeId siblings,
	// the same itemParent()-based sibling lookup PageSettingsModbusDiscovered.qml uses, just via
	// Repeater instead of a visible ListView since nothing here is rendered directly.
	Repeater {
		id: allocationRepeater

		model: VeQItemChildModel {
			model: root.allocations
			childId: "VolumeId"
		}

		delegate: Item {
			id: allocationRow

			readonly property string allocationUid: model.item.itemParent().uid
			readonly property string allocationVolumeId: model.item.value
			readonly property bool isReadyForOtherConsumer:
				consumerItem.value && consumerItem.value !== "vrmlogger"
				&& stateItem.value === VenusOS.Storage_Allocation_Ready

			onAllocationVolumeIdChanged: root._recomputeSharedVolumeIds()
			onIsReadyForOtherConsumerChanged: root._recomputeSharedVolumeIds()
			Component.onCompleted: root._recomputeSharedVolumeIds()

			VeQuickItem {
				id: consumerItem
				uid: allocationRow.allocationUid + "/Consumer"
				onValueChanged: root._recomputeSharedVolumeIds()
			}
			VeQuickItem {
				id: stateItem
				uid: allocationRow.allocationUid + "/State"
				onValueChanged: root._recomputeSharedVolumeIds()
			}
		}

		onCountChanged: root._recomputeSharedVolumeIds()
	}

	GradientListView {
		id: listView

		header: SettingsColumn {
			width: parent.width

			ListRadioButton {
				//% "System (/data)"
				text: qsTrId("settings_logger_storage_none")
				//% "%1 free"
				secondaryText: qsTrId("settings_logger_storage_free").arg(dataPartitionFreeSpaceText)
				checked: !root.currentVolumeId
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: {
					storageVolumeIdSetting.setValue("")
					Global.pageManager.popPage(root)
				}

				readonly property string dataPartitionFreeSpaceText: Utils.qtyToString(dataPartitionFreeSpace.value,
						//% "byte"
						qsTrId("settings_vrm_byte"),
						//% "bytes"
						qsTrId("settings_vrm_bytes"))

				VeQuickItem {
					id: dataPartitionFreeSpace
					uid: Global.venusPlatform.serviceUid + "/ModificationChecks/DataPartitionFreeSpace"
				}
			}

			PrimaryListLabel {
				horizontalAlignment: Text.AlignHCenter
				preferredVisible: listView.count === 0
				//% "No eligible storage volumes found"
				text: qsTrId("settings_logger_storage_no_volumes")
			}
		}

		model: VeQItemSortTableModel {
			model: VeQItemChildModel {
				model: root.volumes
				childId: "Id"
			}
			dynamicSortFilter: true
			filterFlags: VeQItemSortTableModel.FilterInvalid
		}

		delegate: ListRadioButton {
			id: volumeDelegate

			readonly property string volumeUid: model.item.itemParent().uid
			readonly property string volumeId: model.item.value

			preferredVisible: lifecycle.value === VenusOS.Storage_Lifecycle_AdoptedPersistent
							   && (state.value === VenusOS.Storage_VolumeState_Available
								   || state.value === VenusOS.Storage_VolumeState_Active)

			//% "Unnamed volume"
			text: nickname.value || label.value || qsTrId("settings_logger_storage_unnamed_volume")
			// Green means this choice is exclusive to VRM; amber means another
			// registered service is already using it. This remains useful as
			// more consumers are added without growing a sentence per service.
			indicatorColor: root.volumeIsShared(volumeId) ? Theme.color_orange : Theme.color_green
			//% "%1 free"
			secondaryText: qsTrId("settings_logger_storage_free").arg(freeSpaceText)
			checked: volumeId === root.currentVolumeId
			writeAccessLevel: VenusOS.User_AccessType_User

			readonly property string freeSpaceText: Utils.qtyToString(free.value,
					//% "byte"
					qsTrId("settings_vrm_byte"),
					//% "bytes"
					qsTrId("settings_vrm_bytes"))

			onClicked: {
				storageVolumeIdSetting.setValue(volumeId)
				Global.pageManager.popPage(root)
			}

			VeQuickItem {
				id: label
				uid: volumeDelegate.volumeUid + "/Label"
			}
			VeQuickItem {
				id: nickname
				uid: volumeDelegate.volumeUid + "/Nickname"
			}
			VeQuickItem {
				id: free
				uid: volumeDelegate.volumeUid + "/Free"
			}
			VeQuickItem {
				id: lifecycle
				uid: volumeDelegate.volumeUid + "/Lifecycle"
			}
			VeQuickItem {
				id: state
				uid: volumeDelegate.volumeUid + "/State"
			}
		}
	}
}
