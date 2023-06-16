/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

//
// Useful for displaying counters or time values that constantly increment, without changing the
// label width whenever the value changes.
//
Label {
	id: root

	width: timeFontMetrics.averageCharacterWidth * text.length

	FontMetrics {
		id: timeFontMetrics

		font: root.font
	}
}
