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

	property var values: [ 45, 68, 75, 82 ]

	Repeater {
		model: root.values
		delegate: ArcGauge {
			width: 60
			x: index * 12
			opacity: 1.0 - index * 0.2
			height: root.height
			startAngle: 270 - 25
			endAngle: 270 + 25
			radius: 360 - index * 12
			strokeWidth: 10
			value: modelData
		}
	}
}

