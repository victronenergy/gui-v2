/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FontMetrics {
	function columnWidth(unit, defaultValue) {
		if (unit === VenusOS.Units_None) {
			return defaultValue
		}

		// Give the unit symbol some extra space on the column.
		const maxTextWidth = unit === VenusOS.Units_Energy_KiloWattHour
						   ? advanceWidth("99.99kWH")
						   : advanceWidth("99.99W")
		return maxTextWidth
	}

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body3
}
