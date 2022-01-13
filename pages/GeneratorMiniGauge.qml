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
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 - 3
	endAngle: 90 - 24
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: 66
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
		value: 874 // TODO - hook up to real value
		icon.source: "qrc:/images/generator.svg"
		rightAligned: true
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
