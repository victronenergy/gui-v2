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

	property alias value: arc.value

	property int valueType: VenusOS.Gauges_ValueType_FallingPercentage
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc.radius
	property alias useLargeArc: arc.useLargeArc
	property alias strokeWidth: arc.strokeWidth
	property alias direction: arc.direction
	property alias animationEnabled: arc.animationEnabled
	property int alignment: Qt.AlignLeft
	property var arcX
	property var arcY

	Item {
		id: antialiased
		anchors.fill: parent

		// Antialiasing without requiring multisample framebuffers.
		layer.enabled: true
		layer.smooth: true
		layer.textureSize: Qt.size(antialiased.width*2, antialiased.height*2)

		ProgressArc {
			id: arc

			readonly property int status: Gauges.getValueStatus(gauge.value, gauge.valueType)

			width: radius*2
			height: width
			x: arcX !== undefined ? arcX : (gauge.alignment & Qt.AlignRight ? (gauge.width - 2*radius) : 0)
			y: arcY !== undefined ? arcY : ((gauge.height - height) / 2)
			progressColor: Theme.statusColorValue(status)
			remainderColor: Theme.statusColorValue(status, true)
		}
	}
}
