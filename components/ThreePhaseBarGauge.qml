/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Flow {
	id: root

	property int valueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property alias phaseModel: phaseRepeater.model
	property string phaseModelProperty
	property real minimumValue
	property real maximumValue

	width: Theme.geometry_overviewPage_widget_sideGauge_width
	height: parent ? parent.height : 0
	spacing: Theme.geometry_three_phase_gauge_spacing

	Repeater {
		id: phaseRepeater

		delegate: VerticalGauge {
			readonly property int valueStatus: Gauges.getValueStatus(valueRange.valueAsRatio * 100, root.valueType)

			width: parent.width
			height: (root.height - (root.spacing * (phaseRepeater.count - 1))) / phaseRepeater.count
			radius: Theme.geometry_overviewPage_widget_sideGauge_width
			backgroundColor: Theme.statusColorValue(valueStatus, true)
			foregroundColor: Theme.statusColorValue(valueStatus)
			value: valueRange.valueAsRatio

			ValueRange {
				id: valueRange
				value: model[root.phaseModelProperty]
				minimumValue: root.minimumValue
				maximumValue: root.maximumValue
			}
		}
	}
}
