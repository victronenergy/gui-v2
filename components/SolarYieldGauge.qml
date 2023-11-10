/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import "/components/Utils.js" as Utils

Item {
	id: root

	property alias alignment: quantityLabel.alignment
	property alias label: quantityLabel
	property bool animationEnabled
	readonly property int _maxAngle: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.maxAngle : Theme.geometry.briefPage.smallEdgeGauge.maxAngle

	implicitHeight: alignment & Qt.AlignVCenter ? Theme.geometry.briefPage.largeEdgeGauge.height : Theme.geometry.briefPage.smallEdgeGauge.height

	Repeater {
		id: gaugeRepeater

		model: powerSampler.sampledAverages.length + 1

		delegate: ScaledArcGauge {
			animationEnabled: false // never animate the solar gauge.  It's too expensive.
			width: Theme.geometry.briefPage.edgeGauge.width
			x: index*strokeWidth
			opacity: 1.0 - index * 0.3
			height: root.height
			startAngle: root.alignment & Qt.AlignVCenter ? 270 + _maxAngle/2 : 270
			endAngle: startAngle - _maxAngle
			radius: Theme.geometry.briefPage.edgeGauge.radius - index*strokeWidth
			useLargeArc: false
			direction: PathArc.Counterclockwise
			strokeWidth: Theme.geometry.arc.strokeWidth
			arcY: root.alignment & Qt.AlignVCenter ? undefined : -radius + strokeWidth/2
			value: {
				if (solarMeasurements.maxPower == 0) {
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

