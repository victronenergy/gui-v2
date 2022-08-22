/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils

Item {
	id: root

	property int gaugeAlignmentY: Qt.AlignVCenter // valid values: Qt.AlignVCenter, Qt.AlignBottom
	property alias label: quantityLabel

	readonly property int _gaugeAlignmentX: Qt.AlignLeft
	readonly property int _maxAngle: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	implicitHeight: gaugeAlignmentY === Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

	Repeater {
		id: gaugeRepeater

		property real maximumYieldValue
		property int maximumYieldIndex: -1

		model: Global.solarChargers.yieldHistory.slice(0, Theme.geometry.briefPage.solarHistoryGauge.maximumGaugeCount)

		delegate: ScaledArcGauge {
			readonly property real yieldValue: modelData

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

			value: Utils.scaleToRange(yieldValue, 0, gaugeRepeater.maximumYieldValue, 0, 100)
			onYieldValueChanged: Utils.updateMaximumYield(gaugeRepeater, model.index, yieldValue)
		}
	}
	ArcGaugeQuantityLabel {
		id: quantityLabel

		gaugeAlignmentX: root._gaugeAlignmentX
		gaugeAlignmentY: root.gaugeAlignmentY
		icon.source: "qrc:/images/solaryield.svg"
		quantityLabel.dataObject: Global.solarChargers
	}
}

