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
			width: Theme.geometry.briefPage.edgeGauge.width
			x: index * 12
			opacity: 1.0 - index * 0.2
			height: root.height
			startAngle: 270 - 25
			endAngle: 270 + 25
			radius: Theme.geometry.briefPage.edgeGauge.radius - index * 12
			direction: PathArc.Clockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			value: modelData
		}
	}
}

