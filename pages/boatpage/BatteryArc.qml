/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	required property bool animationEnabled
	readonly property var _battery: Global.system && Global.system.battery ? Global.system.battery : null
	readonly property int _leftGaugeCount: _battery ? 1 : 0
	property real _gaugeArcMargin: Theme.geometry_briefPage_edgeGauge_initialize_margin
	property real _gaugeArcOpacity: 1
	function _gaugeHeight(gaugeCount) {
		return Theme.geometry_briefPage_largeEdgeGauge_height / gaugeCount
	}

	/*
	  Returns the start/end angles for the gauge at the specified activeGaugeIndex, where the index
	  indicates the gauge's index (in a clockwise direction) within the active gauges for the left
	  or right edges.
	  E.g. if both the AC input and solar gauges are active, the index of the AC input gauge is 1,
	  since it is the second gauge when listing the left gauges in a clockwise direction. If the
	  solar gauge was not active, the index would be 0 instead.
	*/
	function _sideGaugeParameters(baseAngle, activeGaugeCount, activeGaugeIndex, isMultiPhase) {
		// Start/end angles are those for the large single-gauge case if there is only one gauge,
		// otherwise this angle is split into equal segments for each active gauge (minus spacing).
		let maxSideAngle
		let baseAngleOffset
		if (activeGaugeCount === 1) {
			maxSideAngle = Theme.geometry_briefPage_largeEdgeGauge_maxAngle
			baseAngleOffset = 0
		} else {
			const totalSpacingAngle = Theme.geometry_briefPage_edgeGauge_spacingAngle * (activeGaugeCount - 1)
			maxSideAngle = (Theme.geometry_briefPage_largeEdgeGauge_maxAngle - totalSpacingAngle) / activeGaugeCount
			baseAngleOffset = Theme.geometry_briefPage_edgeGauge_spacingAngle * activeGaugeIndex
		}
		const gaugeStartAngle = baseAngle + (activeGaugeIndex * maxSideAngle) + baseAngleOffset
		const gaugeEndAngle = gaugeStartAngle + maxSideAngle

		let angleOffset = 0
		let phaseLabelHorizontalMargin = 0
		if (isMultiPhase) {
			// If this is a multi-phase gauge, SideMultiGauge will be used instead of SideGauge.
			// Since SideMultiGauge shows 1,2,3 labels beneath the gauges, provide an angleOffset
			// for adjusting the arc angle to make room for the labels. Also provide the edge margin
			// to horizontally align each gauge label with its gauge.
			angleOffset = activeGaugeCount === 1 ? Theme.geometry_briefPage_edgeGauge_angleOffset_one_gauge
					: activeGaugeCount === 2 ? Theme.geometry_briefPage_edgeGauge_angleOffset_two_gauge
					: Theme.geometry_briefPage_edgeGauge_angleOffset_three_gauge
			phaseLabelHorizontalMargin = activeGaugeCount === 1 ? Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_one_gauge
					: activeGaugeCount === 2 ? Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_two_gauge
					: Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_three_gauge
		}

		return {
			start: gaugeStartAngle,
			end: gaugeEndAngle,
			angleOffset: angleOffset,
			phaseLabelHorizontalMargin: phaseLabelHorizontalMargin,
			activeGaugeCount: activeGaugeCount
		}
	}

	function _leftGaugeParameters(gauge, isMultiPhase = false) {
		// Store _leftGaugeCount in a temporary var, as it may change value unexpectedly during the
		// function call if it is updated via its property binding.
		const activeGaugeCount = _leftGaugeCount
		const gaugeHeight = _gaugeHeight(activeGaugeCount)

		// In a clockwise direction, the gauges start from the solar gauge and go upwards to the AC
		// input gauge.
		const baseAngle = 270 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		let gaugeIndex = 0  // solar yield gauge has index=0
		/*
		if (gauge === dcInputGauge) {
			gaugeIndex = solarYieldGauge.active ? 1 : 0
		} else if (gauge === acInputGauge) {
			gaugeIndex = (solarYieldGauge.active ? 1 : 0) + (dcInputGauge.active ? 1 : 0)
		}
		*/
		const params = _sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

		// Add y offset if gauge is aligned to the top or bottom.
		let arcVerticalCenterOffset = 0
		if (activeGaugeCount === 2) {
			arcVerticalCenterOffset = gaugeIndex === 0 ? -(gaugeHeight / 2) : gaugeHeight / 2
		} else if (activeGaugeCount === 3) {
			// The second (center) gauge does not need an offset, as it will be vertically centered.
			if (gaugeIndex === 0) {
				arcVerticalCenterOffset = -gaugeHeight
			} else if (gaugeIndex === 2) {
				arcVerticalCenterOffset = gaugeHeight
			}
		}
		return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
	}

	objectName: "BatteryArc"
	width: Theme.geometry_briefPage_edgeGauge_width
	height: active ? root._gaugeHeight(root._leftGaugeCount) : 0
	active: _battery
	sourceComponent: SideGauge {
		readonly property var gaugeParams: root._leftGaugeParameters(root)

		// DC input gauge progresses in clockwise direction (i.e. upwards).
		direction: PathArc.Clockwise
		startAngle: gaugeParams.start
		endAngle: gaugeParams.end
		arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
		horizontalAlignment: Qt.AlignLeft

		x: root._gaugeArcMargin
		opacity: root._gaugeArcOpacity
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
