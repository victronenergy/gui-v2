/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
ArcGauge {
	width: 60
	height: 2*parent.height
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 + 24
	endAngle: 90 + 3
	radius: 360
	strokeWidth: 10
	value: 33
	arcY: -radius + strokeWidth/2
}
