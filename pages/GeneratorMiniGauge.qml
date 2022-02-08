/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

ArcGauge {
	width: Theme.geometry.briefPage.edgeGauge.width
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 - 3
	endAngle: 90 - 24
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: systemTotals.generatorPower / Utils.maximumValue("systemTotals.generatorPower") * 100
	arcY: -(radius - parent.height) - strokeWidth/2

	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.generatorMiniGauge.label.rightMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry.generatorMiniGauge.label.bottomMargin
		}
		title.text: qsTrId("brief_generator")
		physicalQuantity: Units.Power
		value: systemTotals.generatorPower
		icon.source: "qrc:/images/generator.svg"
		rightAligned: true
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
