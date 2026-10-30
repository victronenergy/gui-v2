/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS

/*
	A scrolling list of rows, which fills its parent.

	Declare the rows directly inside it, for example:

		PluginGradientListView {
			PluginListSwitch { text: "Enabled" }
			PluginListNavigation { text: "Advanced"; pageUrl: Qt.resolvedUrl("AdvancedPage.qml") }
		}

	The rows are fixed when the list is created. To hide a row, set its preferredVisible to false:
	the row then takes no space, and key navigation skips it. If that row already has key focus,
	focus moves to a visible row. Hiding it does not clear focus, and Qt still delivers keys to
	an item that has focus. Do not set 'visible' on a row.
*/
FocusScope {
	id: root

	// The rows of the list, in order. Each one is a Plugin* row, such as PluginListSwitch.
	default property list<PluginListRow> rows

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	focus: true

	GradientListView {
		id: listView

		model: ObjectModel {
			id: rowModel
		}
	}

	// Nested, so this is not part of the plugin API. A function on the list would be.
	QtObject {
		id: hiddenRowFocus

		function watch(row) {
			// The parameter, not the loop variable: every connection must see its own row.
			row.effectiveVisibleChanged.connect(function() {
				if (row.effectiveVisible || !row.activeFocus) {
					return
				}
				Qt.callLater(function() { move(row) })
			})
		}

		function move(row) {
			if (row.effectiveVisible || !row.activeFocus) {
				return
			}
			// focusPolicy follows effectiveVisible, so this runs after that binding updates.
			// Otherwise the helper still accepts this row and puts focus back on it.
			listView.__keyNavHelper.updateFocusedItem()
			if (!row.activeFocus) {
				return
			}
			const next = nextVisibleRow(row)
			if (next) {
				for (let i = 0; i < root.rows.length; ++i) {
					if (root.rows[i] === next) {
						listView.currentIndex = i
						break
					}
				}
				next.forceActiveFocus()
			}
			if (row.activeFocus) {
				row.focus = false
			}
		}

		function nextVisibleRow(row) {
			const rows = root.rows
			let index = -1
			for (let i = 0; i < rows.length; ++i) {
				if (rows[i] === row) {
					index = i
					break
				}
			}
			for (let i = index + 1; i < rows.length; ++i) {
				if (canFocus(rows[i])) {
					return rows[i]
				}
			}
			for (let i = index - 1; i >= 0; --i) {
				if (canFocus(rows[i])) {
					return rows[i]
				}
			}
			return null
		}

		function canFocus(row) {
			// Same test as Utils.acceptsKeyNavigation(): TabFocus, and enabled.
			return row.effectiveVisible && row.enabled && (row.focusPolicy & Qt.TabFocus)
		}
	}

	Component.onCompleted: {
		// Fill the model once, when every row exists. The model is not bound to 'rows', as the
		// rows are fixed when the list is created.
		for (let i = 0; i < root.rows.length; ++i) {
			const row = root.rows[i]
			rowModel.append(row)
			hiddenRowFocus.watch(row)
		}
	}
}
