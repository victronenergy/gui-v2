/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

// TODO
Item {
	id: root

	property var values: [ 45, 82, 75, 68 ]

	Repeater {
		id: repeater

		model: root.values
		delegate: ScaledArcGauge {
			width: Theme.geometry.briefPage.edgeGauge.width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.2
			height: root.height
			startAngle: 270 - 25
			endAngle: 270 + 25
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
			direction: PathArc.Clockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			value: modelData
		}
	}
	ValueDisplay {
		id: valueDisplay

		anchors {
			left: repeater.left
			leftMargin: Theme.geometry.solarYieldGauge.valueDisplay.leftMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.solarYieldGauge.valueDisplay.verticalCenterOffset
		}
		title.text: qsTrId("brief_solar_yield")
		physicalQuantity: Units.Power
		value: 428 // TODO - hook up to real value
		icon.source: "qrc:/images/solaryield.svg"
		rightAligned: false
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}

