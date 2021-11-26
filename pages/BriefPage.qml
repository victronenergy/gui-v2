/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

Page {
	id: root

	CircularMultiGauge {
		id: gauge

		x: sidePanel.x/2 - width/2
		anchors {
			top: parent.top
			topMargin: 56
		}
		width: 315
		height: 320
		model: gaugeModel
	}

	Button {
		id: button

		anchors {
			top: parent.top
			topMargin: 15
			right: parent.right
			rightMargin: 27
		}

		icon.source: sidePanel.state === '' ? "qrc:/images/panel-toggle.svg" : "qrc:/images/panel-toggled.svg"

		onClicked: {
			sidePanel.state = (sidePanel.state == '') ? 'hidden' : ''
		}
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors.top: button.bottom
		x: root.width
		opacity: 0
		width: 240
		height: 367
		states: State {
			name: 'hidden'
			PropertyChanges {
				target: sidePanel
				x: root.width - sidePanel.width - Theme.horizontalPageMargin
				opacity: 1
			}
		}

		transitions: Transition {
			NumberAnimation {
				properties: 'x,opacity'; duration: 400
				easing.type: Easing.InQuad
			}
		}
	}

	ListModel {
		id: gaugeModel

		ListElement { value: 10; text: 'gaugeFuelText'; icon: '/images/tank.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 60; text: 'gaugeBatteryText'; icon: '/images/battery.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 80; text: 'gaugeFreshWaterText'; icon: '/images/freshWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 20; text: 'gaugeBlackWaterText'; icon: '/images/blackWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
	}

	Binding {
		when: battery
		target: gaugeModel.get(1)
		property: 'value'
		value: battery.stateOfCharge
	}

	Instantiator {
		model: tanks ? tanks.model : null
		delegate: QtObject {
			property var modelIndex: {
				if (tank.type === Tanks.Fuel) {
					return 0
				} else if (tank.type === Tanks.FreshWater) {
					return 2
				} else if (tank.type === Tanks.BlackWater) {
					return 3
				}
				return undefined
			}

			property var _binding: Binding {
				when: modelIndex !== undefined
				target: gaugeModel.get(modelIndex)
				property: 'value'
				value: tank.level
			}
		}
	}

	property var _gaugeStrings: [
		//% "Fuel"
		QT_TRID_NOOP('gaugeFuelText'),
		//% "Battery"
		QT_TRID_NOOP('gaugeBatteryText'),
		//% "Fresh water"
		QT_TRID_NOOP('gaugeFreshWaterText'),
		//% "Black water"
		QT_TRID_NOOP('gaugeBlackWaterText')
	]
}
