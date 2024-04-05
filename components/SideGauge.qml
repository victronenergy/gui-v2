/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ArcGauge {
	id: root

	property int horizontalAlignment

	width: parent.width
	height: parent.height
	radius: Theme.geometry_briefPage_edgeGauge_radius
	useLargeArc: false
	strokeWidth: Theme.geometry_arc_strokeWidth
	arcHorizontalCenterOffset: (horizontalAlignment & Qt.AlignLeft) ? -(width - (2 * radius)) / 2
			: (horizontalAlignment & Qt.AlignRight) ? (width - (2 * radius)) / 2
			: 0
}
