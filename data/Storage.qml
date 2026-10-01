/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string storageServiceUid: BackendConnection.serviceUidForType("storage")

	// Every currently-transient (not yet adopted) volume id, app-wide -
	// today every storage-related page built its own /Volumes model
	// independently; this is the first shared one, so a proactive
	// "new storage detected" prompt can react from anywhere in the app,
	// not just while the user happens to be on a storage settings page.
	property var transientVolumeIds: []
	// Long-running storage work for the app-wide background activity UI.
	// This is produced by the same volume watchers that drive storage toasts,
	// avoiding a second /Volumes model with subtly different update behaviour.
	property var backgroundActivityItems: []

	function translatedText(id, fallback) {
		const translated = qsTrId(id)
		return translated === id ? qsTr(fallback) : translated
	}

	// Fires once per volume id the first time it's seen as Transient this
	// session - not persisted, so a restart re-prompts for anything still
	// unmanaged. Dismissing the prompt without adopting just means "not
	// now" - the volume stays Transient, nothing to persist, and it won't
	// fire again this session (below).
	signal newTransientVolumeDetected(string volumeId, string volumePrefix)

	property var _seenVolumeIds: ({})
	property var _shownCompletedEjectIds: ({})

	readonly property VeQItemSortTableModel _volumes: VeQItemSortTableModel {
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Volumes"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
	}

	// Instantiator, not Repeater - this is a non-visual QtObject singleton
	// (see Tanks.qml's _tankObjects for the same pattern in this codebase).
	readonly property Instantiator _volumeWatchers: Instantiator {
		model: VeQItemChildModel {
			model: root._volumes
			childId: "Id"
		}
		delegate: Item {
			// Item, not QtObject - QtObject has no default property, so a
			// bare VeQuickItem child below fails to parent at all ("Cannot
			// assign to non-existent default property"). Never shown -
			// Instantiator doesn't parent/position its delegates visually.
			id: watcher
			readonly property string volumePrefix: model.item.itemParent().uid
			readonly property string volumeId: model.item.value || ""
			readonly property string volumeName: nicknameItem.value || labelItem.value
					|| qsTrId("pagesettingsstorage_unnamed")
			readonly property int operationState: Number(operationItem.value ?? 0)
			readonly property bool isTransient: lifecycleItem.value === VenusOS.Storage_Lifecycle_Transient
			// A handler (venus-data/swupdate-offline) currently claims this
			// volume - it already has a real, legacy purpose, so it isn't
			// "new" in the adoptable sense even though Lifecycle is still
			// Transient. Excluded from the proactive prompt below - see
			// PageSettingsStorage.qml's volumeIndicatorColor for where this
			// otherwise surfaces (a distinct amber "not adoptable" state).
			readonly property bool isClaimed: !!claimedByItem.value
			onVolumeIdChanged: root._recompute()
			onIsTransientChanged: root._recompute()
			onIsClaimedChanged: root._recompute()
			onVolumeNameChanged: root._recompute()
			onOperationStateChanged: root._recompute()
			Component.onCompleted: root._recompute()

			VeQuickItem { id: lifecycleItem; uid: watcher.volumePrefix + "/Lifecycle" }
			VeQuickItem { id: claimedByItem; uid: watcher.volumePrefix + "/ClaimedBy" }
			VeQuickItem {
				id: operationItem
				uid: watcher.volumePrefix + "/Operation"
				onValueChanged: root._recompute()
			}
			VeQuickItem { id: stateItem; uid: watcher.volumePrefix + "/State" }
			VeQuickItem { id: nicknameItem; uid: watcher.volumePrefix + "/Nickname" }
			VeQuickItem { id: labelItem; uid: watcher.volumePrefix + "/Label" }
		}
		onObjectRemoved: root._recompute()
	}

	// Completed operations are retained by venus-storage. Watching that journal instead of the
	// brief /Volumes/<N>/Operation transition makes eject completion reliable for remote WASM
	// clients as well as the GUI that initiated the eject.
	readonly property VeQItemSortTableModel _operations: VeQItemSortTableModel {
		model: VeQItemTableModel {
			uids: [root.storageServiceUid + "/Operations"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterInvalid
	}

	readonly property Instantiator _operationWatchers: Instantiator {
		model: VeQItemChildModel {
			model: root._operations
			childId: "Id"
		}
		delegate: Item {
			id: operationWatcher
			readonly property string operationPrefix: model.item.itemParent().uid
			readonly property string operationId: model.item.value || ""
			readonly property int operationType: Number(typeItem.value ?? 0)
			readonly property int operationState: Number(stateItem.value ?? 0)
			readonly property string volumeId: volumeIdItem.value || ""
			readonly property int completedAt: Number(completedItem.value ?? 0)
			readonly property int errorCode: Number(errorCodeItem.value ?? 0)

			function checkCompletedEject() {
				// venus-storage OperationType.EJECT=3 and TransactionState.COMPLETED=2.
				if (!operationWatcher.operationId || operationWatcher.operationType !== 3
						|| operationWatcher.operationState !== 2 || operationWatcher.errorCode !== 0
						|| operationWatcher.completedAt <= 0
						|| root._shownCompletedEjectIds[operationWatcher.operationId]) {
					return
				}
				root._shownCompletedEjectIds[operationWatcher.operationId] = true
				// Do not replay old completion messages every time a GUI starts. A generous window
				// still covers MQTT propagation and a WASM tab briefly reconnecting during eject.
				const ageSeconds = (Date.now() / 1000) - operationWatcher.completedAt
				if (ageSeconds < -5 || ageSeconds > 60) {
					return
				}
				let name = ""
				for (let i = 0; i < root._volumeWatchers.count; ++i) {
					const volume = root._volumeWatchers.objectAt(i)
					if (volume && volume.volumeId === operationWatcher.volumeId) {
						name = volume.volumeName
						break
					}
				}
				//% "Ejection of %1 completed, ready for removal."
				Global.showToastNotification(VenusOS.Notification_Info,
					root.translatedText("storage_eject_completed",
							"Ejection of %1 completed, ready for removal.")
							.arg(name || root.translatedText("pagesettingsstorage_unnamed", "Unnamed storage")),
					8000)
			}

			onOperationIdChanged: operationWatcher.checkCompletedEject()
			onOperationTypeChanged: operationWatcher.checkCompletedEject()
			onOperationStateChanged: operationWatcher.checkCompletedEject()
			onCompletedAtChanged: operationWatcher.checkCompletedEject()
			onErrorCodeChanged: operationWatcher.checkCompletedEject()
			Component.onCompleted: operationWatcher.checkCompletedEject()

			VeQuickItem { id: typeItem; uid: operationWatcher.operationPrefix + "/Type" }
			VeQuickItem { id: stateItem; uid: operationWatcher.operationPrefix + "/State" }
			VeQuickItem { id: volumeIdItem; uid: operationWatcher.operationPrefix + "/VolumeId" }
			VeQuickItem { id: completedItem; uid: operationWatcher.operationPrefix + "/Completed" }
			VeQuickItem { id: errorCodeItem; uid: operationWatcher.operationPrefix + "/ErrorCode" }
		}
	}

	function _recompute() {
		let ids = []
		let activityItems = []
		for (let i = 0; i < root._volumeWatchers.count; ++i) {
			const watcher = root._volumeWatchers.objectAt(i)
			if (!watcher || !watcher.volumeId) {
				continue
			}

			// venus-storage OperationState: Releasing=3, Quiescing=4,
			// Ejecting=5, Recovering=6. These are the user-visible phases
			// that may wait for consumers and therefore belong in the global
			// activity indicator.
			if (watcher.operationState >= 3 && watcher.operationState <= 6) {
				activityItems.push({
					//% "Storage"
					service: root.translatedText("storageactivity_service", "Storage"),
					//% "Ejecting %1"
					action: root.translatedText("storageactivity_ejecting", "Ejecting %1")
							.arg(watcher.volumeName),
					//% "Releasing storage"
					progress: root.translatedText("storageactivity_releasing", "Releasing storage")
				})
			}

			if (watcher.isTransient && !watcher.isClaimed) {
				ids.push(watcher.volumeId)
				if (!root._seenVolumeIds[watcher.volumeId]) {
					root._seenVolumeIds[watcher.volumeId] = true
					root.newTransientVolumeDetected(watcher.volumeId, watcher.volumePrefix)
				}
			}
		}
		root.transientVolumeIds = ids
		root.backgroundActivityItems = activityItems
	}

	// Shared indicator-bar color for a volume row - New/Adopted/Not-
	// adoptable/Foreign, the simplified four-state model (deliberately
	// collapsing State/Operation detail the GUI doesn't need to show).
	// claimedBy is "" (unclaimed) or a Handler.name (venus-data,
	// swupdate-offline, ...) - see venus-storage's /Volumes/<N>/ClaimedBy.
	function volumeIndicatorColor(lifecycle, claimedBy) {
		switch (lifecycle) {
		case VenusOS.Storage_Lifecycle_ForeignManaged:
			return Theme.color_white
		case VenusOS.Storage_Lifecycle_AdoptedPersistent:
			return Theme.color_green
		case VenusOS.Storage_Lifecycle_Transient:
			return claimedBy ? Theme.color_orange : Theme.color_blue
		default:
			return Qt.rgba(0, 0, 0, 0)
		}
	}

	Component.onCompleted: Global.storage = root
}
