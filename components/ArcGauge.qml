/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl
import Victron.VenusOS

// A progress gauge running an on arc, where 0° is at the top, and positive is clockwise
Item {
	id: gauge

	property real value
	property int valueType: Gauges.FallingPercentage
	property real startAngle: 0
	property real endAngle: 180
	property real radius: 100
	property real strokeWidth: 10
	property int direction: PathArc.Clockwise
	property int alignment: Qt.AlignLeft
	property var arcX
	property var arcY

	Item {
		// Antialiasing
		anchors.fill: parent
		layer.enabled: true
		layer.samples: 4

		ProgressArc {
			property int status: Gauges.getValueStatus(gauge.value, gauge.valueType)
			property real margin: strokeWidth/2

			width: radius*2 - strokeWidth
			height: width
			x: arcX !== undefined ? arcX : (gauge.alignment === Qt.AlignRight ? (gauge.width - 2*radius) - margin : margin)
			y: arcY !== undefined ? arcY : ((gauge.height - height) / 2 - margin)
			radius: gauge.radius
			value: gauge.value
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
			strokeWidth: gauge.strokeWidth
			direction: gauge.direction
			startAngle: gauge.startAngle
			endAngle: gauge.endAngle
		}
	}
}
