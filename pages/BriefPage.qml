/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "../data"

Page {
	id: root

	// Temporary code?
	property bool solarYieldPresent: true
	property bool generatorPresent: true
	property bool loadPresent: true

	property var leftGaugeTypes: []
	property var rightGaugeTypes: []

	function populateSideGauges() {
		// Determine which side gauges are to be displayed
		let leftTypes = []
		let rightTypes = []
		if (solarYieldPresent) {
			leftTypes.push('solar')
		}
		if (generatorPresent) {
			(solarYieldPresent ? rightTypes : leftTypes).push('generator')
		}
		if (loadPresent) {
			rightTypes.push('load')
		}

		leftGaugeTypes = leftTypes
		rightGaugeTypes = rightTypes
	}

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

	Loader {
		id: leftEdge
		anchors {
			top: parent.top
			topMargin: 56
			left: parent.left
			leftMargin: 40
			right: gauge.left
		}
		height: 320
		active: leftGaugeTypes.length === 1
		source: {
			switch (leftGaugeTypes[0]) {
			case 'solar': return 'SolarYieldGauge.qml'
			case 'generator': return 'GeneratorLeftGauge.qml'
			}
			return ''
		}
	}
	Loader {
		id: rightEdge
		anchors {
			top: parent.top
			topMargin: 56
			right: parent.right
			rightMargin: 40
			left: gauge.right
		}
		height: 320
		active: rightGaugeTypes.length === 1
		source: {
			switch (rightGaugeTypes[0]) {
			case 'generator': return 'GeneratorRightGauge.qml'
			case 'load': return 'LoadGauge.qml'
			}
			return ''
		}
	}
	Loader {
		id: rightUpper
		anchors {
			top: parent.top
			topMargin: 56
			right: parent.right
			rightMargin: 40
			left: gauge.right
		}
		height: 160
		active: rightGaugeTypes.length === 2
		source: {
			switch (rightGaugeTypes[0]) {
			case 'generator': return 'GeneratorMiniGauge.qml'
			}
			return ''
		}
	}
	Loader {
		id: rightLower
		anchors {
			top: parent.top
			topMargin: 216
			right: parent.right
			rightMargin: 40
			left: gauge.right
		}
		height: 160
		active: rightGaugeTypes.length === 2
		source: {
			switch (rightGaugeTypes[1]) {
			case 'load': return 'LoadMiniGauge.qml'
			}
			return ''
		}
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

	Component.onCompleted: {
		root.populateSideGauges()
		gaugeData.populateModel()
	}

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
				valueType: Gauges.FallingPercentage
			},
			'fuel': {
				textId: 'gaugeFuelText',
				icon: '/images/tank.svg',
				valueType: Gauges.FallingPercentage
			},
			'freshwater': {
				textId: 'gaugeFreshWaterText',
				icon: '/images/freshWater.svg',
				valueType: Gauges.FallingPercentage
			},
			'blackwater': {
				textId: 'gaugeBlackWaterText',
				icon: '/images/blackWater.svg',
				valueType: Gauges.FallingPercentage
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
