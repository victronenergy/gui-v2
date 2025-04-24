/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Column {
	id: root

	required property bool animationEnabled
	required property Gps gps
	required property MotorDrive motorDrive

	readonly property int _rightGaugeCount: gps.valid && motorDrive.dcConsumption.valid ? 1 // just the motor drive
											: dcLoadGauge.active ? 2 // both AC & DC
											: 1  // just AC. The AC load gauge is always active

	readonly property bool showing3Phases: acLoadGauge.active && Global.system.load.ac.phases.count === 3

	width: Theme.geometry_briefPage_edgeGauge_width
	on_RightGaugeCountChanged: pauseRightGaugeAnimations.restart()

	Loader {
		id: motorDriveLoadGauge

		width: Theme.geometry_briefPage_edgeGauge_width
		height: active ? Gauges.gaugeHeight(root._rightGaugeCount) : 0
		active: gps.valid && motorDrive.dcConsumption.valid
		sourceComponent: SideGauge {
			readonly property var gaugeParams: Gauges.rightGaugeParameters(0, _rightGaugeCount)
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end
			endAngle: gaugeParams.start
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
		height: active ? Gauges.gaugeHeight(root._rightGaugeCount) : 0
		active: !motorDriveLoadGauge.active

		sourceComponent: SideMultiGauge {
			readonly property var gaugeParams: Gauges.rightGaugeParameters(0, _rightGaugeCount, phaseModel.count > 1)
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
		height: active ? Gauges.gaugeHeight(root._rightGaugeCount) : 0
		active: !motorDriveLoadGauge.active && !isNaN(Global.system.dc.power)
		sourceComponent: SideGauge {
			readonly property var gaugeParams: Gauges.rightGaugeParameters(1, _rightGaugeCount,)
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

