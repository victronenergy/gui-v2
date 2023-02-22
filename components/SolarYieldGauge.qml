/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils

Item {
	id: root

	property alias alignment: quantityLabel.alignment
	property alias label: quantityLabel

	readonly property int _maxAngle: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	implicitHeight: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

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
			startAngle: root.alignment & Qt.AlignVCenter ? 270 + _maxAngle / 2 : 270
			endAngle: startAngle - _maxAngle
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
			direction: PathArc.Counterclockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			arcY: root.alignment & Qt.AlignVCenter ? undefined : -radius + strokeWidth/2

			value: gaugeRepeater.maximumYieldIndex < 0 ? NaN : Utils.scaleToRange(yieldValue, 0, gaugeRepeater.maximumYieldValue, 0, 100)
			onYieldValueChanged: Utils.updateMaximumYield(gaugeRepeater, model.index, yieldValue)
		}
	}
	ArcGaugeQuantityLabel {
		id: quantityLabel

		alignment: root.alignment
		icon.source: "qrc:/images/solaryield.svg"
		quantityLabel.dataObject: Global.solarChargers
	}
}

