/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Loader {
	id: root

	required property bool animationEnabled
	required property bool isShoreConnected
	readonly property var _shoreInput: isShoreConnected ? Global.acInputs.highlightedInput : null
	readonly property int _leftGaugeCount: 1

	objectName: "ShoreArc"
	width: Theme.geometry_briefPage_edgeGauge_width
	height: Gauges.gaugeHeight(root._leftGaugeCount)
	sourceComponent: SideGauge {
		readonly property var gaugeParams: Gauges.leftGaugeParameters(0, 1)

		direction: PathArc.Clockwise
		startAngle: gaugeParams.start
		endAngle: gaugeParams.end
		arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
		horizontalAlignment: Qt.AlignLeft

		x: Theme.geometry_briefPage_edgeGauge_initialize_margin
		strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
		animationEnabled: root.animationEnabled && !pauseLeftGaugeAnimations.running
		valueType: VenusOS.Gauges_ValueType_NeutralPercentage
		value: _shoreInput ? shoreRange.valueAsRatio * 100 : 0
	}

	ValueRange {
		id: shoreRange
		value: _shoreInput ? Math.abs(_shoreInput.current) : 0
		maximumValue: _shoreInput && !isNaN(_shoreInput.inputInfo.maximumCurrent)
			? _shoreInput.inputInfo.maximumCurrent
			: 0
	}

	Timer {
		id: pauseLeftGaugeAnimations
		interval: Theme.animation_progressArc_duration
	}
}
