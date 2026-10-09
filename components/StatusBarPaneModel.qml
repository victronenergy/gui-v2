/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// StatusBarPane objects, sorted by order, then by the order in which they were added.
ListModel {
	id: root

	function addPane(pane) {
		if (findPane(pane.paneId)) {
			console.warn("StatusBarPaneModel: ignoring duplicate pane id", pane.paneId)
			return
		}
		let insertionIndex = root.count
		while (insertionIndex > 0 && root.get(insertionIndex - 1).pane.order > pane.order) {
			--insertionIndex
		}
		root.insert(insertionIndex, { pane: pane })
	}

	function removePane(pane) {
		for (let i = 0; i < root.count; ++i) {
			if (root.get(i).pane === pane) {
				root.remove(i)
				break
			}
		}
	}

	function findPane(paneId) {
		for (let i = 0; i < root.count; ++i) {
			const pane = root.get(i).pane
			if (pane.paneId === paneId) {
				return pane
			}
		}
		return null
	}
}
