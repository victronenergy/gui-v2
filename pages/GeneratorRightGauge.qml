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
	height: parent.height
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 + 25
	endAngle: 90 - 25
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: systemTotals.generatorPower / Utils.maximumValue("systemTotals.generatorPower") * 100

	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.generatorRightGauge.label.rightMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.generatorRightGauge.label.verticalCenterOffset
		}
		title.text: qsTrId("brief_generator")
		physicalQuantity: Units.Power
		value: systemTotals.generatorPower
		icon.source: "qrc:/images/generator.svg"
		alignment: Qt.AlignRight
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
