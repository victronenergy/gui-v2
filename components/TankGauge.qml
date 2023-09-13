/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Gauges as Gauges

VerticalGauge {
	id: root

	property int gaugeValueType
	property bool isGrouped: false

	readonly property int _gaugeStatus: Gauges.getValueStatus(value * 100, gaugeValueType)

	backgroundColor: Theme.statusColorValue(root._gaugeStatus, true)
	foregroundColor: Theme.statusColorValue(root._gaugeStatus)
	radius: Theme.geometry.levelsPage.tankGauge.radius

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color.levelsPage.gauge.separatorBarColor
		y: parent.height/4
	}

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color.levelsPage.gauge.separatorBarColor
		y: 2*parent.height/4
	}

	Rectangle {
		width: parent.width
		height: 2
		color: Theme.color.levelsPage.gauge.separatorBarColor
		y: 3*parent.height/4
	}

	CP.ColorImage {
		anchors.horizontalCenter: parent.horizontalCenter
		y: (root.height / 4 / 2) - (height / 2)
		height: Theme.geometry.levelsPage.tankGauge.alarmIcon.height
		fillMode: Image.PreserveAspectFit
		visible: !root.isGrouped
				 && ((gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage && value <= 0.05)
					 || (gaugeValueType === VenusOS.Gauges_ValueType_RisingPercentage && value >= 0.95))
		color: root.gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage
			   ? Theme.color.levelsPage.fallingGauge.alarmIcon
			   : Theme.color.levelsPage.risingGauge.alarmIcon
		source: "qrc:/images/icon_alarm_48.svg"
	}
}
