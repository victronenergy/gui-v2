/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Column {
	id: root

	readonly property ActiveSystemBattery battery: Global.system && Global.system.battery ? Global.system.battery : null
	readonly property var duration: Utils.decomposeSeconds(battery.timeToGo)

	visible: !!battery && battery.timeToGo > 60

	Row {
		id: timeToGo

		spacing: Theme.geometry_boatPage_timeToGo_rowSpacing

		component TimeToGoQuantityLabel : QuantityLabel {
			font.pixelSize: Theme.font_size_body3
			anchors.verticalCenter: parent.verticalCenter
		}

		TimeToGoQuantityLabel {
			id: daysLabel

			unit: VenusOS.Units_Time_Day
			visible: value
			value: duration.days
		}

		TimeToGoQuantityLabel {
			id: hoursLabel

			unit: VenusOS.Units_Time_Hour
			visible: value || daysLabel.visible
			value: duration.hours
		}

		TimeToGoQuantityLabel {
			unit: VenusOS.Units_Time_Minute
			visible: value || hoursLabel.visible
			value: duration.minutes
		}
	}

	Label {
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		//% "Time To Go"
		text: qsTrId("boat_page_time_to_go")
	}
}
