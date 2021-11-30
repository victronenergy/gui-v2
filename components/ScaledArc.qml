/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Shape {
	id: control

	property real value
	property real startAngle
	property real endAngle
	property bool animationEnabled: true
	property alias radius: arc.radius
	property alias strokeWidth: arc.strokeWidth
	property alias strokeColor: arc.strokeColor
	property alias direction: arc.direction
	property alias fillColor: arc.fillColor

	property real midAngle: (startAngle + endAngle) / 2
	property real valueArc: ((endAngle - startAngle) * Math.min(Math.max(control.value, 0.0), 100.0) / 100.0)
	Behavior on valueArc {
		enabled: control.animationEnabled
		NumberAnimation {
			duration: 600
			easing.type: Easing.InOutQuad
		}
	}

	Arc {
		id: arc

		startAngle: control.midAngle - control.valueArc/2
		endAngle: control.midAngle + control.valueArc/2
	}
}
