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
	property alias animationEnabled: arc.animationEnabled
	property alias radius: arc.radius
	property alias useLargeArc: arc.useLargeArc
	property alias strokeWidth: arc.strokeWidth
	property alias strokeColor: arc.strokeColor
	property alias direction: arc.direction
	property alias fillColor: arc.fillColor
	property real valueArc: ((endAngle - startAngle) * Math.min(Math.max(control.value, 0.0), 100.0) / 100.0)

	Arc {
		id: arc

		startAngle: control.startAngle
		endAngle: control.startAngle + control.valueArc
	}
}
