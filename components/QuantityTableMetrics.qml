/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a standardized width for a table column that shows a quantity.

	The width is adjusted depending on the font size and the quantity unit.
*/
FontMetrics {
	function columnWidth(unit, defaultValue) {
		if (unit === VenusOS.Units_None) {
			return defaultValue
		}

		// This is a hack. Put in a reference to font.pixelSize, so that if this value changes, then
		// any bindings to columnWidth() are re-triggered. Otherwise if you switch between portrait
		// and landscape while on a page with a QuantityRow, the row geometries are not updated.
		const s = font.pixelSize

		// Give the unit symbol some extra space on the column.
		// Due to QTBUG-124588, use tightBoundingRect() instead of advanceWidth().
		const maxTextRect = tightBoundingRect("99.99"
			+ (unit === VenusOS.Units_PowerFactor ? "PF" : Units.defaultUnitString(unit)))
		return maxTextRect.width + maxTextRect.x
	}

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body3
}
