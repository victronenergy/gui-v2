/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

// TODO
Item {
	id: root

	Repeater {
		id: repeater

		model: solarChargers ? solarChargers.model : null
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
			value: solarTracker.power / Utils.maximumValue("solarTracker.power") * 100
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
		value: solarChargers ? solarChargers.power : 0
		icon.source: "qrc:/images/solaryield.svg"
		fontSize: Theme.font.size.xl
	}
}

