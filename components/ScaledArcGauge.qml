/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS
import "/components/Gauges.js" as Gauges

Item {
	id: gauge

	property real value
	property int valueType: VenusOS.Gauges_ValueType_FallingPercentage
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc.radius
	property alias strokeWidth: arc.strokeWidth
	property alias direction: arc.direction
	property int alignment: Qt.AlignLeft
	property var arcX
	property var arcY

	Item {
		// Antialiasing
		anchors.fill: parent
		layer.enabled: true
		layer.samples: 4

		ScaledArc {
			id: arc

			property real margin: strokeWidth/2

			width: radius*2 - strokeWidth
			height: width
			x: arcX !== undefined ? arcX : (gauge.alignment === Qt.AlignRight ? (gauge.width - 2*radius) - margin : margin)
			y: arcY !== undefined ? arcY : ((gauge.height - height) / 2 - margin)
			value: gauge.value
			strokeColor: Theme.color.ok
		}
	}
}
