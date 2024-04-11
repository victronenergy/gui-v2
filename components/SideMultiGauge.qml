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
	property alias phaseModel: gaugeRepeater.model
	property real maximumCurrent

	width: parent.width
	height: parent.height

	Repeater {
		id: gaugeRepeater

		delegate: Item {
			id: gaugeDelegate

			required property real current
			required property int index

			width: Theme.geometry_briefPage_edgeGauge_width
			height: root.height

			SideGauge {
				id: gauge
				animationEnabled: root.animationEnabled
				width: Theme.geometry_briefPage_edgeGauge_width
				height: root.height
				x: (gaugeDelegate.index * (strokeWidth + Theme.geometry_briefPage_edgeGauge_gaugeSpacing))
					// If showing multiple gauges on the right edge, shift them towards the left
					- (gaugeRepeater.count === 1 || root.horizontalAlignment === Qt.AlignLeft ? 0 : (strokeWidth * gaugeRepeater.count))
				valueType: root.valueType
				direction: root.direction
				startAngle: root.startAngle
				endAngle: root.endAngle
				horizontalAlignment: root.horizontalAlignment
				arcVerticalCenterOffset: root.arcVerticalCenterOffset
				value: root.maximumCurrent === 0 ? 0 : (gaugeDelegate.current / root.maximumCurrent) * 100
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
				text: gaugeDelegate.index + 1
				font.pixelSize: Theme.font_size_brief_phase
			}
		}
	}
}
