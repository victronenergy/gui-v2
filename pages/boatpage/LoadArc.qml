/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	required property bool animationEnabled
	required property Gps gps
	required property MotorDrive motorDrive

	readonly property int _rightGaugeCount: gps.valid && motorDrive.dcConsumption.valid
											? 1 // just the motor drive
											: dcLoadGauge.active
											  ? 2 // both AC & DC
											  : 1  // just AC. The AC load gauge is always active

	readonly property bool showing3Phases: acLoadGauge.active && Global.system.load.ac.phases.count === 3


	function _gaugeHeight(gaugeCount) {
		return Theme.geometry_briefPage_largeEdgeGauge_height / gaugeCount
	}

	function _rightGaugeParameters(gauge, isMultiPhase = false) {
		// Store _rightGaugeCount in a temporary var, as it may change value unexpectedly during the
		// function call if it is updated via its property binding.
		const activeGaugeCount = _rightGaugeCount
		const gaugeHeight = _gaugeHeight(activeGaugeCount)

		// In a clockwise direction, the gauges start from the AC load gauge and go downwards to the
		// DC load gauge.
		const baseAngle = 90 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		const gaugeIndex = gauge === acLoadGauge ? 0 : 1
		const params = _sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

		// Add y offset if gauge is aligned to the top or bottom.
		let arcVerticalCenterOffset = 0
		if (activeGaugeCount === 2) {
			arcVerticalCenterOffset = gaugeIndex === 0 ? gaugeHeight / 2 : -(gaugeHeight / 2)
		}
		return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
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

	width: Theme.geometry_briefPage_edgeGauge_width
	on_RightGaugeCountChanged: pauseRightGaugeAnimations.restart()

	Loader {
		id: motorDriveLoadGauge

		width: Theme.geometry_briefPage_edgeGauge_width
		height: active ? root._gaugeHeight(root._rightGaugeCount) : 0
		active: gps.valid && motorDrive.dcConsumption.valid
		sourceComponent: SideGauge {
			readonly property var gaugeParams: Gauges.rightGaugeParameters(0, _rightGaugeCount)
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.start
			endAngle: gaugeParams.end
			strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
			horizontalAlignment: Qt.AlignRight
			animationEnabled: root.animationEnabled
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			value: motorDrive.dcConsumption.percentage
		}
	}

	Loader {
		id: acLoadGauge

		width: Theme.geometry_briefPage_edgeGauge_width
		height: active ? root._gaugeHeight(root._rightGaugeCount) : 0
		active: !motorDriveLoadGauge.active

		sourceComponent: SideMultiGauge {
			readonly property var gaugeParams: root._rightGaugeParameters(acLoadGauge, phaseModel.count > 1)
			readonly property real startAngleOffset: -gaugeParams.angleOffset

			// AC load gauge progresses in counter-clockwise direction (i.e. upwards).
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end + startAngleOffset
			endAngle: gaugeParams.start
			phaseLabelHorizontalMargin: gaugeParams.phaseLabelHorizontalMargin
			arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
			horizontalAlignment: Qt.AlignRight
			strokeWidth: phaseModel.count <= 1
						 ? Theme.geometry_boatPage_batteryGauge_strokeWidth
						 : Theme.geometry_arc_strokeWidth
			x: -root._gaugeArcMargin
			animationEnabled: root.animationEnabled
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			phaseModel: Global.system.load.ac.phases
			phaseModelProperty: "current"
			maximumValue: Global.system.load.maximumAcCurrent
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC load edge")
	}

	Loader {
		id: dcLoadGauge

		width: Theme.geometry_briefPage_edgeGauge_width
		height: active ? root._gaugeHeight(root._rightGaugeCount) : 0
		active: !motorDriveLoadGauge.active && !isNaN(Global.system.dc.power)
		sourceComponent: SideGauge {
			readonly property var gaugeParams: root._rightGaugeParameters(dcLoadGauge)

			// DC load gauge progresses in counter-clockwise direction (i.e. upwards).
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end
			endAngle: gaugeParams.start
			strokeWidth: Theme.geometry_boatPage_batteryGauge_strokeWidth
			arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
			horizontalAlignment: Qt.AlignRight

			x: -root._gaugeArcMargin
			animationEnabled: root.animationEnabled && !pauseRightGaugeAnimations.running
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			value: visible ? dcLoadsRange.valueAsRatio * 100 : 0

			ValueRange {
				id: dcLoadsRange
				value: root.visible ? Global.system.dc.power || 0 : 0
				maximumValue: Global.system.dc.maximumPower
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load DC load gauge")
	}

	Timer {
		id: pauseRightGaugeAnimations
		interval: Theme.animation_progressArc_duration
	}
}

