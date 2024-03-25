/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FontMetrics {
	property var _groups: []
	property int maxColumnWidth: advanceWidth("9999kWH")
	signal updated(var columnWidths)

	font.family: Global.fontLoader.name
	font.pixelSize: Theme.font_size_body3

	function remove(repeater) {
		var groups = _groups
		delete groups[repeater]
		_groups = groups
	}

	function update(repeater) {
		// Gather the updated dimensions
		var childWidths = []
		for (let i = 0; i < repeater.count; i++) {
			const child = repeater.itemAt(i)

			if (child && (child.showValue === undefined || child.showValue)) {
				childWidths[childWidths.length] = child.columnImplicitWidth
			}
		}

		// Store the new dimensions
		var groups = _groups
		groups[repeater] = childWidths
		_groups = groups

		// Calculate the number of columns
		var columns = 0
		for (let group in groups) {
			columns = Math.max(columns, groups[group].length)
		}

		// Calculate the optimal width for each column
		var columnWidths = []
		for (let j = 1; j <= columns; j++) {
			columnWidths[columns - j] = 0
			for (let group in groups) {
				var widths = groups[group]
				if (j <= widths.length) {
					columnWidths[columns - j] = Math.min(maxColumnWidth, Math.max(columnWidths[columns - j], widths[widths.length - j]))
				}
			}
		}

		// signal quantity groups
		updated(columnWidths)
	}
}
