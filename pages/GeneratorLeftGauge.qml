/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
ArcGauge {
	id: root

	width: Theme.geometry.briefPage.edgeGauge.width
	height: parent.height
	value: 66
	startAngle: 270 - 25
	endAngle: 270 + 25
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth

	ValueDisplay {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.generatorLeftGauge.valueDisplay.leftMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.generatorLeftGauge.valueDisplay.verticalCenterOffset
		}
		title.text: qsTrId("brief_generator")
		physicalQuantity: Units.Power
		value: 874 // TODO - hook up to real value
		icon.source: "qrc:/images/generator.svg"
		rightAligned: false
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}
