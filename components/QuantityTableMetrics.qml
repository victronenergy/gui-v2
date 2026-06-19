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
	function columnWidth(unit, decimals) {
		// This is a hack. Put in a reference to font.pixelSize, so that if this value changes, then
		// any bindings to columnWidth() are re-triggered. Otherwise if you switch between portrait
		// and landscape while on a page with a QuantityRow, the row geometries are not updated.
		const s = font.pixelSize

		// Make a best guess on the width required: use the width required by the font to show
		// "99.99<unit symbol>".
		// Due to QTBUG-124588, use tightBoundingRect() instead of advanceWidth().
		const maxTextRect = tightBoundingRect("99.99"
			+ (unit === VenusOS.Units_PowerFactor ? "PF" : Units.defaultUnitString(unit)))
		const defaultDecimals = Units.defaultUnitDecimals(unit)
		return maxTextRect.width + maxTextRect.x
			// Add a buffer to increase the padding around quantity labels, especially for quantity
			// table headers, which are longer and ideally should not be elided.
			+ Theme.geometry_quantityMetricPadding
			// If the quantity contains more decimals than usual, provide extra space for them.
			+ (decimals > defaultDecimals ? (decimals - defaultDecimals) * averageCharacterWidth : 0)
	}

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body3
}
