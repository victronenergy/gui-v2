/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils
import "../data"

Item {
	id: root

	property int gaugeAlignmentY: Qt.AlignVCenter // valid values: Qt.AlignVCenter, Qt.AlignBottom
	readonly property int _gaugeAlignmentX: Qt.AlignLeft
	readonly property int _maxAngle: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

	Repeater {
		id: repeater

		model: solarChargers ? solarChargers.model : null
		delegate: ScaledArcGauge {
			width: Theme.geometry.briefPage.edgeGauge.width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.3
			height: root.height
			startAngle: root.gaugeAlignmentY === Qt.AlignVCenter ? 270 + _maxAngle / 2 : 270
			endAngle: startAngle - _maxAngle
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
			direction: PathArc.Counterclockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			arcY: root.gaugeAlignmentY === Qt.AlignVCenter ? undefined : -radius + strokeWidth/2
			value: solarTracker.power / Utils.maximumValue("solarTracker.power") * 100
		}
	}
	ArcGaugeValueDisplay {
		id: valueDisplay

		gaugeAlignmentX: root._gaugeAlignmentX
		gaugeAlignmentY: root.gaugeAlignmentY
		layoutDirection: root._gaugeAlignmentX === Qt.AlignRight ? Qt.RightToLeft : Qt.LeftToRight
		source: "qrc:/images/solaryield.svg"
		physicalQuantity: Units.Power
		value: solarChargers ? solarChargers.power : NaN
	}
}

