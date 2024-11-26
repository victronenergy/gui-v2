/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

BarGaugeBase {
	id: root

	foregroundParent: root
	clip: true

	Rectangle {
		id: borderRect
		color: "transparent"
		radius: root.radius + border.width // "exterior" radius = "internal" radius + border.width
		width: parent.width + 2 * border.width
		height: parent.height + 2 * border.width
		x: -border.width
		y: -border.width
		z: 5 // drawn above everything else.
		// wide enough to perfectly cover the "missing" pixels due to interior rounding.
		border.width: Math.ceil(((Math.SQRT2 * (2 * root.radius)) - (2 * root.radius)) / 2)
		border.color: root.surfaceColor
	}
}
