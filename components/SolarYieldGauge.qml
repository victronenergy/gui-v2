/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Item {
	id: root

	property int alignment
	property bool animationEnabled

	property int direction
	property real startAngle
	property real endAngle

	Repeater {
		id: gaugeRepeater

		model: powerSampler.sampledAverages.length + 1

		delegate: SideGauge {
			animationEnabled: root.animationEnabled
			width: Theme.geometry_briefPage_edgeGauge_width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.3
			height: root.height
			alignment: root.alignment
			direction: root.direction
			startAngle: root.startAngle
			endAngle: root.endAngle
			radius: Theme.geometry_briefPage_edgeGauge_radius - index*strokeWidth
			value: {
				if (!visible || solarMeasurements.maxPower == 0) {
					// No useful max yet, so show a full gauge
					return 100
				}
				// First gauge shows the current runtime power, other gauges show historical values.
				const power = model.index === 0 ? Global.system.solar.power : powerSampler.sampledAverages[model.index - 1]
				return Utils.scaleToRange(power, 0, solarMeasurements.maxPower, 0, 100)
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

	Connections {
		id: solarMeasurements

		property real maxPower: NaN

		target: Global.system.solar

		function onPowerChanged() {
			maxPower = isNaN(maxPower) ? Global.system.solar.power : Math.max(maxPower, Global.system.solar.power)
		}
	}
}

