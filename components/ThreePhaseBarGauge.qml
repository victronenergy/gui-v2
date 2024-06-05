/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Flow {
	id: root

	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property alias phaseModel: phaseRepeater.model
	property string phaseModelProperty
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

		delegate: Item {
			width: root.orientation === Qt.Vertical ? root.width : root._delegateLength
			height: root.orientation === Qt.Vertical ? root._delegateLength : root.height

			Label {
				id: phaseLabel

				anchors.verticalCenter: parent.verticalCenter
				leftPadding: Theme.geometry_barGauge_phaseLabel_leftPadding
				rightPadding: Theme.geometry_barGauge_phaseLabel_rightPadding
				text: model.index + 1
				font.pixelSize: Theme.font_size_phase_number
				visible: root.orientation === Qt.Horizontal && phaseRepeater.count > 1
			}

			ValueRange {
				id: valueRange
				value: root.visible ? model[root.phaseModelProperty] : root.minimumValue
				minimumValue: root.minimumValue
				maximumValue: root.maximumValue
			}

			Loader {
				id: gaugeLoader
				anchors.right: parent.right
				width: parent.width - (phaseLabel.visible ? phaseLabel.width : 0)
				height: parent.height
				sourceComponent: Global.isGxDevice ? cheapGauge : prettyGauge
				readonly property bool feedingToGrid: root.inputMode
						&& (model.power || 0) < 0
						&& Global.systemSettings.essFeedbackToGridEnabled
			}

			Component {
				id: cheapGauge
				CheapBarGauge {
					foregroundColor: Theme.color_darkOk,gaugeLoader.feedingToGrid ? Theme.color_green : Theme.statusColorValue(valueStatus)
					backgroundColor: Theme.color_darkOk,gaugeLoader.feedingToGrid ? Theme.color_darkGreen
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
					foregroundColor: Theme.color_darkOk,gaugeLoader.feedingToGrid ? Theme.color_green : Theme.statusColorValue(valueStatus)
					backgroundColor: Theme.color_darkOk,gaugeLoader.feedingToGrid ? Theme.color_darkGreen
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
