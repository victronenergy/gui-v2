/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import Victron.Gauges

// A progress gauge running an on arc, where 0° is at the top.
Item {
	id: gauge

	implicitWidth: arc.implicitWidth
	implicitHeight: arc.implicitHeight

	property int valueType: VenusOS.Gauges_ValueType_FallingPercentage
	property int alignment: Qt.AlignTop | Qt.AlignLeft
	property int direction: ((alignment & Qt.AlignLeft && alignment & Qt.AlignVCenter)
			|| (alignment & Qt.AlignLeft && alignment & Qt.AlignTop)
			|| (alignment & Qt.AlignRight && alignment & Qt.AlignBottom))
		? PathArc.Clockwise : PathArc.Counterclockwise

	property alias arcWidth: arc.width
	property alias arcHeight: arc.height
	property alias arcX: arc.x
	property alias arcY: arc.y
	property alias value: arc.value
	property alias startAngle: arc.startAngle
	property alias endAngle: arc.endAngle
	property alias radius: arc.radius
	property alias strokeWidth: arc.strokeWidth
	property alias progressColor: arc.progressColor
	property alias remainderColor: arc.remainderColor
	property alias animationEnabled: arc.animationEnabled

	readonly property int _status: Gauges.getValueStatus(value, valueType)
	readonly property real _maxAngle: alignment & Qt.AlignVCenter
		? Theme.geometry.briefPage.largeEdgeGauge.maxAngle
		: Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	ShaderProgressArc {
		id: arc

		implicitWidth: Theme.geometry.briefPage.edgeGauge.width
		implicitHeight: (alignment & Qt.AlignVCenter)
			? Theme.geometry.briefPage.largeEdgeGauge.height
			: Theme.geometry.briefPage.smallEdgeGauge.height

		x: (alignment & Qt.AlignLeft) ? 0 : (parent.width - width)
		y: (alignment & Qt.AlignTop) ? (parent.height - height)
			: (alignment & Qt.AlignBottom) ? 0
			: (parent.height - height)/2

		startAngle: (alignment & Qt.AlignVCenter) ? 270 - _maxAngle/2
			: (alignment & Qt.AlignTop) ? 270
			: 90
		endAngle: startAngle + _maxAngle
		radius: Theme.geometry.briefPage.edgeGauge.radius - 2*strokeWidth
		strokeWidth: Theme.geometry.arc.strokeWidth
		progressColor: Theme.statusColorValue(_status)
		remainderColor: Theme.statusColorValue(_status, true)
		clockwise: direction === PathArc.Clockwise
	}
}
