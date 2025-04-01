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

	readonly property var battery: Global.system && Global.system.battery ? Global.system.battery : null

	anchors {
		top: parent.top
		topMargin: Theme.geometry_boatPage_timeToGo_topMargin
		left: parent.left
		leftMargin: Theme.geometry_boatPage_timeToGo_leftMargin
	}

	visible: !!battery

	Row {
		id: timeToGo

		readonly property int secs: battery.timeToGo
		readonly property int days: Math.floor(secs / 86400)
		readonly property int hours: Math.floor((secs - (days * 86400)) / 3600)
		readonly property int minutes: Math.floor((secs - (days * 86400) - (hours * 3600)) / 60)

		spacing: Theme.geometry_boatPage_timeToGo_rowSpacing

		component TimeToGoQuantityLabel : QuantityLabel {
			font.pixelSize: Theme.font_size_body3
			anchors.verticalCenter: parent.verticalCenter
		}

		TimeToGoQuantityLabel {
			id: daysLabel

			unit: VenusOS.Units_Time_Day
			visible: value
			value: parent.days
		}

		TimeToGoQuantityLabel {
			id: hoursLabel

			unit: VenusOS.Units_Time_Hour
			visible: value || daysLabel.visible
			value: parent.hours
		}

		TimeToGoQuantityLabel {
			unit: VenusOS.Units_Time_Minute
			visible: value || hoursLabel.visible
			value: parent.minutes
		}
	}

	Label {
		visible: timeToGo.secs > 60
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		//% "Time To Go"
		text: qsTrId("boat_page_time_to_go")
	}
}
