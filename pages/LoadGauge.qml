/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
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
	value: system ? system.loads.power / Utils.maximumValue("system.loads.power") * 100 : 0

	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.loadGauge.label.rightMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.loadGauge.label.verticalCenterOffset
		}
		title.text: qsTrId("brief_loads")
		physicalQuantity: Enums.Units_PhysicalQuantity_Power
		value: system ? system.loads.power : 0
		icon.source: "qrc:/images/consumption.svg"
		alignment: Qt.AlignRight
		fontSize: Theme.font.size.xl
	}
}
