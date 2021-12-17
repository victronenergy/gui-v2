/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
ArcGauge {
	width: Theme.geometry.briefPage.edgeGauge.width
	height: 2*parent.height
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 - 3
	endAngle: 90 - 24
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: 66
	arcY: -(radius - parent.height) - strokeWidth/2
}
