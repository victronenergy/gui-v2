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

		model: SolarYieldModel {
			id: yieldModel
			dayRange: [0, Theme.geometry.briefPage.solarHistoryGauge.maximumGaugeCount + 1]
		}

		delegate: ScaledArcGauge {
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
			value: yieldModel.maximumYield ? Utils.scaleToRange(model.yieldKwh, 0, yieldModel.maximumYield, 0, 100) : 100
		}
	}

	ArcGaugeQuantityLabel {
		id: quantityLabel

		alignment: root.alignment
		icon.source: "qrc:/images/solaryield.svg"
		quantityLabel.dataObject: Global.solarChargers
	}
}

