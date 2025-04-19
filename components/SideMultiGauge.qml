/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property int direction
	property real startAngle
	property real endAngle
	property int horizontalAlignment
	property real arcVerticalCenterOffset
	property real phaseLabelHorizontalMargin
	property bool animationEnabled
	property var phaseModel
	property string phaseModelProperty
	property real minimumValue
	property real maximumValue
	property bool inputMode
	property int strokeWidth: Theme.geometry_arc_strokeWidth

	width: parent.width
	height: parent.height

	onPhaseModelPropertyChanged: {
		placeholderModel.clear();
		if (phaseModelProperty.length > 0) {
			let itemProperties = {}
			itemProperties[phaseModelProperty] = NaN
			placeholderModel.append(itemProperties)
		}
	}

	ListModel {
		id: placeholderModel
	}

	Repeater {
		id: gaugeRepeater

		model: root.phaseModel && root.phaseModel.count ? root.phaseModel : placeholderModel

		delegate: Item {
			id: gaugeDelegate

			width: Theme.geometry_briefPage_edgeGauge_width
			height: root.height

			// ignore noise values (close to zero)
			readonly property real modelValue: Math.floor(Math.abs(model[root.phaseModelProperty] || 0)) < 1.0 ? 0.0
					: model[root.phaseModelProperty]
			readonly property bool feedingToGrid: root.inputMode && modelValue < 0.0

			SideGauge {
				id: gauge
				animationEnabled: root.animationEnabled
				width: Theme.geometry_briefPage_edgeGauge_width
				height: root.height
				x: (model.index * (strokeWidth + Theme.geometry_briefPage_edgeGauge_gaugeSpacing))
					// If showing multiple gauges on the right edge, shift them towards the left
					- (gaugeRepeater.count === 1 || root.horizontalAlignment === Qt.AlignLeft ? 0 : (strokeWidth * gaugeRepeater.count))
				valueType: root.valueType
				progressColor: Theme.color_darkOk,gaugeDelegate.feedingToGrid ? Theme.color_green : Theme.statusColorValue(valueStatus)
				remainderColor: Theme.color_darkOk,gaugeDelegate.feedingToGrid ? Theme.color_darkGreen : Theme.statusColorValue(valueStatus, true)
				direction: root.direction
				startAngle: root.startAngle
				endAngle: root.endAngle
				strokeWidth: root.strokeWidth
				horizontalAlignment: root.horizontalAlignment
				arcVerticalCenterOffset: root.arcVerticalCenterOffset
				value: valueRange.valueAsRatio * 100
			}

			Label {
				anchors {
					left: root.horizontalAlignment === Qt.AlignLeft ? parent.left : undefined
					leftMargin: root.phaseLabelHorizontalMargin + gauge.x
					right: root.horizontalAlignment === Qt.AlignRight ? parent.right : undefined
					rightMargin: root.phaseLabelHorizontalMargin - gauge.x
					bottom: parent.bottom
					bottomMargin: Theme.geometry_briefPage_edgeGauge_phaseLabel_bottomMargin
				}
				visible: gaugeRepeater.count > 1
				text: model.index + 1
				font.pixelSize: Theme.font_size_phase_number
			}

			ValueRange {
				id: valueRange

				// When feeding in to grid, use an absolute value for the gauge. This effectively
				// reverses the gauge direction so that negative and positive values have the same
				// value on the gauge, though negative values will be drawn in green.
				value: root.visible
					   ? (gaugeDelegate.feedingToGrid ? Math.abs(gaugeDelegate.modelValue) : gaugeDelegate.modelValue)
					   : root.minimumValue
				minimumValue: 0
				maximumValue: Math.max(Math.abs(root.minimumValue), Math.abs(root.maximumValue))
			}
		}
	}
}
