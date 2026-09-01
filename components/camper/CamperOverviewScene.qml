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
	property string solarTitle: "Solar PV"
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

	readonly property color _pageBackground: "#ECEFF3"
	readonly property color _scenarioTextColor: "#A0A7B0"
	readonly property color _hubColorActive: "#2F70D8"
	readonly property color _hubColorInactive: "#A2AAB5"
	readonly property color _hubColorAlarm: "#D04E22"
	readonly property color _flowColor: "#2F70D8"
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
	readonly property string _acTitle: "AC out"

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

	Item {
		id: sceneLayer

		anchors {
			fill: parent
			leftMargin: root._portrait ? 10
				: 26
			rightMargin: root._portrait ? 10
				: 26
			topMargin: root._portrait ? 18
				: 20
			bottomMargin: root._portrait ? 10
				: 16
		}

		readonly property real _camperAspect: 335 / 149
		readonly property real _camperWidth: Math.min(
				width * (root._portrait ? 0.92 : 0.78),
				height * _camperAspect * (root._portrait ? 0.68 : 0.84))
		readonly property real _camperHeight: _camperWidth / _camperAspect
		readonly property real _cardWidth: Math.max(122, Math.min(170, _camperWidth * 0.175))
		readonly property real _cardHeight: Math.round(_cardWidth * 0.72)
		readonly property real _hubSize: Math.max(34, Math.round(_cardHeight * 0.54))
		readonly property real _socWidth: Math.max(78, Math.round(_cardWidth * 0.74))
		readonly property real _socHeight: Math.max(40, Math.round(_cardHeight * 0.48))
		readonly property real _flowStrokeWidth: root._portrait ? 2.0
				: 2.6
		readonly property real _nodeGap: Math.max(8, Math.round(_cardHeight * 0.14))
		readonly property real _linkInset: Math.max(8, Math.round(_cardWidth * 0.07))

		Image {
			id: camperImage

			z: 0
			width: sceneLayer._camperWidth
			height: sceneLayer._camperHeight
			anchors.horizontalCenter: parent.horizontalCenter
			y: Math.max(34, parent.height * (root._portrait ? 0.23 : 0.20))
			source: root.scenario === root.scenarioCharging ? "qrc:/images/camper/camper_charging.svg"
				: root.scenario === root.scenarioDriving ? "qrc:/images/camper/camper_driving.svg"
				: root.scenario === root.scenarioParking ? "qrc:/images/camper/camper_parking.svg"
				: "qrc:/images/camper/camper_offgrid.svg"
			fillMode: Image.PreserveAspectFit
			smooth: true
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowSolarToDc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: solarCard.x + solarCard.width
			startY: solarCard.y + solarCard.height * 0.24
			endX: dcCard.x - sceneLayer._linkInset * 0.15
			endY: dcCard.y + dcCard.height * 0.54
			turnX: dcCard.x - sceneLayer._nodeGap
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowSolarToSoc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: solarCard.x + solarCard.width * 0.50
			startY: solarCard.y + solarCard.height
			endX: socBadge.x - sceneLayer._linkInset * 0.1
			endY: socBadge.y + socBadge.height * 0.56
			turnY: solarCard.y + solarCard.height + sceneLayer._nodeGap * 0.50
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowHubToDc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: batteryHub.x + batteryHub.width
			startY: batteryHub.y + batteryHub.height * 0.36
			endX: dcCard.x - sceneLayer._linkInset * 0.15
			endY: dcCard.y + dcCard.height * 0.52
			turnX: dcCard.x - sceneLayer._nodeGap
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowSocToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: socBadge.x + socBadge.width * 0.50
			startY: socBadge.y + socBadge.height
			endX: batteryHub.x + batteryHub.width * 0.50
			endY: batteryHub.y - 1
			horizontalFirst: false
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowHubToAc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: batteryHub.x + batteryHub.width
			startY: batteryHub.y + batteryHub.height * 0.52
			endX: acCard.x - sceneLayer._linkInset * 0.15
			endY: acCard.y + acCard.height * 0.56
			turnX: acCard.x - sceneLayer._nodeGap
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowGridToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: gridShoreCard.x + gridShoreCard.width
			startY: gridShoreCard.y + gridShoreCard.height * 0.54
			endX: batteryHub.x - 1
			endY: batteryHub.y + batteryHub.height * 0.46
			turnY: batteryHub.y + batteryHub.height * 0.46
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowGeneratorToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: generatorCard.x + generatorCard.width * 0.58
			startY: generatorCard.y
			endX: batteryHub.x + batteryHub.width * 0.42
			endY: batteryHub.y + batteryHub.height
			horizontalFirst: false
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowAlternatorToHub
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: alternatorCard.x
			startY: alternatorCard.y + alternatorCard.height * 0.54
			endX: batteryHub.x + batteryHub.width
			endY: batteryHub.y + batteryHub.height * 0.54
			turnY: alternatorCard.y + alternatorCard.height * 0.54
		}

		CamperFlowArrow {
			z: 2
			anchors.fill: parent
			visible: root._flowInputToAc
			strokeColor: root._flowColor
			strokeWidth: sceneLayer._flowStrokeWidth
			startX: root._gridShoreActive ? gridShoreCard.x + gridShoreCard.width
				: generatorCard.x + generatorCard.width
			startY: root._gridShoreActive ? gridShoreCard.y + gridShoreCard.height * 0.54
				: generatorCard.y + generatorCard.height * 0.46
			endX: acCard.x - sceneLayer._linkInset * 0.15
			endY: acCard.y + acCard.height * 0.56
			turnY: acCard.y + acCard.height * 0.56
		}

		CamperDomainCard {
			id: solarCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.11 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y - height * 0.72, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/solaryield.svg"
			title: "PV"
			value: root.solarPower
			active: root._solarActive
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
		}

		CamperDomainCard {
			id: generatorCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.22 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.93, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/generator.svg"
			title: root.generatorTitle
			value: root.generatorPower
			active: root._generatorActive
		}

		CamperDomainCard {
			id: dcCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.60 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.06, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/dcloads.svg"
			title: "DC"
			value: root.dcLoadsPower
			active: root._dcCardActive
		}

		CamperDomainCard {
			id: acCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.60 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.74, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/acloads.svg"
			title: root._acTitle
			value: root.acLoadsPower
			active: root._acLoadsActive
			alarm: root._acCut
			warning: false
		}

		CamperDomainCard {
			id: alternatorCard

			z: 3
			x: root._boundedX(camperImage.x + camperImage.width * 0.90 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.46, height, sceneLayer.height)
			width: sceneLayer._cardWidth
			height: sceneLayer._cardHeight
			iconSource: "qrc:/images/alternator.svg"
			title: root.alternatorTitle
			value: root.alternatorPower
			active: root._alternatorActive
		}

		Rectangle {
			id: batteryHub

			z: 4
			width: sceneLayer._hubSize
			height: sceneLayer._hubSize
			x: root._boundedX(camperImage.x + camperImage.width * 0.33 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(camperImage.y + camperImage.height * 0.65 - height * 0.50, height, sceneLayer.height)
			radius: Math.max(7, Math.round(width * 0.22))
			color: root._batterySocAlarm ? root._hubColorAlarm
				: root._hubVisible ? root._hubColorActive
				: root._hubColorInactive

			Image {
				anchors.centerIn: parent
				width: Math.max(16, Math.round(parent.width * 0.54))
				height: width
				source: "qrc:/images/inverter_charger.svg"
				fillMode: Image.PreserveAspectFit
				smooth: true
			}
		}

		Rectangle {
			id: socBadge

			readonly property real batteryNubWidth: Math.max(4, Math.round(height * 0.08))

			z: 5
			width: sceneLayer._socWidth
			height: sceneLayer._socHeight
			x: root._boundedX(batteryHub.x + batteryHub.width * 0.50 - width * 0.50, width, sceneLayer.width)
			y: root._boundedY(batteryHub.y - height - sceneLayer._nodeGap, height, sceneLayer.height)
			radius: Math.round(height * 0.20)
			color: root._batterySocAlarm ? "#FFEDE5"
				: root._batterySocWarning ? "#FFF6E8"
				: "#DDF6E6"
			border.width: 1
			border.color: root._batterySocAlarm ? "#E86A3D"
				: root._batterySocWarning ? "#E99B44"
				: "#4C9C61"

			Rectangle {
				width: socBadge.batteryNubWidth
				height: Math.round(parent.height * 0.32)
				x: parent.width + 1
				y: Math.round((parent.height - height) * 0.50)
				radius: 1
				color: socBadge.border.color
			}

			Canvas {
				id: socBolt
				property color boltColor: root._batterySocAlarm ? "#B14824"
						: root._batterySocWarning ? "#8F5A20"
						: "#2C7440"

				anchors {
					left: parent.left
					leftMargin: Math.round(parent.height * 0.24)
					verticalCenter: parent.verticalCenter
				}
				width: Math.max(9, Math.round(parent.height * 0.22))
				height: Math.max(14, Math.round(parent.height * 0.42))
				onPaint: {
					const ctx = getContext("2d")
					ctx.clearRect(0, 0, width, height)
					ctx.fillStyle = boltColor
					ctx.beginPath()
					ctx.moveTo(width * 0.58, 0)
					ctx.lineTo(width * 0.06, height * 0.52)
					ctx.lineTo(width * 0.42, height * 0.52)
					ctx.lineTo(width * 0.30, height)
					ctx.lineTo(width * 0.94, height * 0.40)
					ctx.lineTo(width * 0.54, height * 0.40)
					ctx.closePath()
					ctx.fill()
				}
				onBoltColorChanged: requestPaint()
				onWidthChanged: requestPaint()
				onHeightChanged: requestPaint()
				Component.onCompleted: requestPaint()
			}

			Text {
				anchors {
					left: socBolt.right
					leftMargin: Math.round(parent.height * 0.12)
					verticalCenter: parent.verticalCenter
				}
				text: root._socText
				color: root._batterySocAlarm ? "#B14824"
					: root._batterySocWarning ? "#8F5A20"
					: "#2C7440"
				font.pixelSize: Math.max(16, Math.round(parent.height * 0.56))
				font.bold: true
			}
		}
	}
}
