/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ArcGauge {
	id: root

	implicitWidth: Theme.geometry_briefPage_edgeGauge_width
	radius: Theme.geometry_briefPage_edgeGauge_radius
	useLargeArc: false
	strokeWidth: Theme.geometry_arc_strokeWidth
	arcY: alignment & Qt.AlignTop ? -(radius - root.height)
			: alignment & Qt.AlignBottom ? -radius
			: undefined     // Qt.AlignVCenter
}
