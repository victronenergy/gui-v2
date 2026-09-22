/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/* Settings > General > Storage: system-wide Storage Manager overview. */
Page {
	id: root

	readonly property string storageServiceUid: BackendConnection.serviceUidForType("storage")
	readonly property bool storageManagerRunning: storageConnected.valid && storageConnected.value === 1
	property var consumersByVolume: ({})
	//% "VRM online logging"
	readonly property string vrmConsumerName: qsTrId("pagesettingsstorage_consumer_vrm")
	//% "Unnamed storage"
	readonly property string unnamedText: qsTrId("pagesettingsstorage_unnamed")
	VeQuickItem {
		id: storageConnected
		uid: root.storageServiceUid + "/Connected"
	}

	// Every currently-published volume, resolved once here (name/state/
	// lifecycle/claim/capacity/mount point/device id) rather than
	// re-derived independently by each row - lets the list be split into
	// real sections without the underlying model itself needing to
	// reorder, and without a second, separate model/pass per section -
	// same "shadow Repeater over the full model, computed once"
	// convention this app already uses in other model-backed settings pages.
	property var volumeRecords: []
	readonly property var adoptedVolumes: root.volumeRecords.filter(function (v) {
		return v.lifecycle === VenusOS.Storage_Lifecycle_AdoptedPersistent
				&& v.state !== VenusOS.Storage_VolumeState_Lost
				&& v.state !== VenusOS.Storage_VolumeState_Absent
	})
	readonly property var newVolumes: root.volumeRecords.filter(function (v) {
		return v.lifecycle === VenusOS.Storage_Lifecycle_Transient && !v.claimedBy
	})
	readonly property var claimedVolumes: root.volumeRecords.filter(function (v) {
		return v.lifecycle === VenusOS.Storage_Lifecycle_Transient && !!v.claimedBy
	})
	readonly property var foreignVolumes: root.volumeRecords.filter(function (v) {
		return v.lifecycle === VenusOS.Storage_Lifecycle_ForeignManaged
	})
	// Absent joins Lost here, not the main adopted list above - a fixed,
	// non-removable device that's just been safely ejected is exactly as
	// "known but not currently available" as one that's gone missing, even
	// though it never left (no udev event will ever bring it back on its
	// own the way reinserting a removable device does).
	readonly property var lostVolumes: root.volumeRecords.filter(function (v) {
		return v.lifecycle === VenusOS.Storage_Lifecycle_AdoptedPersistent
				&& (v.state === VenusOS.Storage_VolumeState_Lost || v.state === VenusOS.Storage_VolumeState_Absent)
	})

	//% "Eject"
	readonly property string ejectButtonText: qsTrId("pagesettingsstorage_eject_button")

	function filesystemDisplayName(filesystem) {
		if (filesystem === "vfat") {
			return qsTrId("formatchoosedialog_column_fat")
		}
		if (filesystem === "ext4") {
			return qsTrId("formatchoosedialog_column_ext4")
		}
		return filesystem ? filesystem.toUpperCase() : "--"
	}

	// View models for the flat (no sub-page) rows below - New/Claimed/
	// Foreign each need their own caption text and action set, computed
	// once here rather than inside the shared row component, which just
	// renders whatever it's given.
	// New media has two management paths under Adopt: label and use it as
	// is, or format first and then label/use it. Either way,
	// the GUI only ever fires one trigger and displays whatever comes
	// back - the backend resolves the freshly-formatted volume's own new
	// identity itself and does the labeling/adopting server-side in the
	// same call (see dbus_service.py's format_and_adopt_volume()), not a
	// GUI-side pending-state/re-identification dance like the old
	// "Format first, then wait for the result to reappear" flow, which
	// proved unreliable live.
	readonly property var newVolumeRows: root.newVolumes.map(function (record) {
		return {
			"text": record.name,
			"caption": root.newCaption(record),
			"indicatorColor": Global.storage.volumeIndicatorColor(record.lifecycle, record.claimedBy),
			"reformatting": record.prefix === root.reformattingVolumePrefix,
			"primaryActionText": root.ejectButtonText,
			"primaryActionClicked": function () { root.startEject(record) },
			//% "Adopt"
			"secondaryActionText": qsTrId("pagesettingsstorage_adopt_button"),
			"secondaryActionClicked": function () { root.startAdopt(record) },
		}
	})

	readonly property var claimedVolumeRows: root.claimedVolumes.map(function (record) {
		return {
			"text": record.name,
			"caption": root.claimedCaption(record),
			"indicatorColor": Global.storage.volumeIndicatorColor(record.lifecycle, record.claimedBy),
			"reformatting": record.prefix === root.reformattingVolumePrefix,
			"primaryActionText": root.ejectButtonText,
			"primaryActionClicked": function () { root.startEject(record) },
			// Legacy-claimed media is owned by that handler. Storage Manager
			// must not offer a competing destructive/adoption action.
		}
	})

	readonly property var foreignVolumeRows: root.foreignVolumes.map(function (record) {
		return {
			"text": record.name,
			"caption": root.foreignCaption(record),
			"indicatorColor": Global.storage.volumeIndicatorColor(record.lifecycle, record.claimedBy),
			"reformatting": false,
			"primaryActionText": root.ejectButtonText,
			"primaryActionClicked": function () { root.startEject(record) },
		}
	})

	VeQItemSortTableModel {
		id: volumes
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Volumes"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
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

	function consumerName(consumer) {
		if (consumer === "vrmlogger") {
			return root.vrmConsumerName
		}
		return consumer
	}

	function recomputeConsumers() {
		let result = {}
		for (let i = 0; i < allocationRepeater.count; ++i) {
			const row = allocationRepeater.itemAt(i)
			if (!row || !row.volumeId || !row.consumer) {
				continue
			}
			let consumers = result[row.volumeId] || []
			if (consumers.indexOf(row.consumer) < 0) {
				consumers.push(row.consumer)
			}
			result[row.volumeId] = consumers
		}
		root.consumersByVolume = result
	}

	function interestCountText(volumeId) {
		const count = (root.consumersByVolume[volumeId] || []).length
		if (count === 0) {
			//% "No services interested"
			return qsTrId("pagesettingsstorage_interest_none")
		}
		//% "%1 service(s) interested"
		return qsTrId("pagesettingsstorage_interest_count").arg(count)
	}

	function claimedByText(claimedBy) {
		switch (claimedBy) {
		case "venus-data":
			//% "a Venus customization archive"
			return qsTrId("pagesettingsstorage_claimed_venus_data")
		case "swupdate-offline":
			//% "a firmware update"
			return qsTrId("pagesettingsstorage_claimed_swupdate")
		default:
			return claimedBy
		}
	}

	function adoptedCaption(record) {
		return root.interestCountText(record.id) + " · " + (record.mountPoint || "--")
	}

	function adoptedUsageText(record) {
		//% "%1 used / %2 free"
		return qsTrId("pagesettingsstorage_adopted_usage").arg(root.formatBytes(record.used))
				.arg(root.formatBytes(Math.max(0, record.capacity - record.used)))
	}

	function formatBytes(bytes) {
		return Utils.qtyToString(Number(bytes) || 0,
				//% "byte"
				qsTrId("settings_vrm_byte"),
				//% "bytes"
				qsTrId("settings_vrm_bytes"))
	}

	function newCaption(record) {
		//% "New — not yet managed by this device · %1"
		return qsTrId("pagesettingsstorage_new_caption").arg(record.mountPoint || "--")
	}

	function claimedCaption(record) {
		//% "In use by %1 — not available to adopt · %2"
		return qsTrId("pagesettingsstorage_claimed_caption")
				.arg(root.claimedByText(record.claimedBy)).arg(record.mountPoint || "--")
	}

	function foreignCaption(record) {
		//% "Managed by a different GX device · %1"
		return qsTrId("pagesettingsstorage_foreign_caption").arg(record.mountPoint || "--")
	}

	function recomputeVolumes() {
		let result = []
		for (let i = 0; i < volumeInfoRepeater.count; ++i) {
			const row = volumeInfoRepeater.itemAt(i)
			if (!row || !row.volumeId) {
				continue
			}
			result.push({
				"id": row.volumeId,
				"prefix": row.prefix,
				"name": row.name,
				"lifecycle": row.lifecycleValue,
				"state": row.stateValue,
				"claimedBy": row.claimedBy,
				"capacity": row.capacityValue,
				"used": row.usedValue,
				"mountPoint": row.mountPointValue,
				"deviceId": row.deviceIdValue,
				"filesystem": row.filesystemValue,
				"adoptRequiresFormat": row.adoptRequiresFormat,
			})
		}
		root.volumeRecords = result
	}

	Repeater {
		id: allocationRepeater
		model: VeQItemChildModel {
			model: allocations
			childId: "VolumeId"
		}
		delegate: Item {
			id: allocationRow
			readonly property string prefix: model.item.itemParent().uid
			readonly property string volumeId: model.item.value || ""
			readonly property string consumer: consumerItem.value || ""

			onVolumeIdChanged: root.recomputeConsumers()
			onConsumerChanged: root.recomputeConsumers()
			Component.onCompleted: root.recomputeConsumers()

			VeQuickItem { id: consumerItem; uid: allocationRow.prefix + "/Consumer" }
		}
		onCountChanged: root.recomputeConsumers()
	}

	Repeater {
		id: volumeInfoRepeater
		model: VeQItemChildModel {
			model: volumes
			childId: "Id"
		}
		delegate: Item {
			id: volumeInfoRow
			readonly property string prefix: model.item.itemParent().uid
			readonly property string volumeId: model.item.value || ""
			// A D-Bus child briefly becomes undefined while its model row is
			// being removed. Keep the typed bindings valid during that teardown.
			readonly property int lifecycleValue: lifecycleItem.value || 0
			readonly property int stateValue: stateItem.value || 0
			readonly property string claimedBy: claimedByItem.value || ""
			readonly property real capacityValue: capacityItem.value || 0
			readonly property real usedValue: usedItem.value || 0
			readonly property string mountPointValue: mountPointItem.value || ""
			readonly property string deviceIdValue: deviceIdItem.value || ""
			readonly property string filesystemValue: filesystemItem.value || ""
			readonly property bool adoptRequiresFormat: adoptRequiresFormatItem.value === 1
			// Nicknames only ever exist on an adopted volume (the backend
			// rejects setting one otherwise) - an unmanaged volume's own
			// identifying text is its filesystem label if it has one,
			// otherwise its mount point (there's nothing else meaningful
			// to show), never "Unnamed storage" while it's still sitting
			// there mounted and visible.
			readonly property string name: lifecycleValue === VenusOS.Storage_Lifecycle_AdoptedPersistent
					? (nicknameItem.value || labelItem.value || root.unnamedText)
					: (labelItem.value || mountPointValue || root.unnamedText)

			onVolumeIdChanged: root.recomputeVolumes()
			onNameChanged: root.recomputeVolumes()
			onLifecycleValueChanged: root.recomputeVolumes()
			onStateValueChanged: root.recomputeVolumes()
			onClaimedByChanged: root.recomputeVolumes()
			onCapacityValueChanged: root.recomputeVolumes()
			onUsedValueChanged: root.recomputeVolumes()
			onMountPointValueChanged: root.recomputeVolumes()
			onDeviceIdValueChanged: root.recomputeVolumes()
			onFilesystemValueChanged: root.recomputeVolumes()
			onAdoptRequiresFormatChanged: root.recomputeVolumes()
			Component.onCompleted: root.recomputeVolumes()

			VeQuickItem { id: labelItem; uid: volumeInfoRow.prefix + "/Label" }
			VeQuickItem { id: nicknameItem; uid: volumeInfoRow.prefix + "/Nickname" }
			VeQuickItem { id: stateItem; uid: volumeInfoRow.prefix + "/State" }
			VeQuickItem { id: lifecycleItem; uid: volumeInfoRow.prefix + "/Lifecycle" }
			VeQuickItem { id: claimedByItem; uid: volumeInfoRow.prefix + "/ClaimedBy" }
			VeQuickItem { id: capacityItem; uid: volumeInfoRow.prefix + "/Capacity" }
			VeQuickItem { id: usedItem; uid: volumeInfoRow.prefix + "/Used" }
			VeQuickItem { id: mountPointItem; uid: volumeInfoRow.prefix + "/MountPoint" }
			VeQuickItem { id: deviceIdItem; uid: volumeInfoRow.prefix + "/DeviceId" }
			VeQuickItem { id: filesystemItem; uid: volumeInfoRow.prefix + "/Filesystem" }
			VeQuickItem { id: adoptRequiresFormatItem; uid: volumeInfoRow.prefix + "/Admin/AdoptRequiresFormat" }
		}
		onCountChanged: root.recomputeVolumes()
	}

	// Waits for a dialog to actually finish closing before opening the
	// next one - chaining dialogLayer.open() calls synchronously risks
	// the first dialog's own closed-signal handler destroying the second
	// dialog instead of the first. Same pattern PageSettingsStorageVolume.
	// qml uses for all chained storage dialogs.
	property bool pendingReformatAfterClose: false
	property bool pendingReformatConfirmAfterClose: false
	property string pendingReformatVolumePrefix: ""
	property string pendingReformatMountPoint: ""
	property string pendingReformatFilesystem: ""
	property bool pendingReformatEraseEntireDrive: false
	// Entered in the Adopt dialog before its "Format first" action.
	// The backend performs format+label+adopt as one atomic call - see
	// dbus_service.py's format_and_adopt_volume() - so there is no
	// client-side pending-state or re-identification needed here at all,
	// unlike the old GUI-driven "wait for the result to reappear" flow.
	property string pendingReformatNickname: ""

	// Real progress feedback while a reformat is actually running - set
	// the moment the confirm dialog fires its trigger, cleared once that
	// same trigger leaf resets to "" (mkfs is synchronous on the backend,
	// so this covers the whole operation, not just the write). The row
	// itself (flatVolumeRowComponent) shows this in place of its action
	// buttons - see reformattingText below. reformattingTriggerName tracks
	// the FormatAndAdopt trigger that is in flight.
	property string reformattingVolumePrefix: ""
	property string reformattingTriggerName: "Admin/FormatAndAdopt"

	VeQuickItem {
		id: reformattingWatcherItem
		uid: root.reformattingVolumePrefix ? (root.reformattingVolumePrefix + "/" + root.reformattingTriggerName) : ""
		onValueChanged: {
			if (value === "" && root.reformattingVolumePrefix) {
				root.reformattingVolumePrefix = ""
			}
		}
	}

	Connections {
		target: Global.dialogLayer
		function onCurrentDialogChanged() {
			if (Global.dialogLayer.currentDialog) {
				return
			}
			if (root.pendingReformatAfterClose) {
				root.pendingReformatAfterClose = false
				Global.dialogLayer.open(reformatChooseFilesystemDialogComponent, {
					"volumePrefix": root.pendingReformatVolumePrefix,
					"mountPoint": root.pendingReformatMountPoint,
					"nickname": root.pendingReformatNickname,
					"eraseEntireDrive": root.pendingReformatEraseEntireDrive,
				})
			} else if (root.pendingReformatConfirmAfterClose) {
				root.pendingReformatConfirmAfterClose = false
				Global.dialogLayer.open(reformatConfirmDialogComponent, {
					"volumePrefix": root.pendingReformatVolumePrefix,
					"mountPoint": root.pendingReformatMountPoint,
					"filesystem": root.pendingReformatFilesystem,
					"nickname": root.pendingReformatNickname,
					"eraseEntireDrive": root.pendingReformatEraseEntireDrive,
				})
			}
		}
	}

	GradientListView {
		id: listView

		header: SettingsColumn {
			width: parent.width

			SettingsListHeader {
				//% "Storage volumes"
				text: qsTrId("pagesettingsstorage_volumes")
			}

			PrimaryListLabel {
				horizontalAlignment: Text.AlignHCenter
				preferredVisible: !root.storageManagerRunning
				//% "Storage Manager is not running"
				text: qsTrId("pagesettingsstorage_manager_not_running")
			}

			PrimaryListLabel {
				horizontalAlignment: Text.AlignHCenter
				preferredVisible: root.storageManagerRunning && root.volumeRecords.length === 0
				//% "No storage volumes detected"
				text: qsTrId("pagesettingsstorage_no_volumes")
			}

			Repeater {
				model: root.adoptedVolumes

				delegate: ListNavigation {
					required property var modelData

					text: modelData.name
					caption: root.adoptedCaption(modelData)
					secondaryText: root.adoptedUsageText(modelData)
					indicatorColor: Global.storage.volumeIndicatorColor(modelData.lifecycle, modelData.claimedBy)
					onClicked: Global.pageManager.pushPage(
							"/pages/settings/PageSettingsStorageVolume.qml",
							{"volumePrefix": modelData.prefix})
				}
			}

			Repeater {
				model: root.newVolumeRows

				delegate: flatVolumeRowComponent
			}

			Repeater {
				model: root.claimedVolumeRows

				delegate: flatVolumeRowComponent
			}

			Repeater {
				model: root.foreignVolumeRows

				delegate: flatVolumeRowComponent
			}

			SettingsListHeader {
				//% "Not currently connected"
				text: qsTrId("pagesettingsstorage_lost_header")
				visible: root.lostVolumes.length > 0
			}

			Repeater {
				model: root.lostVolumes

				delegate: ListButton {
					required property var modelData

					text: modelData.name
					//% "Forget"
					secondaryText: qsTrId("pagesettingsstorage_forget")
					//% "Adopted previously, not seen since - forgetting removes it from this list for good"
					caption: qsTrId("pagesettingsstorage_lost_caption")
					writeAccessLevel: VenusOS.User_AccessType_Installer
					onClicked: {
						Global.dialogLayer.open(forgetDialogComponent, {
							"volumePrefix": modelData.prefix,
							"volumeName": modelData.name,
						})
					}
				}
			}
		}

		// Everything rendered here lives in the header above - there's no
		// separate scrollable body distinct from it. A ListView's header
		// renders fully regardless of its own model/delegate, so an empty
		// model here is exactly "no body content", not a hack.
		model: 0
	}

	// -- flat action row, shared by New/Claimed/Foreign - no sub-page, one
	// or two inline actions right on the list, per the "actions belong at
	// the list view" decision (only Adopted keeps a chevron-to-detail-page,
	// since it's the one category with more than a couple of actions).
	Component {
		id: flatVolumeRowComponent

		ListSetting {
			id: flatRow

			required property var modelData
			readonly property string primaryActionText: modelData.primaryActionText || ""
			readonly property var primaryActionClicked: modelData.primaryActionClicked || null
			readonly property string secondaryActionText: modelData.secondaryActionText || ""
			readonly property var secondaryActionClicked: modelData.secondaryActionClicked || null
			readonly property string tertiaryActionText: modelData.tertiaryActionText || ""
			readonly property var tertiaryActionClicked: modelData.tertiaryActionClicked || null
			readonly property bool reformatting: !!modelData.reformatting

			text: modelData.text
			//% "Formatting…"
			caption: flatRow.reformatting ? qsTrId("pagesettingsstorage_formatting_in_progress") : modelData.caption
			indicatorColor: modelData.indicatorColor
			// Not a single whole-row click target (no onClicked here) -
			// only the two action buttons below are - but still needs
			// interactive:true for clickable/checkWriteAccessLevel to
			// actually gate them (ListSetting's own default, false,
			// would leave clickable permanently false).
			interactive: true

			contentItem: Item {
				implicitWidth: Theme.geometry_listItem_width
				implicitHeight: rowLayout.implicitHeight

				RowLayout {
					id: rowLayout
					anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
					spacing: flatRow.spacing

					ThreeLabelLayout {
						Layout.fillWidth: true
						primaryText: flatRow.text
						primaryLabel.font: flatRow.font
						primaryLabel.textFormat: flatRow.textFormat
						captionText: flatRow.caption
					}

					ListItemButton {
						text: flatRow.primaryActionText
						visible: !flatRow.reformatting && !!flatRow.primaryActionText
						enabled: flatRow.clickable
						onClicked: {
							if (flatRow.checkWriteAccessLevel() && flatRow.primaryActionClicked) {
								flatRow.primaryActionClicked()
							}
						}
					}
					ListItemButton {
						text: flatRow.secondaryActionText
						visible: !flatRow.reformatting && !!flatRow.secondaryActionText
						enabled: flatRow.clickable
						onClicked: {
							if (flatRow.checkWriteAccessLevel() && flatRow.secondaryActionClicked) {
								flatRow.secondaryActionClicked()
							}
						}
					}
					ListItemButton {
						text: flatRow.tertiaryActionText
						visible: !flatRow.reformatting && !!flatRow.tertiaryActionText
						enabled: flatRow.clickable
						onClicked: {
							if (flatRow.checkWriteAccessLevel() && flatRow.tertiaryActionClicked) {
								flatRow.tertiaryActionClicked()
							}
						}
					}
				}
			}
		}
	}

	function startEject(record) {
		Global.dialogLayer.open(ejectDialogComponent, {"volumePrefix": record.prefix, "volumeName": record.name})
	}

	function startAdopt(record) {
		Global.dialogLayer.open(manageDialogComponent, {
			"volumePrefix": record.prefix,
			"mountPoint": record.mountPoint,
			"filesystem": record.filesystem,
			"adoptRequiresFormat": record.adoptRequiresFormat,
		})
	}

	Component {
		id: forgetDialogComponent

		ModalWarningDialog {
			id: forgetDialog

			required property string volumePrefix
			required property string volumeName

			VeQuickItem {
				id: forgetVolumeAction
				uid: forgetDialog.volumePrefix + "/Admin/Forget"
			}

			//% "Forget this storage?"
			title: qsTrId("pagesettingsstorage_forget_confirm_title")
			//% "%1 will be removed from this list. If it's ever reconnected, it will show up again as new, unmanaged storage."
			description: qsTrId("pagesettingsstorage_forget_confirm_description").arg(forgetDialog.volumeName)
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			onAccepted: forgetVolumeAction.setValue(1)
		}
	}

	Component {
		id: ejectDialogComponent

		EjectDialog {}
	}

	Component {
		id: manageDialogComponent

		ModalDialog {
			id: manageDialog

			required property string volumePrefix
			required property string mountPoint
			required property string filesystem
			required property bool adoptRequiresFormat
			property bool adopting: false
			property bool adoptRequestSent: false
			property bool adoptTriggerAcknowledged: false
			property string failure: ""

			//% "Adopt this storage"
			title: qsTrId("pagesettingsstorage_manage_dialog_title")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
			focus: true

			// A string trigger carrying the nickname directly - naming and
			// adopting land as one atomic backend call, not two writes
			// this dialog has to sequence itself (that race was a real
			// bug, found live on raspberrypi5).
			function completeAdoption() {
				if (!manageDialog.adopting) {
					return
				}
				manageDialog.adopting = false
				if (manageOperationError.value) {
					manageDialog.failure = manageOperationError.value
					return
				}
				manageDialog.accept()
			}

			VeQuickItem {
				id: manageAdoptAction
				uid: manageDialog.volumePrefix + "/Admin/Adopt"
				onValueChanged: {
					if (!manageDialog.adoptRequestSent) {
						return
					}
					if (value !== "") {
						manageDialog.adoptTriggerAcknowledged = true
					} else if (manageDialog.adoptTriggerAcknowledged) {
						manageDialog.completeAdoption()
					}
				}
			}
			VeQuickItem {
				id: manageOperationError
				uid: manageDialog.volumePrefix + "/LastOperationError"
			}

			Timer {
				id: adoptTimer
				interval: 100
				repeat: false
				onTriggered: {
					manageDialog.adoptRequestSent = true
					manageAdoptAction.setValue(manageNameField.text)
				}
			}

			contentItem: ModalDialog.FocusableContentItem {
				// Wider than the standard dialog width - the portability
				// row's "Works on other systems (Windows, Mac, Linux)"
				// label needs room to stay on one line.
				implicitWidth: Theme.geometry_modalDialog_width + 100
				implicitHeight: manageDialogColumn.implicitHeight

				ColumnLayout {
					id: manageDialogColumn
					anchors {
						left: parent.left
						leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
						right: parent.right
						rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
					}
					spacing: Theme.geometry_modalDialog_content_spacing

					Label {
						Layout.fillWidth: true
						text: manageDialog.adoptRequiresFormat
								//% "This storage has an incompatible partition layout and must be reformatted before it can be adopted by this GX device. Reformatting erases all data and partitions. Give it a name, then choose Format and Adopt."
								? qsTrId("pagesettingsstorage_manage_dialog_format_required")
								//% "Give this storage a name, then choose how to adopt it for use by services on this GX device. Choose Adopt to keep its current format and data, or Format and Adopt to erase it and choose a new format."
								: qsTrId("pagesettingsstorage_manage_dialog_description")
						wrapMode: Text.Wrap
					}

					Label {
						Layout.fillWidth: true
						visible: manageDialog.adopting
						//% "Adopting storage…"
						text: qsTrId("pagesettingsstorage_adopting_in_progress")
						color: Theme.color_orange
						wrapMode: Text.Wrap
					}

					Label {
						Layout.fillWidth: true
						visible: !!manageDialog.failure
						//% "This storage cannot be managed: %1"
						text: qsTrId("pagesettingsstorage_manage_failed").arg(manageDialog.failure)
						color: Theme.color_red
						wrapMode: Text.Wrap
					}

					TextValidationField {
						id: manageNameField
						Layout.fillWidth: true
						focus: true
						//% "Unnamed volume"
						placeholderText: qsTrId("pagesettingsstorage_nickname_placeholder")
						maximumLength: 32
					}

					Label {
						Layout.fillWidth: true
						visible: manageNameField.text.trim().length === 0
						color: Theme.color_orange
						//% "Enter a name above to continue"
						text: qsTrId("pagesettingsstorage_manage_dialog_name_required")
						wrapMode: Text.Wrap
					}

					Label {
						Layout.fillWidth: true
						Layout.topMargin: Theme.geometry_modalDialog_content_spacing
						//% "Currently formatted as %1. Each service below can use it as-is if it supports that:"
						text: qsTrId("pagesettingsstorage_manage_dialog_compatibility_intro")
								.arg(root.filesystemDisplayName(manageDialog.filesystem))
						wrapMode: Text.Wrap
					}

						StorageFilesystemCompatibility {
							Layout.fillWidth: true
						}

					Item { Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing }
				}
			}

			footer: FocusScope {
				implicitHeight: Theme.geometry_modalDialog_footer_height
				focus: true
				Keys.onEscapePressed: manageDialog.reject()
				Keys.enabled: Global.keyNavigationEnabled

				SeparatorBar {
					anchors { left: parent.left; right: parent.right; top: parent.top }
				}

				RowLayout {
					anchors {
						fill: parent
						topMargin: Theme.geometry_modalDialog_content_spacing
						leftMargin: Theme.geometry_modalDialog_content_spacing
						rightMargin: Theme.geometry_modalDialog_content_spacing
						bottomMargin: Theme.geometry_modalDialog_content_spacing
					}
					spacing: Theme.geometry_modalDialog_content_spacing

					Button {
						text: CommonWords.cancel
						enabled: !manageDialog.adopting
						flat: false
						Layout.fillWidth: true
						Layout.fillHeight: true
						onClicked: manageDialog.reject()
					}
					Button {
						//% "Format and Adopt"
						text: qsTrId("pagesettingsstorage_manage_format")
						flat: false
						enabled: !manageDialog.adopting && manageNameField.text.trim().length > 0
						Layout.fillWidth: true
						Layout.fillHeight: true
						onClicked: {
							root.pendingReformatAfterClose = true
							root.pendingReformatVolumePrefix = manageDialog.volumePrefix
							root.pendingReformatMountPoint = manageDialog.mountPoint
							root.pendingReformatNickname = manageNameField.text
							root.pendingReformatEraseEntireDrive = true
							manageDialog.reject()
						}
					}
					Button {
						//% "Adopt"
						text: qsTrId("pagesettingsstorage_manage_just_adopt")
						visible: !manageDialog.adoptRequiresFormat
						flat: false
						enabled: !manageDialog.adopting && manageNameField.text.trim().length > 0
						Layout.fillWidth: true
						Layout.fillHeight: true
						onClicked: {
							manageDialog.failure = ""
							manageDialog.adopting = true
							adoptTimer.start()
						}
					}
				}
			}
		}
	}

	Component {
		id: reformatChooseFilesystemDialogComponent

		FormatChooseDialog {
			onFilesystemChosen: function (filesystem) {
				root.pendingReformatVolumePrefix = volumePrefix
				root.pendingReformatMountPoint = mountPoint
				root.pendingReformatNickname = nickname
				root.pendingReformatFilesystem = filesystem
				root.pendingReformatConfirmAfterClose = true
			}
		}
	}

	Component {
		id: reformatConfirmDialogComponent

		FormatConfirmDialog {
			onFormatStarted: function (triggerName) {
				root.reformattingVolumePrefix = volumePrefix
				root.reformattingTriggerName = triggerName
			}
			onFormatFinished: root.reformattingVolumePrefix = ""
		}
	}
}
