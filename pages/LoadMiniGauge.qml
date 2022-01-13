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
	startAngle: 90 + 24
	endAngle: 90 + 3
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: 33
	arcY: -radius + strokeWidth/2
	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.loadMiniGauge.label.rightMargin
			top: parent.top
			topMargin: Theme.geometry.loadMiniGauge.label.topMargin
		}
		title.text: qsTrId("brief_loads")
		physicalQuantity: Units.Power
		value: 6250 // TODO - hook up to real value
		icon.source: "qrc:/images/consumption.svg"
		rightAligned: true
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
