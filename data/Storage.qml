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

	// Fires once per volume id the first time it's seen as Transient this
	// session - not persisted, so a restart re-prompts for anything still
	// unmanaged. Dismissing the prompt without adopting just means "not
	// now" - the volume stays Transient, nothing to persist, and it won't
	// fire again this session (below).
	signal newTransientVolumeDetected(string volumeId, string volumePrefix)

	property var _seenVolumeIds: ({})

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
			Component.onCompleted: root._recompute()

			VeQuickItem { id: lifecycleItem; uid: watcher.volumePrefix + "/Lifecycle" }
			VeQuickItem { id: claimedByItem; uid: watcher.volumePrefix + "/ClaimedBy" }
		}
		onObjectRemoved: root._recompute()
	}

	function _recompute() {
		let ids = []
		for (let i = 0; i < root._volumeWatchers.count; ++i) {
			const watcher = root._volumeWatchers.objectAt(i)
			if (!watcher || !watcher.volumeId || !watcher.isTransient || watcher.isClaimed) {
				continue
			}
			ids.push(watcher.volumeId)
			if (!root._seenVolumeIds[watcher.volumeId]) {
				root._seenVolumeIds[watcher.volumeId] = true
				root.newTransientVolumeDetected(watcher.volumeId, watcher.volumePrefix)
			}
		}
		root.transientVolumeIds = ids
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
