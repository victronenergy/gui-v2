/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property int direction
	property real startAngle
	property real endAngle
	property int horizontalAlignment
	property real arcVerticalCenterOffset
	property bool animationEnabled

	width: parent.width
	height: parent.height

	Repeater {
		id: gaugeRepeater

		model: powerSampler.sampledAverages.length + 1

		delegate: SideGauge {
			animationEnabled: root.animationEnabled
			width: Theme.geometry_briefPage_edgeGauge_width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.3
			height: root.height
			direction: root.direction
			startAngle: root.startAngle
			endAngle: root.endAngle
			horizontalAlignment: root.horizontalAlignment
			arcVerticalCenterOffset: root.arcVerticalCenterOffset
			valueType: VenusOS.Gauges_ValueType_NeutralPercentage
			value: valueRange.valueAsRatio * 100

			ValueRange {
				id: valueRange

				// First gauge shows the current runtime power, other gauges show historical values.
				value: model.index === 0 ? Global.system.solar.power : powerSampler.sampledAverages[model.index - 1]
				maximumValue: Global.system.solar.maximumPower
			}
		}
	}

	// Take 30-second samples of the solar power. Every 5 minutes, take the average of these samples
	// and add a new gauge bar with that value.
	Timer {
		id: powerSampler

		property var sampledAverages: []
		property var _activeSamples: []

		running: true
		repeat: true
		interval: 30 * 1000
		onTriggered: {
			_activeSamples.push(Global.system.solar.power)
			if (_activeSamples.length < 10) {
				return
			}
			const averagePower = _activeSamples.reduce((accumulator, currentValue) => accumulator + currentValue) / _activeSamples.length
			let newAverages = sampledAverages
			newAverages.unshift(averagePower)
			if (newAverages.length >= Theme.geometry_briefPage_solarHistoryGauge_maximumGaugeCount) {
				newAverages.pop()
			}
			_activeSamples = []
			sampledAverages = newAverages
		}
	}
}

