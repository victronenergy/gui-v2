/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls

ApplicationWindow {
	id: root

	width: 1280
	height: 720
	visible: true
	color: "#121417"
	title: "Camper View (%1)".arg(camperDataProvider.sourceName)

	readonly property var _data: camperDataProvider.data
	readonly property string _activeInputSource: (_data.activeInputSource ?? "none").toString().toLowerCase()
	readonly property bool _gridOrShoreActive: _activeInputSource === "grid" || _activeInputSource === "shore"
	readonly property bool _generatorActive: _activeInputSource === "generator"
	readonly property real _movingAlternatorThreshold: 50
	readonly property real _alternatorPower: _toFiniteNumber(_data.alternatorPower)
	readonly property int _scenario: _gridOrShoreActive ? camperView.scenarioCharging
			: _alternatorPower > _movingAlternatorThreshold ? camperView.scenarioDriving
			: _generatorActive ? camperView.scenarioParking
			: camperView.scenarioOffGrid
	readonly property string _scenarioText: _scenario === camperView.scenarioCharging ? "Charging"
			: _scenario === camperView.scenarioDriving ? "Driving"
			: _scenario === camperView.scenarioParking ? "Parking"
			: "Off-grid"
	readonly property string _gridShoreTitle: _activeInputSource === "shore" ? "Shore"
			: _activeInputSource === "grid" ? "Grid"
			: "Grid/Shore"

	function _toFiniteNumber(value) {
		const parsed = Number(value)
		return isFinite(parsed) ? parsed
				: NaN
	}

	Rectangle {
		id: toolbar

		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		height: 48
		color: "#1C232C"

		Row {
			anchors {
				fill: parent
				leftMargin: 12
				rightMargin: 12
			}
			spacing: 12

			Label {
				anchors.verticalCenter: parent.verticalCenter
				color: "#F3F5F7"
				text: camperDataProvider.hostDataAvailable ? "Host data active (window.camperViewData)"
					: "No host data detected; displaying mock data"
			}

			Button {
				anchors.verticalCenter: parent.verticalCenter
				text: "Refresh"
				onClicked: camperDataProvider.refresh()
			}
		}
	}

	CamperOverviewScene {
		id: camperView

		anchors {
			top: toolbar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		scenario: root._scenario
		scenarioText: root._scenarioText
		gridShoreTitle: root._gridShoreTitle
		gridShoreIsShore: root._activeInputSource === "shore"
		gridShorePower: root._gridOrShoreActive ? root._toFiniteNumber(root._data.gridShorePower)
			: NaN
		generatorPower: root._generatorActive ? root._toFiniteNumber(root._data.generatorPower)
			: NaN
		solarPower: root._toFiniteNumber(root._data.solarPower)
		batteryPower: root._toFiniteNumber(root._data.batteryPower)
		batterySoc: root._toFiniteNumber(root._data.batterySoc)
		alternatorPower: root._alternatorPower
		dcLoadsPower: root._toFiniteNumber(root._data.dcLoadsPower)
		acLoadsPower: root._toFiniteNumber(root._data.acLoadsPower)
	}
}
