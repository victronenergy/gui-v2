/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import "/components/Gauges.js" as Gauges

// A progress gauge running an on arc, where 0° is at the top, and positive is clockwise
Item {
	id: gauge

	property real value
	property int valueType: VenusOS.Gauges_ValueType_FallingPercentage
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc.radius
	property alias strokeWidth: arc.strokeWidth
	property alias direction: arc.direction
	property alias animationEnabled: arc.animationEnabled
	property int alignment: Qt.AlignLeft
	property var arcX
	property var arcY

	Item {
		// Antialiasing
		anchors.fill: parent
		layer.enabled: true
		layer.samples: 4

		ProgressArc {
			id: arc

			property int status: Gauges.getValueStatus(gauge.value, gauge.valueType)

			width: radius*2
			height: width
			x: arcX !== undefined ? arcX : (gauge.alignment === Qt.AlignRight ? (gauge.width - 2*radius) : 0)
			y: arcY !== undefined ? arcY : ((gauge.height - height) / 2)
			radius: gauge.radius
			value: gauge.value
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
		}
	}
}
