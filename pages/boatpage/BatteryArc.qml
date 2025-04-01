/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SideGauge {
	id: batteryGauge

	readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null

	anchors {
		left: parent.left
		leftMargin: Theme.geometry_page_content_horizontalMargin
	}
	y: (root.Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2

	direction: PathArc.Clockwise
	startAngle: Theme.geometry_boatPage_batteryGauge_startAngle
	endAngle: Theme.geometry_boatPage_batteryGauge_endAngle
	strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
	horizontalAlignment: Qt.AlignLeft
	animationEnabled: false
	valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	value: _battery.stateOfCharge || 0
}
