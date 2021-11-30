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
	height: parent.height
	value: 66
	startAngle: 270 - 25
	endAngle: 270 + 25
	radius: 360
	strokeWidth: 10
}
