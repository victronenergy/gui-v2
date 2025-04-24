/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Loader {
	id: root

	required property bool animationEnabled
	readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null
	readonly property int _leftGaugeCount: _battery ? 1 : 0

	objectName: "BatteryArc"
	width: Theme.geometry_briefPage_edgeGauge_width
	height: active ? Gauges.gaugeHeight(root._leftGaugeCount) : 0
	active: _battery
	sourceComponent: SideGauge {
		readonly property var gaugeParams: Gauges.leftGaugeParameters(0, 1)

		// DC input gauge progresses in clockwise direction (i.e. upwards).
		direction: PathArc.Clockwise
		startAngle: gaugeParams.start
		endAngle: gaugeParams.end
		arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
		horizontalAlignment: Qt.AlignLeft

		x: Theme.geometry_briefPage_edgeGauge_initialize_margin
		strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
		animationEnabled: root.animationEnabled && !pauseLeftGaugeAnimations.running
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: _battery ? _battery.stateOfCharge : 0
	}
	onStatusChanged: if (status === Loader.Error) console.warn("Unable to load", objectName)
	on_LeftGaugeCountChanged: pauseLeftGaugeAnimations.restart()

	Timer {
		id: pauseLeftGaugeAnimations
		interval: Theme.animation_progressArc_duration
	}
}
