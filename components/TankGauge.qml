/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

BarGauge {
	id: root

	property int gaugeValueType
	property bool isGrouped: false
	property bool expanded

	valueType: gaugeValueType
	radius: Theme.geometry_levelsPage_tankGauge_radius

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color_levelsPage_gauge_separatorBarColor
		y: parent.height/4
	}

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color_levelsPage_gauge_separatorBarColor
		y: 2*parent.height/4
	}

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color_levelsPage_gauge_separatorBarColor
		y: 3*parent.height/4
	}

	CP.ColorImage {
		anchors.horizontalCenter: parent.horizontalCenter
		y: (root.height / 4 / 2) - (height / 2)

		visible: !root.isGrouped
				 && ((gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage && value <= 0.05)
					 || (gaugeValueType === VenusOS.Gauges_ValueType_RisingPercentage && value >= 0.95))
		color: root.gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage
			   ? Theme.color_levelsPage_fallingGauge_alarmIcon
			   : Theme.color_levelsPage_risingGauge_alarmIcon
		source: expanded ? "qrc:/images/icon_warning_32.svg"
						 : "qrc:/images/icon_warning_24.svg"
	}
}
