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

	Loader {
		id: mainGauge

		property bool multipleValues: gaugeData.model.count > 1

		anchors {
			top: parent.top
			topMargin: Theme.geometry.mainGauge.topMargin
		}
		width: Theme.geometry.mainGauge.size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: gaugeData.model.count === 0 ? null : (multipleValues ? multiGauge : singleGauge)
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: gaugeData.model
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			model: gaugeData.model.get(0)
		}
	}

	property real sideOpacity: 1

	Loader {
		id: leftEdge
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		height: parent.height
		opacity: root.sideOpacity
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
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		height: parent.height
		opacity: root.sideOpacity
		active: rightGaugeTypes.length === 1
		source: {
			switch (rightGaugeTypes[0]) {
			case 'generator': return 'GeneratorRightGauge.qml'
			case 'load': return 'LoadGauge.qml'
			}
			return ''
		}
	}

	/*	Example of how to use 'ValueDisplay'
	Column {
		spacing: 20
		anchors {
			top: parent.top
			topMargin: 164
			right: parent.right
			rightMargin: 68
		}
		ValueDisplay {
			title.text: "Generator"
			physicalQuantity: Units.Power
			value: 874
			icon.source: "qrc:/images/generator.svg"
		}
		ValueDisplay {
			title.text: "Loads"
			physicalQuantity: Units.Power
			value: 6251.1234
			icon.source: "qrc:/images/consumption.svg"
		}
	}
	ValueDisplay {
		anchors {
			top: parent.top
			topMargin: 208
			left: parent.left
			leftMargin: 88
		}
		rightAligned: false
		title.text: "Solar yield"
		physicalQuantity: Units.Power
		value: 428
		precision: 2
		icon.source: "qrc:/images/solaryield.svg"
	}
	*/
	Loader {
		id: rightUpper
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		height: parent.height/2
		opacity: root.sideOpacity
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
			top: rightUpper.bottom
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		height: parent.height/2
		opacity: root.sideOpacity
		active: rightGaugeTypes.length === 2
		source: {
			switch (rightGaugeTypes[1]) {
			case 'load': return 'LoadMiniGauge.qml'
			}
			return ''
		}
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.sidePanel.topMargin
		}
		width: Theme.geometry.briefPage.sidePanel.width

		// hidden by default.
		x: root.width
		opacity: 0.0
	}

	Component.onCompleted: {
		root.populateSideGauges()
	}

	Item {
		id: gaugeData

		property ListModel model: ListModel {
			Component.onCompleted: {
				insert(0, Object.assign({}, gaugeData._gaugeTypeProperties['battery'],
						{ gaugeType: 'battery', value: 0.0 }))
				batteryValueBinding.target = gaugeData.model.get(0)
			}
		}

		property var _gaugeConfig: [
			'fuel',
			'battery',
			'freshwater',
			'blackwater'
		]

		property var _gaugeTypeProperties: ({
			'fuel': {
				textId: 'gaugeFuelText',
				icon: '/images/tank.svg',
				valueType: Gauges.FallingPercentage
			},
			'battery': {
				textId: 'gaugeBatteryText',
				icon: '/images/battery.svg',
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
				valueType: Gauges.RisingPercentage
			}
		})

		property int _batteryIndex: _gaugeIndex("battery")

		function _gaugeIndex(type) {
			for (let i = 0; i < gaugeData.model.count; ++i) {
				if (gaugeData.model.get(i).gaugeType == type) {
					return i
				}
			}
			return -1
		}

		function _gaugeOrder(type) {
			return tanks && tanks.model ? _gaugeConfig.indexOf(type) : -1
		}

		function _gaugeData(index) {
			return index >= 0 && index < model.count ? model.get(index) : null
		}

		Binding {
			id: batteryValueBinding
			property: 'value'
			value: battery ? Math.round(battery.stateOfCharge) : null
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

				onGaugeTypeChanged: {
					let orderedTypeIndex = gaugeData._gaugeOrder(gaugeType)
					let insertionIndex = -1
					for (let i = 0; i < gaugeData.model.count; ++i) {
						let currentGaugeType = gaugeData.model.get(i).gaugeType
						if (orderedTypeIndex < gaugeData._gaugeOrder(currentGaugeType)) {
							insertionIndex = i
							break
						}
					}
					if (insertionIndex < 0) {
						insertionIndex = gaugeData.model.count
					}
					if (modelIndex >= 0) {
						gaugeData.model.move(modelIndex, insertionIndex, 1)
					} else {
						gaugeData.model.insert(insertionIndex, Object.assign({},
								gaugeData._gaugeTypeProperties[gaugeType],
								{ gaugeType: gaugeType, value: 0.0 }))
					}
					modelIndex = insertionIndex
				}

				property int modelIndex: -1

				property var updater: Binding {
					target: modelIndex >= 0 ? gaugeData._gaugeData(modelIndex) : null
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

	state: PageManager.sidePanelActive ? 'panelOpen' : ''
	states: State {
		name: 'panelOpen'
		PropertyChanges {
			target: sidePanel
			x: root.width - sidePanel.width - Theme.geometry.page.grid.horizontalMargin
			opacity: 1
		}
		PropertyChanges {
			target: root
			sideOpacity: 0
		}
	}

	transitions: [
		Transition {
			to: "panelOpen"
			from: ""
			SequentialAnimation {
				NumberAnimation {
					target: root
					property: 'sideOpacity'
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation.briefPage.sidePanel.slide.duration
					easing.type: Easing.InQuad
				}
			}
		},
		Transition {
			to: ""
			from: "panelOpen"
			SequentialAnimation {
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation.briefPage.sidePanel.slide.duration
					easing.type: Easing.InQuad
				}
				NumberAnimation {
					target: root
					property: 'sideOpacity'
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
			}
		}
	]
}
