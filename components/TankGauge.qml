/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

VerticalGauge {
	id: root

	objectName: "TankGauge"
	property int gaugeValueType
	property bool isGrouped: false

	// TODO: hook up to real warning / critical levels
	readonly property int _warningLevel: gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage
			? (value <= 0.05
			  ? VenusOS.TankGauge_WarningLevel_Alarm
			  : value <= 0.1
				? VenusOS.TankGauge_WarningLevel_Critical
				  : value <= 0.2
				  ? VenusOS.TankGauge_WarningLevel_Warning
				  : VenusOS.TankGauge_WarningLevel_Ok)
			: (value >= 0.95
			   ? VenusOS.TankGauge_WarningLevel_Alarm
			   : value >= 0.9
				 ? VenusOS.TankGauge_WarningLevel_Critical
				   : value >= 0.8
				   ? VenusOS.TankGauge_WarningLevel_Warning
				   : VenusOS.TankGauge_WarningLevel_Ok)

	readonly property var _backgroundColors: [
		Theme.color.darkOk,
		Theme.color.darkWarning,
		Theme.color.darkCritical,
		Theme.color.darkCritical
	]
	readonly property var _foregroundColors: [
		Theme.color.ok,
		Theme.color.warning,
		Theme.color.critical,
		Theme.color.critical
	]

	backgroundColor: _backgroundColors[_warningLevel]
	foregroundColor: _foregroundColors[_warningLevel]
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
		visible: !root.isGrouped && root._warningLevel === VenusOS.TankGauge_WarningLevel_Alarm
		color: root.gaugeValueType === VenusOS.Gauges_ValueType_FallingPercentage
			   ? Theme.color.levelsPage.fallingGauge.alarmIcon
			   : Theme.color.levelsPage.risingGauge.alarmIcon
		source: "qrc:/images/icon_alarm_48.svg"
	}
}
