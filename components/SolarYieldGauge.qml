/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Utils

Item {
	id: root

	property alias alignment: quantityLabel.alignment
	property alias label: quantityLabel
	property bool animationEnabled

	implicitHeight: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

	Repeater {
		id: gaugeRepeater

		model: powerSampler.sampledAverages.length + 1

		delegate: ArcGauge {
			animationEnabled: root.animationEnabled
			width: Theme.geometry.briefPage.edgeGauge.width
			arcX: index*strokeWidth
			//arcY: (root.alignment & Qt.AlignVCenter) ? 0 : (-radius + strokeWidth/2)
			opacity: 1.0 - index * 0.3
			height: root.height
			alignment: root.alignment
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
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
			if (newAverages.length >= Theme.geometry.briefPage.solarHistoryGauge.maximumGaugeCount) {
				newAverages.pop()
			}
			_activeSamples = []
			sampledAverages = newAverages
		}
	}

	ArcGaugeQuantityLabel {
		id: quantityLabel

		alignment: root.alignment
		icon.source: "qrc:/images/solaryield.svg"
		quantityLabel.dataObject: Global.system.solar
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

