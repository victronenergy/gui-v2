/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FontMetrics {
	property bool smallTextMode
	property real availableWidth
	property bool equalWidthColumns
	property int count
	property int spacing: Theme.geometry_quantityTable_horizontalSpacing

	// If specified, allows for a custom column width for the 'Units_None' column.
	// Eg. label columns with cells like "L1", "L2" can be thinner to allow wider columns elsewhere.
	property int firstColumnWidth

	font.family: Global.fontFamily
	font.pixelSize: smallTextMode ? Theme.font_size_body2 : Theme.font_size_body3

	function columnWidth(unit) {
		if (!!firstColumnWidth) {
			if (unit === VenusOS.Units_None) {
				return firstColumnWidth
			}
			return (availableWidth - firstColumnWidth) / (count - 1)
		}

		if (equalWidthColumns) {
			return availableWidth / count
		}

		// Give the unit symbol some extra space on the column.
		const maxTextWidth = unit === VenusOS.Units_Energy_KiloWattHour
						   ? advanceWidth("9999kWH")
						   : advanceWidth("9999W")
		return maxTextWidth + spacing
	}
}
