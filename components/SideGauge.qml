/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ArcGauge {
	id: root

	readonly property int _maxArcHeight: Math.sin(Utils.degreesToRadians(_maxAngle)) * radius
	readonly property int _arcOffset: -(radius - root.height) - strokeWidth / 2
	readonly property real _maxAngle: alignment & Qt.AlignVCenter ? Theme.geometry_briefPage_largeEdgeGauge_maxAngle : Theme.geometry_briefPage_smallEdgeGauge_maxAngle

	implicitWidth: Theme.geometry_briefPage_edgeGauge_width
	implicitHeight: alignment & Qt.AlignVCenter ? Theme.geometry_briefPage_largeEdgeGauge_height : Theme.geometry_briefPage_smallEdgeGauge_height
	alignment: Qt.AlignTop | Qt.AlignLeft
	direction: PathArc.Counterclockwise
	startAngle: alignment & Qt.AlignTop ? 90 : alignment & Qt.AlignVCenter ? 90 + _maxAngle/2 : 90 + _maxAngle
	endAngle: direction === PathArc.Counterclockwise ? startAngle - _maxAngle : startAngle + _maxAngle
	radius: Theme.geometry_briefPage_edgeGauge_radius
	useLargeArc: false
	strokeWidth: Theme.geometry_arc_strokeWidth
	arcY: alignment & Qt.AlignTop ? _arcOffset : alignment & Qt.AlignVCenter ? undefined : _arcOffset - _maxArcHeight
}
