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
		model: gaugeData.model
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

	property var gaugeConfig: [
		'fuel',
		'battery',
		'freshwater',
		'blackwater'
	]

	onGaugeConfigChanged: gaugeData.populateModel()
	Component.onCompleted: gaugeData.populateModel()

	Item {
		id: gaugeData

		property ListModel model: ListModel {}

		function populateModel() {
			_populated = false

			model.clear()
			for (let i = 0; i < gaugeConfig.length; ++i) {
				const type = gaugeConfig[i]
				if (type in _gaugeTypeProperties) {
					const props = _gaugeTypeProperties[type]
					model.append(Object.assign({}, props, { value: Math.floor(Math.random() * 100) * 1.0 }))
				}
			}

			_populated = true
		}

		property bool _populated: false

		property var _gaugeTypeProperties: ({
			'battery': {
				textId: 'gaugeBatteryText',
				icon: '/images/battery.svg',
				valueType: CircularMultiGauge.FallingPercentage
			},
			'fuel': {
				textId: 'gaugeFuelText',
				icon: '/images/tank.svg',
				valueType: CircularMultiGauge.FallingPercentage
			},
			'freshwater': {
				textId: 'gaugeFreshWaterText',
				icon: '/images/freshWater.svg',
				valueType: CircularMultiGauge.FallingPercentage
			},
			'blackwater': {
				textId: 'gaugeBlackWaterText',
				icon: '/images/blackWater.svg',
				valueType: CircularMultiGauge.FallingPercentage
			}
		})

		property int _batteryIndex: _gaugeIndex("battery")

		function _gaugeIndex(type) {
			return _populated ? gaugeConfig.indexOf(type) : -1
		}

		function _gaugeData(index) {
			return index >= 0 && index < model.count ? model.get(index) : null
		}

		Binding {
			target: battery ? gaugeData._gaugeData(gaugeData._batteryIndex) : null
			property: 'value'
			value: battery.stateOfCharge
		}

		Instantiator {
			model: tanks ? tanks.model : null
			delegate: QtObject {
				property string gaugeType: {
					switch (tank.type) {
					case Tanks.Fuel: return 'fuel'
					case Tanks.FreshWater: return 'freshwater'
					case Tanks.BlackWater: return 'blackwater'
					}
					return ''
				}

				property int modelIndex: gaugeData._gaugeIndex(gaugeType)

				property var updater: Binding {
					target: gaugeData._gaugeData(modelIndex)
					property: 'value'
					value: tank.level
				}
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
