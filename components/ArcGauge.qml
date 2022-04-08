/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import Qt5Compat.GraphicalEffects

// A progress gauge running an on arc, where 0° is at the top, and positive is clockwise
Item {
	id: gauge

	property real value
	property int valueType: Gauges.FallingPercentage
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
		//layer.samples: 4
		layer.effect: FastBlur {
			transparentBorder: true
			radius: 4
		}

		ProgressArc {
			id: arc

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
		}
	}
}
