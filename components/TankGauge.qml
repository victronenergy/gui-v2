/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ClippingBarGauge {
	id: root

	property bool isGrouped: false
	property bool expanded

	radius: Theme.geometry_levelsPage_tankGauge_radius
	surfaceColor: Theme.color_levelsPage_gauge_separatorBarColor

	Rectangle {
		width: root.orientation === Qt.Vertical ? parent.width : 2
		height: root.orientation === Qt.Vertical ? 2 : parent.height
		color: root.surfaceColor
		x: root.orientation === Qt.Vertical ? 0 : parent.width/4
		y: root.orientation === Qt.Vertical ? parent.height/4 : 0
		z: 5
	}

	Rectangle {
		width: root.orientation === Qt.Vertical ? parent.width : 2
		height: root.orientation === Qt.Vertical ? 2 : parent.height
		color: root.surfaceColor
		x: root.orientation === Qt.Vertical ? 0 : 2*parent.width/4
		y: root.orientation === Qt.Vertical ? 2*parent.height/4 : 0
		z: 5
	}

	Rectangle {
		width: root.orientation === Qt.Vertical ? parent.width : 2
		height: root.orientation === Qt.Vertical ? 2 : parent.height
		color: root.surfaceColor
		x: root.orientation === Qt.Vertical ? 0 : 3*parent.width/4
		y: root.orientation === Qt.Vertical ? 3*parent.height/4 : 0
		z: 5
	}

	CP.ColorImage {
		x: root.orientation === Qt.Vertical ? (parent.width - width)/2 : (root.width / 4 / 2) - (width / 2)
		y: root.orientation === Qt.Vertical ? (root.height / 4 / 2) - (height / 2) : (parent.height - height)/2
		z: 5

		visible: !root.isGrouped
				 && ((root.valueType === VenusOS.Gauges_ValueType_FallingPercentage && value <= 0.05)
					 || (root.valueType === VenusOS.Gauges_ValueType_RisingPercentage && value >= 0.95))
		color: root.valueType === VenusOS.Gauges_ValueType_FallingPercentage
			   ? Theme.color_levelsPage_fallingGauge_alarmIcon
			   : Theme.color_levelsPage_risingGauge_alarmIcon
		source: expanded ? "qrc:/images/icon_warning_32.svg"
						 : "qrc:/images/icon_warning_24.svg"
	}
}
