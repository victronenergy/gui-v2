/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Flow {
	id: root

	required property PhaseModel phaseModel
	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property real minimumValue
	property real maximumValue
	property bool inputMode
	property int orientation: Qt.Vertical
	property bool animationEnabled
	property bool inOverviewWidget

	readonly property real _longEdgeLength: orientation === Qt.Vertical ? height : width
	readonly property real _delegateLength: (_longEdgeLength - (spacing * (phaseRepeater.count - 1))) / phaseRepeater.count

	width: orientation === Qt.Vertical
		   ? (phaseRepeater.count > 1 ? Theme.geometry_barGauge_vertical_width_small : Theme.geometry_barGauge_vertical_width_large)
		   : Theme.geometry_barGauge_vertical_width_large
	height: orientation === Qt.Vertical ? parent.height : Theme.geometry_barGauge_horizontal_height
	spacing: Theme.geometry_three_phase_gauge_spacing

	Repeater {
		id: phaseRepeater

		model: root.phaseModel
		delegate: Item {
			id: phaseDelegate

			required property int index
			required property real power
			required property real current
			readonly property bool feedingToGrid: root.inputMode && power < -1.0 // ignore noise values (close to zero)

			width: root.orientation === Qt.Vertical ? root.width : root._delegateLength
			height: root.orientation === Qt.Vertical ? root._delegateLength : root.height

			Label {
				id: phaseLabel

				anchors.verticalCenter: parent.verticalCenter
				leftPadding: Theme.geometry_barGauge_phaseLabel_leftPadding
				rightPadding: Theme.geometry_barGauge_phaseLabel_rightPadding
				text: phaseDelegate.index + 1
				font.pixelSize: Theme.font_size_phase_number
				visible: root.orientation === Qt.Horizontal && phaseRepeater.count > 1
			}

			ValueRange {
				id: valueRange

				// When feeding in to grid, use an absolute value for the gauge. This effectively
				// reverses the gauge direction so that negative and positive values have the same
				// value on the gauge, though negative values will be drawn in green.
				value: root.visible
					   ? phaseDelegate.feedingToGrid ? Math.abs(phaseDelegate.current) : phaseDelegate.current
					   : root.minimumValue
				minimumValue: 0
				maximumValue: Math.max(Math.abs(root.minimumValue), Math.abs(root.maximumValue))
			}

			Loader {
				id: gaugeLoader
				anchors.right: parent.right
				width: parent.width - (phaseLabel.visible ? phaseLabel.width : 0)
				height: parent.height
				sourceComponent: Global.isGxDevice ? cheapGauge : prettyGauge
			}

			Component {
				id: cheapGauge
				CheapBarGauge {
					foregroundColor: Theme.color_darkOk,phaseDelegate.feedingToGrid ? Theme.color_green : Theme.statusColorValue(valueStatus)
					backgroundColor: Theme.color_darkOk,phaseDelegate.feedingToGrid ? Theme.color_darkGreen
							: root.inOverviewWidget && valueStatus === Theme.Ok ? Theme.color_darkishBlue
							: Theme.statusColorValue(valueStatus, true)
					valueType: root.valueType
					value: valueRange.valueAsRatio
					orientation: root.orientation
					animationEnabled: root.animationEnabled
				}
			}

			Component {
				id: prettyGauge
				BarGauge {
					foregroundColor: Theme.color_darkOk,phaseDelegate.feedingToGrid ? Theme.color_green : Theme.statusColorValue(valueStatus)
					backgroundColor: Theme.color_darkOk,phaseDelegate.feedingToGrid ? Theme.color_darkGreen
							: root.inOverviewWidget && valueStatus === Theme.Ok ? Theme.color_darkishBlue
							: Theme.statusColorValue(valueStatus, true)
					valueType: root.valueType
					value: valueRange.valueAsRatio
					orientation: root.orientation
					animationEnabled: root.animationEnabled
				}
			}
		}
	}
}
