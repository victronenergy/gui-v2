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
	height: parent.height
	value: 66
	startAngle: 270 - 25
	endAngle: 270 + 25
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
}
