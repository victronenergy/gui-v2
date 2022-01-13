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
	value: 33
	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.loadGauge.label.rightMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.loadGauge.label.verticalCenterOffset
		}
		title.text: qsTrId("brief_loads")
		physicalQuantity: Units.Power
		value: 6250 // TODO - hook up to real value
		icon.source: "qrc:/images/consumption.svg"
		rightAligned: true
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
