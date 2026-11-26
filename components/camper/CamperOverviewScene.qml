/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Item {
	id: root

	required property CamperState camperState
	required property CamperTheme theme
	required property var powerFormatter

	// Set by CamperOverviewView, which holds the translated defaults.
	property string gridShoreTitle
	property string solarTitle
	property string generatorTitle
	property string alternatorTitle
	property string dcLoadsTitle
	property string acLoadsTitle
	property string acOffTitle
	property string acCutTitle

	property real batterySoc: NaN

	readonly property bool _portrait: root.height > root.width

	// An unknown scenario shows the off-grid background, which claims no external input or driving.
	readonly property string _scenarioImageName: camperState.scenario === camperState.scenarioCharging ? "charging"
			: camperState.scenario === camperState.scenarioDriving ? "driving"
			: "offgrid"

	function _boundedX(x, width, containerWidth) {
		return Math.max(0, Math.min(containerWidth - width, x))
	}

	function _boundedY(y, height, containerHeight) {
		return Math.max(0, Math.min(containerHeight - height, y))
	}

	Rectangle {
		anchors.fill: parent
		color: root.theme.colors.background
	}

	Item {
		id: sceneLayer

		anchors {
			fill: parent
			leftMargin: root._portrait ? root.theme.portraitHorizontalMargin : root.theme.landscapeHorizontalMargin
			rightMargin: root._portrait ? root.theme.portraitHorizontalMargin : root.theme.landscapeHorizontalMargin
			topMargin: root._portrait ? root.theme.portraitVerticalMargin : root.theme.landscapeVerticalMargin
			bottomMargin: root._portrait ? root.theme.portraitVerticalMargin : root.theme.landscapeVerticalMargin
		}

		readonly property real _camperAspect: root.theme.illustrationAspectRatio
		readonly property real _camperWidth: Math.min(
				width * (root._portrait ? root.theme.portraitWidthFill : root.theme.landscapeWidthFill),
				height * _camperAspect * (root._portrait ? root.theme.portraitHeightFill : root.theme.landscapeHeightFill))
		readonly property real _camperHeight: _camperWidth / _camperAspect
		// Screen px per design px: the design drawn at the illustration's width.
		readonly property real _scale: _camperWidth / root.theme.designWidth
		readonly property real _nodeGap: root.theme.arrowGap * _scale

		// Converts a design x or y on the illustration to a scene position.
		function _sceneX(designX) {
			return camperImage.x + designX * _scale
		}
		function _sceneY(designY) {
			return camperImage.y + designY * _scale
		}

		Image {
			id: camperImage

			width: sceneLayer._camperWidth
			height: sceneLayer._camperHeight
			anchors.centerIn: parent
			source: "qrc:/images/camper/camper_%1_%2_%3.svg"
					.arg(root.camperState.solarPresent ? "solar" : "nosolar")
					.arg(root._scenarioImageName)
					.arg(root.theme.colors.dark ? "dark" : "light")
			sourceSize.width: width
			fillMode: Image.PreserveAspectFit
			smooth: true
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowSolarToBattery
			theme: root.theme
			designScale: sceneLayer._scale
			startX: solarCard.x + solarCard.width * 0.50
			startY: solarCard.y + solarCard.height + sceneLayer._nodeGap
			turnX: startX
			endX: battery.x - sceneLayer._nodeGap
			endY: battery.y + battery.height * root.theme.solarArrowBatteryY
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowBatteryToDc
			theme: root.theme
			designScale: sceneLayer._scale
			startX: battery.x + battery.width + sceneLayer._nodeGap
			startY: battery.y + battery.height * 0.50
			endX: dcCard.x - sceneLayer._nodeGap
			endY: dcCard.y + dcCard.height * root.theme.dcArrowCardY
			turnX: startX + (endX - startX) / 2
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowHubToBattery
			theme: root.theme
			designScale: sceneLayer._scale
			startX: hub.x + hub.width * 0.50
			startY: hub.y - sceneLayer._nodeGap
			endX: battery.x + battery.width * 0.50
			endY: battery.y + battery.height + sceneLayer._nodeGap
			turnY: startY + (endY - startY) / 2
			horizontalFirst: false
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowBatteryToHub
			theme: root.theme
			designScale: sceneLayer._scale
			startX: battery.x + battery.width * 0.50
			startY: battery.y + battery.height + sceneLayer._nodeGap
			endX: hub.x + hub.width * 0.50
			endY: hub.y - sceneLayer._nodeGap
			turnY: startY + (endY - startY) / 2
			horizontalFirst: false
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowHubToAc
			theme: root.theme
			designScale: sceneLayer._scale
			startX: hub.x + hub.width + sceneLayer._nodeGap
			startY: hub.y + hub.height * 0.5
			endX: acCard.x - sceneLayer._nodeGap
			endY: acCard.y + acCard.height * 0.5
			turnX: startX + (endX - startX) / 2
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowGridToHub
			theme: root.theme
			designScale: sceneLayer._scale
			startX: gridShoreCard.x + gridShoreCard.width + sceneLayer._nodeGap
			startY: gridShoreCard.y + gridShoreCard.height * 0.5
			endX: hub.x - sceneLayer._nodeGap
			endY: hub.y + hub.height * 0.5
			turnX: startX + (endX - startX)/2
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowGeneratorToHub
			theme: root.theme
			designScale: sceneLayer._scale
			startX: hub.x + hub.width * 0.5
			startY: generatorCard.y - sceneLayer._nodeGap
			endX: hub.x + hub.width * 0.5
			endY: hub.y + hub.height + sceneLayer._nodeGap
			horizontalFirst: false
		}

		CamperFlowArrow {
			anchors.fill: parent
			visible: root.camperState.flowAlternatorToBattery
			theme: root.theme
			designScale: sceneLayer._scale
			cornerRadius: root.theme.arrowLongCornerRadius * sceneLayer._scale
			startX: alternatorCard.x - sceneLayer._nodeGap
			startY: alternatorCard.y + alternatorCard.height * 0.5
			endX: battery.x + battery.width * root.theme.alternatorArrowBatteryX
			endY: battery.y + battery.height + sceneLayer._nodeGap
			turnY: startY
		}

		CamperDomainCard {
			id: solarCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.solarCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.solarCardPosition.y), height, sceneLayer.height)
			iconSource: "qrc:/images/solaryield.svg"
			title: root.solarTitle
			value: root.camperState.solarPower
			active: root.camperState.solarActive
			visible: root.camperState.solarPresent
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDomainCard {
			id: gridShoreCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.gridShoreCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.gridShoreCardPosition.y), height, sceneLayer.height)
			iconSource: root.camperState.gridInput ? "qrc:/images/grid.svg" : "qrc:/images/shore.svg"
			title: root.gridShoreTitle
			value: root.camperState.gridShorePower
			active: root.camperState.gridShoreActive
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDomainCard {
			id: generatorCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.generatorCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.generatorCardPosition.y), height, sceneLayer.height)
			iconSource: "qrc:/images/generator.svg"
			title: root.generatorTitle
			value: root.camperState.generatorPower
			active: root.camperState.generatorActive
			visible: root.camperState.generatorPresent
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDomainCard {
			id: dcCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.dcCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.dcCardPosition.y), height, sceneLayer.height)
			iconSource: "qrc:/images/dcloads.svg"
			title: root.dcLoadsTitle
			value: root.camperState.dcLoadsPower
			active: root.camperState.dcLoadsActive
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDomainCard {
			id: acCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.acCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.acCardPosition.y), height, sceneLayer.height)
			iconSource: "qrc:/images/acloads.svg"
			title: root.camperState.acOutputCut ? root.acCutTitle
				: root.camperState.inverterChargerOff ? root.acOffTitle
				: root.acLoadsTitle
			value: root.camperState.acLoadsPower
			active: root.camperState.acLoadsActive
			alarm: root.camperState.acOutputCut
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDomainCard {
			id: alternatorCard

			x: root._boundedX(sceneLayer._sceneX(root.theme.alternatorCardPosition.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.alternatorCardPosition.y), height, sceneLayer.height)
			iconSource: "qrc:/images/alternator.svg"
			title: root.alternatorTitle
			value: root.camperState.alternatorPower
			active: root.camperState.alternatorActive
			theme: root.theme
			designScale: sceneLayer._scale
			powerFormatter: root.powerFormatter
		}

		CamperDevice {
			id: hub
			x: root._boundedX(sceneLayer._sceneX(root.theme.hubCenter.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.hubCenter.y) - height / 2, height, sceneLayer.height)
			active: root.camperState.hubActive
			alarm: root.camperState.acOutputCut
			theme: root.theme
			designScale: sceneLayer._scale
		}

		CamperBattery {
			id: battery
			value: root.batterySoc
			charging: root.camperState.batteryCharging
			discharging: root.camperState.batteryDischarging
			alarm: root.camperState.lowBatteryAlarm
			x: root._boundedX(sceneLayer._sceneX(root.theme.batteryCenter.x) - width / 2, width, sceneLayer.width)
			y: root._boundedY(sceneLayer._sceneY(root.theme.batteryCenter.y) - height / 2, height, sceneLayer.height)
			theme: root.theme
			designScale: sceneLayer._scale
		}
	}
}
