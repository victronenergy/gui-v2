/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

ArcGauge {
	id: root

	width: Theme.geometry.briefPage.edgeGauge.width
	height: parent.height
	value: system ? system.generator.power / Utils.maximumValue("system.generator.power") * 100 : 0
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
		physicalQuantity: Enums.Units_PhysicalQuantity_Power
		value: system ? system.generator.power : 0
		icon.source: "qrc:/images/generator.svg"
		fontSize: Theme.font.size.xl
	}
}
