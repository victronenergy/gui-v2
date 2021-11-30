/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
Item {
	id: root

	property var values: [ 45, 82, 75, 68 ]

	Repeater {
		model: root.values
		delegate: ScaledArcGauge {
			width: 60
			x: index * 12
			opacity: 1.0 - index * 0.2
			height: root.height
			startAngle: 270 - 25
			endAngle: 270 + 25
			radius: 360 - index * 12
			direction: PathArc.Clockwise
			strokeWidth: 10
			value: modelData
		}
	}
}

