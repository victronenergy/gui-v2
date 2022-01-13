/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
ArcGauge {
	width: Theme.geometry.briefPage.edgeGauge.width
	height: parent.height
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 + 25
	endAngle: 90 - 25
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: 66
	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.generatorRightGauge.label.rightMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: geometry.generatorRightGauge.label.verticalCenterOffset
		}
		title.text: qsTrId("brief_generator")
		physicalQuantity: Units.Power
		value: 874 // TODO - hook up to real value
		icon.source: "qrc:/images/generator.svg"
		rightAligned: true
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
