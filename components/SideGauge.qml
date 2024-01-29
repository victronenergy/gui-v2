/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

ArcGauge {
	id: root

	property int horizontalAlignment
	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	readonly property int valueStatus: Gauges.getValueStatus(value, valueType)

	width: parent.width
	height: parent.height
	radius: Theme.geometry_briefPage_edgeGauge_radius
	useLargeArc: false
	strokeWidth: Theme.geometry_arc_strokeWidth
	progressColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus)
	remainderColor: Theme.color_darkOk,Theme.statusColorValue(valueStatus, true)
	arcHorizontalCenterOffset: (horizontalAlignment & Qt.AlignLeft) ? -(width - (2 * radius)) / 2
			: (horizontalAlignment & Qt.AlignRight) ? (width - (2 * radius)) / 2
			: 0
}
