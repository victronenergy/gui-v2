/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property bool interactive: true
	property real percentage: 0.0
	property bool isGrouped: false
	readonly property int _gaugeType: _tankProperties[model.type].gaugeType
	readonly property int _barHeight: (height / 4) - Theme.geometry.levelsPage.tankGauge.spacing
	readonly property int _warningLevel: _gaugeType === Gauges.FallingPercentage ?
											 ((percentage < 0.1) ? 2 : ((percentage < 0.2) ? 1 : 0 )) :
											 ((percentage > 0.9) ? 2 : ((percentage > 0.8) ? 1 : 0 )) // TODO: hook up to real warning / critical levels
	readonly property color _barGaugeBackgroundColor: [
		Theme.color.levelsPage.tankGroupData.barGaugeBackgroundColor.ok,
		Theme.color.levelsPage.tankGroupData.barGaugeBackgroundColor.warning,
		Theme.color.levelsPage.tankGroupData.barGaugeBackgroundColor.critical][_warningLevel]

	readonly property color _barGaugeForegroundColor: [Theme.color.ok, Theme.color.warning, Theme.color.critical][_warningLevel]

	signal testAddTank()					// only used for testing
	signal testRemoveTank(int tankIndex)	// only used for testing

	radius: Theme.geometry.levelsPage.tankGauge.radius
	gradient: Gradient { // Take care if modifying this; be sure to test the edge cases of percentage == 0.0 and percentage == 1.0
		GradientStop { position: 0.0; color: root.percentage >= 1.0 ? root._barGaugeForegroundColor : root._barGaugeBackgroundColor }
		GradientStop { position: Math.min(0.999999, (1.0 - root.percentage)); color: root.percentage >= 1.0 ? root._barGaugeForegroundColor : root._barGaugeBackgroundColor }
		GradientStop { position: Math.min(1.0, (1.0 - root.percentage) + 0.001); color: root.percentage <= 0.0 ? root._barGaugeBackgroundColor : root._barGaugeForegroundColor }
		GradientStop { position: 1.0; color: root._barGaugeForegroundColor }
	}

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
		anchors {
			top: parent.top
			topMargin: root.interactive ? 0 : Theme.geometry.levelsPage.tankGauge.alarmIcon.topMargin // TODO animate
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.levelsPage.tankGauge.alarmIcon.width
		height: Theme.geometry.levelsPage.tankGauge.alarmIcon.height
		visible: {
			if (root.isGrouped) {
				return false
			}
			if (_gaugeType === Gauges.FallingPercentage) {
				return (root.percentage < 0.05) ? true : false
			} else
			{
				return (root.percentage > 0.95) ? true : false
			}
		}
		color: _gaugeType === Gauges.FallingPercentage ? Theme.color.levelsPage.fallingGauge.alarmIcon : Theme.color.levelsPage.risingGauge.alarmIcon
		source: "qrc:/images/icon_alarm_48.svg"
	}
}
