/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	required property string volumePrefix
	readonly property string storageServiceUid: BackendConnection.serviceUidForType("storage")
	property bool pendingReformatAfterClose: false
	property bool pendingReformatConfirmAfterClose: false
	property bool pendingReturnAfterFormat: false
	property bool pendingReturnAfterEject: false
	property string pendingReformatFilesystem: ""
	//% "VRM online logging"
	readonly property string vrmConsumerName: qsTrId("pagesettingsstorage_consumer_vrm")
	readonly property var stateNames: [
		//% "Absent"
		qsTrId("pagesettingsstorage_state_absent"),
		//% "Available"
		qsTrId("pagesettingsstorage_state_available"),
		//% "Active"
		qsTrId("pagesettingsstorage_state_active"),
		//% "Preparing to eject"
		qsTrId("pagesettingsstorage_state_quiescing"),
		//% "Lost"
		qsTrId("pagesettingsstorage_state_lost"),
		//% "Error"
		qsTrId("pagesettingsstorage_state_error"),
		//% "Recovering"
		qsTrId("pagesettingsstorage_state_recovering")
	]
	// Live, not a static title passed in at push time - so it updates
	// immediately as Nickname is edited on this same page, and works
	// regardless of what the caller happened to know when navigating in.
	//% "Unnamed storage"
	title: nicknameItem.value || labelItem.value || qsTrId("pagesettingsstorage_unnamed")
	VeQuickItem { id: labelItem; uid: root.volumePrefix + "/Label" }
	VeQuickItem { id: nicknameItem; uid: root.volumePrefix + "/Nickname" }

	VeQuickItem { id: volumeIdItem; uid: root.volumePrefix + "/Id" }
	VeQuickItem { id: uuidItem; uid: root.volumePrefix + "/Uuid" }
	VeQuickItem { id: filesystem; uid: root.volumePrefix + "/Filesystem" }
	VeQuickItem { id: state; uid: root.volumePrefix + "/State" }
	VeQuickItem { id: lifecycle; uid: root.volumePrefix + "/Lifecycle" }
	VeQuickItem { id: capacity; uid: root.volumePrefix + "/Capacity" }
	// Not Capacity - Free: that counts ext4's root-only blocks as "used".
	// Used matches `df`'s own
	// accounting instead - see inventory.py's _volume_used_bytes. The
	// real Free leaf isn't read on this page at all - see the capacity
	// gauge's caption below for why.
	VeQuickItem { id: used; uid: root.volumePrefix + "/Used" }
	VeQuickItem { id: mountPoint; uid: root.volumePrefix + "/MountPoint" }
	// Set only once this page's own Eject dialog has actually been
	// confirmed - guards against popping the page on page load if this
	// volume simply already happens to be ejected.
	property bool pendingEject: false
	VeQuickItem {
		id: safeToRemove
		uid: root.volumePrefix + "/SafeToRemove"
		onValueChanged: {
			if (value === 1 && root.pendingEject) {
				root.pendingEject = false
				// The accepted Eject dialog can still own dialogLayer here. A
				// synchronous pop is then lost while that dialog tears down, so
				// return to the list only after it has completely closed.
				root.pendingReturnAfterEject = true
				if (!Global.dialogLayer.currentDialog) {
					root.pendingReturnAfterEject = false
					Global.pageManager.popPage()
				}
			}
		}
	}
	VeQuickItem { id: ejectAction; uid: root.volumePrefix + "/Admin/Eject" }
	// Only read for .valid here (gates the Reformat button) - the actual
	// write happens inside the shared FormatConfirmDialog now.
	VeQuickItem { id: formatAndAdoptAction; uid: root.volumePrefix + "/Admin/FormatAndAdopt" }

	// Waits for a dialog to actually finish closing (not just accept()
	// being called, which may still be animating) before opening the
	// next one - chaining dialogLayer.open() calls synchronously risks
	// the first dialog's own closed-signal handler destroying the second
	// dialog instead of the first.
	Connections {
		target: Global.dialogLayer
		function onCurrentDialogChanged() {
			if (Global.dialogLayer.currentDialog) {
				return
			}
			if (root.pendingReturnAfterEject) {
				root.pendingReturnAfterEject = false
				Global.pageManager.popPage()
			} else if (root.pendingReformatAfterClose) {
				root.pendingReformatAfterClose = false
				Global.dialogLayer.open(reformatChooseFilesystemDialogComponent, {
					"volumePrefix": root.volumePrefix,
					"mountPoint": mountPoint.value || "",
					"nickname": nicknameItem.value || "",
				})
			} else if (root.pendingReformatConfirmAfterClose) {
				root.pendingReformatConfirmAfterClose = false
				Global.dialogLayer.open(reformatConfirmDialogComponent, {
					"volumePrefix": root.volumePrefix,
					"mountPoint": mountPoint.value || "",
					"filesystem": root.pendingReformatFilesystem,
					"nickname": nicknameItem.value || "",
				})
			} else if (root.pendingReturnAfterFormat) {
				root.pendingReturnAfterFormat = false
				Global.pageManager.popPage()
			}
		}
	}

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

	function stateText(value) {
		return value >= 0 && value < root.stateNames.length ? root.stateNames[value] : "--"
	}

	function consumerName(consumer) {
		if (consumer === "vrmlogger") {
			return root.vrmConsumerName
		}
		return consumer
	}

	function formatBytes(bytes) {
		return Utils.qtyToString(Number(bytes) || 0,
				//% "byte"
				qsTrId("settings_vrm_byte"),
				//% "bytes"
				qsTrId("settings_vrm_bytes"))
	}

	property int consumerCount: 0
	property bool hasActiveConsumer: false

	function recomputeConsumerCounts() {
		let count = 0
		let active = false
		for (let i = 0; i < usedByRepeater.count; ++i) {
			const row = usedByRepeater.itemAt(i)
			if (!row || !row.isThisVolume) {
				continue
			}
			count += 1
			if (row.isActive) {
				active = true
			}
		}
		root.consumerCount = count
		root.hasActiveConsumer = active
	}

	GradientListView {
		model: VisibleItemModel {
			ListTextField {
				//% "Name"
				text: qsTrId("pagesettingsstorage_nickname")
				dataItem.uid: root.volumePrefix + "/Nickname"
				dataItem.invalidate: false
				maximumLength: 32
				preferredVisible: lifecycle.value === VenusOS.Storage_Lifecycle_AdoptedPersistent
							  && dataItem.valid
				//% "Unnamed volume"
				placeholderText: qsTrId("pagesettingsstorage_nickname_placeholder")
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListResourceGauge {
				//% "Used"
				text: qsTrId("pagesettingsstorage_used")
				value: used.value
				to: capacity.value
				//% "%1 / %2"
				valueText: qsTrId("pagesettingsstorage_usage_value")
						.arg(root.formatBytes(value))
						.arg(root.formatBytes(to))
				//% "%1 total, %2 free"
				// Free here is deliberately Capacity - Used, not the real
				// Free leaf (which excludes ext4's root-only blocks and can
				// therefore make Total and Used look like they don't add up).
				caption: qsTrId("pagesettingsstorage_capacity_detail")
						.arg(root.formatBytes(capacity.value))
						.arg(root.formatBytes(Math.max(0, capacity.value - used.value)))
			}

			ListText {
				//% "Mount point"
				text: qsTrId("pagesettingsstorage_mount_point")
				secondaryText: mountPoint.value || "--"
			}

			ListButton {
				//% "Safely eject storage"
				text: qsTrId("pagesettingsstorage_eject")
				//% "Eject"
				secondaryText: qsTrId("pagesettingsstorage_eject_button")
				// The backend only publishes /Admin/Eject for media whose
				// parent device is removable. Fixed PCIe/NVMe and eMMC can still
				// be unmounted internally by reformat, but never expose Eject.
				preferredVisible: ejectAction.valid && !safeToRemove.value
				writeAccessLevel: VenusOS.User_AccessType_Installer
				onClicked: Global.dialogLayer.open(ejectDialogComponent, {
					"volumePrefix": root.volumePrefix,
					"volumeName": root.title,
				})
			}

			SettingsListHeader {
				//% "Used by"
				text: qsTrId("pagesettingsstorage_used_by_header")
			}

			SettingsColumn {
				width: parent ? parent.width : 0

				ListText {
					//% "No services are currently using this storage"
					text: qsTrId("pagesettingsstorage_used_by_none")
					visible: root.consumerCount === 0
				}

				Repeater {
					id: usedByRepeater
					model: VeQItemChildModel {
						model: allocations
						childId: "VolumeId"
					}
					delegate: ListText {
						id: allocationDelegate
						readonly property string allocationPrefix: model.item.itemParent().uid
						readonly property bool isThisVolume: model.item.value === volumeIdItem.value
						readonly property bool isActive: isThisVolume
									&& (state.value === VenusOS.Storage_Allocation_Ready
										|| state.value === VenusOS.Storage_Allocation_Quiescing)
						// preferredVisible alone does not hide a ListText
						// outside a VisibleItemModel-driven list (same bug
						// already fixed in other model-backed settings pages) -
						// every allocation for every volume was showing here,
						// not just this one's own.
						visible: isThisVolume
						text: root.consumerName(consumer.value || "")

						onIsThisVolumeChanged: root.recomputeConsumerCounts()
						onIsActiveChanged: root.recomputeConsumerCounts()
						onTextChanged: root.recomputeConsumerCounts()
						Component.onCompleted: root.recomputeConsumerCounts()

						VeQuickItem { id: consumer; uid: allocationDelegate.allocationPrefix + "/Consumer" }
						VeQuickItem { id: state; uid: allocationDelegate.allocationPrefix + "/State" }
					}
					onCountChanged: root.recomputeConsumerCounts()
				}
			}

			SettingsListHeader {
				//% "Actions"
				text: qsTrId("pagesettingsstorage_actions")
			}

			ListButton {
				// reformat_volume() itself now allows an already-adopted
				// volume through as long as nothing is actively using it
				// (see prepare.py) - it does its own unmount, no prior
				// Eject required. Only a real, active consumer still blocks
				// it here, matching the backend's own gate.
				readonly property bool inActiveUse: root.hasActiveConsumer
				//% "Reformat storage"
				text: qsTrId("pagesettingsstorage_reformat")
				//% "Reformat"
				secondaryText: qsTrId("pagesettingsstorage_reformat_button")
				readOnly: !formatAndAdoptAction.valid || inActiveUse
				caption: {
					if (!formatAndAdoptAction.valid) {
						//% "Not supported by the installed Storage Manager"
						return qsTrId("pagesettingsstorage_reformat_unavailable")
					}
					if (inActiveUse) {
						//% "Safely eject this storage before reformatting it"
						return qsTrId("pagesettingsstorage_reformat_in_use")
					}
					//% "Erases all data and creates a new filesystem"
					return qsTrId("pagesettingsstorage_reformat_caption")
				}
				writeAccessLevel: VenusOS.User_AccessType_Installer
				onClicked: Global.dialogLayer.open(reformatChooseFilesystemDialogComponent, {
					"volumePrefix": root.volumePrefix,
					"mountPoint": mountPoint.value || "",
					"nickname": nicknameItem.value || "",
				})
			}

			SettingsListHeader {
				//% "Status"
				text: qsTrId("pagesettingsstorage_status")
			}

			ListText {
				//% "State"
				text: qsTrId("pagesettingsstorage_state")
				secondaryText: root.stateText(state.value)
			}

			ListText {
				//% "Filesystem"
				text: qsTrId("pagesettingsstorage_filesystem")
				secondaryText: filesystem.value || "--"
			}

			ListText {
				text: "UUID"
				secondaryText: uuidItem.value || "--"
			}

		}
	}

	Component {
		id: ejectDialogComponent

		EjectDialog {
			onEjectStarted: root.pendingEject = true
		}
	}

	Component {
		id: reformatChooseFilesystemDialogComponent

		FormatChooseDialog {
			onFilesystemChosen: function (filesystem) {
				root.pendingReformatFilesystem = filesystem
				root.pendingReformatConfirmAfterClose = true
			}
		}
	}

	Component {
		id: reformatConfirmDialogComponent

		FormatConfirmDialog {
			// Wait until the modal has closed before navigating. Popping while
			// it still owns dialogLayer leaves the obsolete UUID detail page up.
			onFormatFinished: root.pendingReturnAfterFormat = true
		}
	}
}
