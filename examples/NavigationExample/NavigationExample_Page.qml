/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

FocusScope {
	id: root

	focus: true
	focusPolicy: Qt.TabFocus

	onActiveFocusChanged: {
		if (activeFocus && Global.keyNavigationEnabled) {
			const fromBottom = (Global.mainView?.swipeView?.focusEdgeHint ?? 0) === Qt.BottomEdge
			if (fromBottom) {
				waterTile.forceActiveFocus()
			} else {
				batteryTile.forceActiveFocus()
			}
		}
	}

	property string systemUid: Global.system ? Global.system.serviceUid : ""
	property bool fakePumpOn: false

	function fmtPower(w) {
		if (isNaN(w)) return "--"
		return Math.abs(Math.round(w)) + " W"
	}
	function fmtPercent(p) {
		if (isNaN(p)) return "--"
		return Math.round(p) + "%"
	}

	readonly property color tileBackground: Theme.color_overviewPage_widget_background
	readonly property color tileBorder: Theme.color_overviewPage_widget_border
	readonly property real tileBorderWidth: Theme.geometry_overviewPage_widget_border_width || 2
	readonly property real tileRadius: Theme.geometry_overviewPage_widget_radius || 8
	readonly property int gridColumns: 3

	// Tile order is row-major, so the neighbor on the right changes when the
	// grid drops from three columns to two.
	function tileNeighbor(index, rowDelta, columnDelta) {
		const columns = gridColumns
		const row = Math.floor(index / columns) + rowDelta
		const column = (index % columns) + columnDelta
		if (row < 0 || column < 0 || column >= columns)
			return null
		const next = row * columns + column
		const tiles = [batteryTile, solarTile, propaneTile, waterTile, pumpTile, dcTile]
		return next < tiles.length ? tiles[next] : null
	}

	GridLayout {
		anchors.fill: parent
		anchors.margins: 12
		columns: root.gridColumns
		columnSpacing: 8
		rowSpacing: 8

		// ── Battery ──
		Rectangle {
			id: batteryTile
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: batteryTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: batteryTile.activeFocus ? 3 : root.tileBorderWidth
			focus: true
			activeFocusOnTab: true
			KeyNavigation.right: root.tileNeighbor(0, 0, 1)
			KeyNavigation.down: root.tileNeighbor(0, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "BATTERY"
					color: Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: fmtPercent(Global.system.battery.stateOfCharge)
					color: {
						var soc = Global.system.battery.stateOfCharge
						if (isNaN(soc)) return Theme.color_font_primary
						if (soc <= 15) return Theme.color_critical
						if (soc <= 30) return Theme.color_warning
						return Theme.color_ok
					}
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: {
						var p = Global.system.battery.power
						if (isNaN(p)) return "No battery"
						var mode = VenusOS.battery_modeFromPower(p)
						if (mode === VenusOS.Battery_Mode_Charging)
							return "Charging " + fmtPower(p)
						if (mode === VenusOS.Battery_Mode_Discharging)
							return "Discharging " + fmtPower(p)
						return fmtPower(p)
					}
					color: Theme.color_font_secondary
					font.pixelSize: 11
				}
			}
		}

		// ── Solar ──
		Rectangle {
			id: solarTile
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: solarTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: solarTile.activeFocus ? 3 : root.tileBorderWidth
			activeFocusOnTab: true
			KeyNavigation.left: root.tileNeighbor(1, 0, -1)
			KeyNavigation.right: root.tileNeighbor(1, 0, 1)
			KeyNavigation.down: root.tileNeighbor(1, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "SOLAR"
					color: Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: {
						var p = Global.system.solar.power
						return isNaN(p) ? "No PV" : fmtPower(p)
					}
					color: {
						var p = Global.system.solar.power
						return (!isNaN(p) && p > 0) ? Theme.color_ok : Theme.color_font_primary
					}
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: {
						var count = Global.solarChargers ? Global.solarChargers.model.count : 0
						if (count === 0) return "No chargers"
						return count + " charger" + (count > 1 ? "s" : "")
					}
					color: Theme.color_font_secondary
					font.pixelSize: 11
				}
			}
		}

		// ── Propane ──
		Rectangle {
			id: propaneTile
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: propaneTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: propaneTile.activeFocus ? 3 : root.tileBorderWidth
			activeFocusOnTab: true
			KeyNavigation.left: root.tileNeighbor(2, 0, -1)
			KeyNavigation.right: root.tileNeighbor(2, 0, 1)
			KeyNavigation.up: root.tileNeighbor(2, -1, 0)
			KeyNavigation.down: root.tileNeighbor(2, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "PROPANE"
					color: Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: {
						if (!Global.tanks) return "--"
						var models = Global.tanks.allTankModels
						for (var i = 0; i < models.length; i++) {
							if (models[i].type === VenusOS.Tank_Type_LPG && models[i].count > 0) {
								var tank = models[i].deviceAt(0)
								if (tank && !isNaN(tank.level))
									return Math.round(tank.level) + "%"
							}
						}
						return "--"
					}
					color: {
						if (!Global.tanks) return Theme.color_font_primary
						var models = Global.tanks.allTankModels
						for (var i = 0; i < models.length; i++) {
							if (models[i].type === VenusOS.Tank_Type_LPG && models[i].count > 0) {
								var tank = models[i].deviceAt(0)
								if (tank && !isNaN(tank.level)) {
									if (tank.level <= 15) return Theme.color_critical
									if (tank.level <= 30) return Theme.color_warning
									return Theme.color_ok
								}
							}
						}
						return Theme.color_font_primary
					}
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: {
						if (!Global.tanks) return "No tanks"
						var count = 0
						var models = Global.tanks.allTankModels
						for (var i = 0; i < models.length; i++) {
							if (models[i].type === VenusOS.Tank_Type_LPG)
								count += models[i].count
						}
						if (count === 0) return "No propane tanks"
						return count + " tank" + (count > 1 ? "s" : "")
					}
					color: Theme.color_font_secondary
					font.pixelSize: 11
				}
			}
		}

		// ── Water ──
		Rectangle {
			id: waterTile
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: waterTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: waterTile.activeFocus ? 3 : root.tileBorderWidth
			activeFocusOnTab: true
			KeyNavigation.up: root.tileNeighbor(3, -1, 0)
			KeyNavigation.down: root.tileNeighbor(3, 1, 0)
			KeyNavigation.left: root.tileNeighbor(3, 0, -1)
			KeyNavigation.right: root.tileNeighbor(3, 0, 1)

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "WATER"
					color: Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: {
						if (!Global.tanks) return "--"
						var models = Global.tanks.allTankModels
						for (var i = 0; i < models.length; i++) {
							if (models[i].type === VenusOS.Tank_Type_FreshWater && models[i].count > 0) {
								var tank = models[i].deviceAt(0)
								if (tank && !isNaN(tank.level))
									return Math.round(tank.level) + "%"
							}
						}
						return "--"
					}
					color: Theme.color_ok
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: {
						if (!Global.tanks) return "No tanks"
						var count = 0
						var models = Global.tanks.allTankModels
						for (var i = 0; i < models.length; i++) {
							if (models[i].type === VenusOS.Tank_Type_FreshWater)
								count += models[i].count
						}
						if (count === 0) return "No fresh water"
						return count + " tank" + (count > 1 ? "s" : "")
					}
					color: Theme.color_font_secondary
					font.pixelSize: 11
				}
			}
		}

		// ── Water Pump ──
		Rectangle {
			id: pumpTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.fakePumpOn ? Theme.color_ok : root.tileBackground
			border.color: pumpTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: pumpTile.activeFocus ? 3 : root.tileBorderWidth
			focus: true
			activeFocusOnTab: true
			KeyNavigation.up: root.tileNeighbor(4, -1, 0)
			KeyNavigation.left: root.tileNeighbor(4, 0, -1)
			KeyNavigation.right: root.tileNeighbor(4, 0, 1)

			Behavior on color {
				ColorAnimation { duration: 200 }
			}

			Keys.onSpacePressed: root.fakePumpOn = !root.fakePumpOn
			Keys.onReturnPressed: root.fakePumpOn = !root.fakePumpOn

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "PUMP"
					color: root.fakePumpOn ? "white" : Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: root.fakePumpOn ? "ON" : "OFF"
					color: root.fakePumpOn ? "white" : Theme.color_font_primary
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: "Tap to toggle"
					color: root.fakePumpOn ? Qt.rgba(1,1,1,0.7) : Theme.color_font_secondary
					font.pixelSize: 11
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: {
					pumpTile.forceActiveFocus()
					root.fakePumpOn = !root.fakePumpOn
				}
			}
		}

		// ── DC System ──
		Rectangle {
			id: dcTile
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: dcTile.activeFocus ? Theme.color_focus_highlight : root.tileBorder
			border.width: dcTile.activeFocus ? 3 : root.tileBorderWidth
			activeFocusOnTab: true
			KeyNavigation.up: root.tileNeighbor(5, -1, 0)
			KeyNavigation.left: root.tileNeighbor(5, 0, -1)
			KeyNavigation.right: root.tileNeighbor(5, 0, 1)

			Column {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 2

				Text {
					text: "DC SYSTEM"
					color: Theme.color_font_secondary
					font.pixelSize: 11
					font.bold: true
				}
				Text {
					text: {
						var p = Global.system.dc.power
						return isNaN(p) ? "-- W" : fmtPower(p)
					}
					color: Theme.color_font_primary
					font.pixelSize: 36
					font.bold: true
				}
				Text {
					text: {
						var v = Global.system.dc.voltage
						if (isNaN(v)) return "No DC data"
						return v.toFixed(1) + " V"
					}
					color: Theme.color_font_secondary
					font.pixelSize: 11
				}
			}
		}
	}
}
