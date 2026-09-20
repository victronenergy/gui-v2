/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Item {
	id: root

	readonly property int scenarioCharging: 0
	readonly property int scenarioDriving: 1
	readonly property int scenarioParking: 2
	readonly property int scenarioOffGrid: 3

	property int scenario: scenarioOffGrid
	property string scenarioText: "Stationary"
	property string gridShoreTitle: "Grid/Shore"
	property bool gridShoreIsShore: false
	property string solarTitle: "PV"
	property string generatorTitle: "Generator"
	property string batteryTitle: "Battery"
	property string alternatorTitle: "Alternator"
	property string dcLoadsTitle: "DC"
	property string acLoadsTitle: "AC"

	property real gridShorePower: NaN
	property real generatorPower: NaN
	property real solarPower: NaN
	property real batteryPower: NaN
	property real batterySoc: NaN
	property real alternatorPower: NaN
	property real dcLoadsPower: NaN
	property real acLoadsPower: NaN

	property int colorScheme: 0
	readonly property color _pageBackground: colorScheme === 0 ? "#E9ECEF" : "#0A0C0E"
	readonly property color _textPrimary: colorScheme === 0 ? "#343A40" : "#DEE2E6"
	readonly property color _textSecondary: colorScheme === 0 ? "#495057" : "#ADB5BD"
	readonly property color _flowColor: colorScheme === 0 ? "#005FBE" : "#66B0FF"
	readonly property bool _portrait: root.height > root.width

	readonly property bool _gridShoreActive: _isActivePower(gridShorePower)
	readonly property bool _generatorActive: _isActivePower(generatorPower)
	readonly property bool _solarActive: _isActivePower(solarPower)
	readonly property bool _alternatorActive: _isActivePower(alternatorPower)
	readonly property bool _dcLoadsActive: _isActivePower(dcLoadsPower)
	readonly property bool _acLoadsActive: _isActivePower(acLoadsPower)
	readonly property bool _batteryFlowActive: _isActivePower(batteryPower, 60)
	readonly property bool _batterySocWarning: isFinite(batterySoc) && batterySoc <= 50
	readonly property bool _batterySocAlarm: isFinite(batterySoc) && batterySoc <= 20
	readonly property bool _acCut: _batterySocAlarm && !_gridShoreActive && !_generatorActive
	readonly property bool _passThroughMode: _gridShoreActive
			&& !_solarActive
			&& !_generatorActive
			&& !_alternatorActive
			&& !_batteryFlowActive
	readonly property bool _hubVisible: _solarActive
			|| _alternatorActive
			|| _gridShoreActive
			|| _generatorActive
			|| _batteryFlowActive
			|| _acLoadsActive
			|| _dcLoadsActive
	readonly property bool _flowSolarToDc: _solarActive && _dcLoadsActive
	readonly property bool _flowSolarToSoc: _solarActive
	readonly property bool _dcCardActive: _dcLoadsActive
			|| _solarActive
			|| _gridShoreActive
			|| _alternatorActive
			|| _generatorActive
			|| _batteryFlowActive
	readonly property bool _flowHubToDc: _dcCardActive && _hubVisible
	readonly property bool _flowSocToHub: isFinite(batterySoc)
	readonly property bool _flowHubToAc: _acLoadsActive && !_acCut && !_passThroughMode
	readonly property bool _flowGridToHub: _gridShoreActive && !_passThroughMode
	readonly property bool _flowGeneratorToHub: _generatorActive && !_passThroughMode
	readonly property bool _flowAlternatorToHub: _alternatorActive
	readonly property bool _flowInputToAc: (_gridShoreActive || _generatorActive) && _acLoadsActive
	readonly property string _socText: !isFinite(batterySoc) ? "--%"
			: batteryPower < -80 ? "+" + Math.round(Math.max(0, Math.min(100, batterySoc))).toString() + "%"
			: Math.round(Math.max(0, Math.min(100, batterySoc))).toString() + "%"

	function _isActivePower(value, threshold) {
		const effectiveThreshold = isFinite(threshold) ? threshold
				: 30
		return isFinite(value) && Math.abs(value) >= effectiveThreshold
	}

	function _boundedX(x, width, containerWidth) {
		return Math.max(0, Math.min(containerWidth - width, x))
	}

	function _boundedY(y, height, containerHeight) {
		return Math.max(0, Math.min(containerHeight - height, y))
	}

	Rectangle {
		anchors.fill: parent
		color: root._pageBackground
	}
	Rectangle {
		anchors.fill: parent
		color:"transparent"
		border.width: 1
		border.color: "red"
	}
	Item {
		id: sceneLayer

		anchors {
			fill: parent
			leftMargin: root._portrait ? 10
				: 26
			rightMargin: root._portrait ? 10
				: 26
			topMargin: root._portrait ? 12
				: 16
			bottomMargin: root._portrait ? 12
				: 16
		}

		readonly property real _camperAspect: 335 / 149
		readonly property real _camperWidth: Math.min(
				width * (root._portrait ? 0.98 : 0.92),
				height * _camperAspect * (root._portrait ? 0.88 : 0.94))
		readonly property real _camperHeight: _camperWidth / _camperAspect
		readonly property real _cardWidth: Math.max(122, Math.min(170, _camperWidth * 0.175))
		readonly property real _cardExtraWidth: Math.max(122, Math.min(170, _camperWidth * 0.275))
		readonly property real _cardHeight: Math.round(_cardWidth * 0.62)
		readonly property real _hubSize: Math.max(34, Math.round(_cardHeight * 0.75))
		readonly property real _batteryWidth: Math.max(78, Math.round(_cardWidth * 0.78))
		readonly property real _batteryHeight: Math.max(40, Math.round(_cardHeight * 0.52))
		readonly property real _flowStrokeWidth: root._portrait ? 2.0
				: 2.6
		readonly property real _nodeGap: Math.max(8, Math.round(_cardHeight * 0.14))
		readonly property real _linkInset: Math.max(8, Math.round(_cardWidth * 0.07))

		Image {
			id: camperImage

			readonly property var _backgroundImage: root.colorScheme === 0
					? [ "qrc:/images/camper/camper_charging_light.svg", "qrc:/images/camper/camper_driving_light.svg",
						"qrc:/images/camper/camper_parking_light.svg", "qrc:/images/camper/camper_offgrid_light.svg" ]
					:  [ "qrc:/images/camper/camper_charging_dark.svg", "qrc:/images/camper/camper_driving_dark.svg",
						"qrc:/images/camper/camper_parking_dark.svg", "qrc:/images/camper/camper_offgrid_dark.svg" ]

			z: 0
			width: sceneLayer._camperWidth
			height: sceneLayer._camperHeight
			anchors.centerIn: parent
			source: root.scenario === root.scenarioCharging ? _backgroundImage[0]
				: root.scenario === root.scenarioDriving ? _backgroundImage[1]
				: root.scenario === root.scenarioParking ? _backgroundImage[2]
				: _backgroundImage[3]
			fillMode: Image.PreserveAspectFit
			smooth: true

			Rectangle {
				x: 0
				y: 0
				width: parent.width * .65
				height: parent.height * .097
				color: root._pageBackground
				visible: false // hide solar panel
			}
		}

		CamperDevice {
			id: hub
			z: 4
			width: sceneLayer._hubSize
			height: sceneLayer._hubSize
			x: root._boundedX(camperImage.x + camperImage.width * 0.36 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.60 - height * 0.50, height, sceneLayer.height)
			colorScheme: root.colorScheme
		}

		CamperBattery {
			id: battery
			z: 5
			width: sceneLayer._batteryWidth
			height: sceneLayer._batteryHeight
			x: root._boundedX(camperImage.x + camperImage.width * 0.39 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.28 - height * 0.50, height, sceneLayer.height)
			colorScheme: root.colorScheme
		}


		CamperDomainCard {
			id: solarCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.21 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y - height * 0.72, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/solaryield.svg"
			title: root.solarTitle
			value: root.solarPower
			active: root._solarActive
			colorScheme: root.colorScheme
		}

		CamperDomainCard {
			id: gridShoreCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.03 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.40, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: root.gridShoreIsShore ? "qrc:/images/shore.svg"
				: "qrc:/images/grid.svg"
			title: root.gridShoreTitle
			value: root.gridShorePower
			active: root._gridShoreActive
			colorScheme: root.colorScheme
		}

		CamperDomainCard {
			id: generatorCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.22 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.93, height, sceneLayer.height)
			width: sceneLayer._cardExtraWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/generator.svg"
			title: root.generatorTitle
			value: root.generatorPower
			active: root._generatorActive
			colorScheme: root.colorScheme
		}

		CamperDomainCard {
			id: dcCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.62 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.02, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/dcloads.svg"
			title: root.dcLoadsTitle
			value: root.dcLoadsPower
			active: root._dcCardActive
			colorScheme: root.colorScheme
		}

		CamperDomainCard {
			id: acCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.62 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.70, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/acloads.svg"
			title: root.acLoadsTitle
			value: root.acLoadsPower
			active: root._acLoadsActive
			alarm: root._acCut
			colorScheme: root.colorScheme
		}

		CamperDomainCard {
			id: alternatorCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.90 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.4, height, sceneLayer.height)
			width: sceneLayer._cardExtraWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/alternator.svg"
			title: root.alternatorTitle
			value: root.alternatorPower
			active: root._alternatorActive
			colorScheme: root.colorScheme
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowSolarToSoc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: solarCard.x + solarCard.width * 0.50
			startY: solarCard.y + solarCard.height + sceneLayer._nodeGap
			turnX: startX
			endX: battery.x - sceneLayer._nodeGap
			endY: battery.y + battery.height * 0.56
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowHubToDc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: battery.x + battery.width + sceneLayer._nodeGap
			startY: battery.y + battery.height * 0.50
			endX: dcCard.x - sceneLayer._nodeGap
			endY: dcCard.y + dcCard.height * 0.52
			turnX: startX + (endX - startX) / 2
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowHubToBattery
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: hub.x + hub.width * 0.50
			startY: hub.y - sceneLayer._nodeGap
			endX: battery.x + battery.width * 0.50
			endY: battery.y + battery.height + sceneLayer._nodeGap
			turnY: startY + (endY - startY) / 2
			horizontalFirst: false
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowHubToAc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: hub.x + hub.width + sceneLayer._nodeGap
			startY: hub.y + hub.height * 0.5
			endX: acCard.x - sceneLayer._nodeGap
			endY: acCard.y + acCard.height * 0.5
			turnX: startX + (endX - startX) / 2
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowGridToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: gridShoreCard.x + gridShoreCard.width + sceneLayer._nodeGap
			startY: gridShoreCard.y + gridShoreCard.height * 0.5
			endX: hub.x - sceneLayer._nodeGap
			endY: hub.y + hub.height * 0.5
			turnX: startX + (endX - startX)/2
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowGeneratorToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: generatorCard.x + generatorCard.width * 0.5
			startY: generatorCard.y - sceneLayer._nodeGap
			endX: hub.x + hub.width * 0.5
			endY: hub.y + hub.height + sceneLayer._nodeGap
			turnY: startY - (startY - endY)/2
			horizontalFirst: false
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowAlternatorToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			cornerRadius: 24
			startX: alternatorCard.x - sceneLayer._nodeGap
			startY: alternatorCard.y + alternatorCard.height * 0.5
			endX: battery.x + battery.width * 0.80
			endY: battery.y + battery.height + sceneLayer._nodeGap
			turnY: startY
		}
	}
}
