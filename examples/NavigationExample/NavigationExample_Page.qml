/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

FocusScope {
	id: root

	property bool fakePumpOn: false

	readonly property int gridColumns: Theme.screenSize === Theme.Portrait ? 2 : 3
	readonly property int titlePixelSize: Theme.font_overviewPage_widget_phase_minimumSize
	readonly property int valuePixelSize: Theme.font_overviewPage_widget_quantityLabel_large
	readonly property int detailPixelSize: Theme.font_overviewPage_widget_quantityLabel_small

	focus: true
	focusPolicy: Qt.TabFocus

	function tiles() {
		return [batteryTile, solarTile, propaneTile, waterTile, pumpTile, dcTile]
	}

	function tileNeighbor(index, rowDelta, columnDelta) {
		const columns = gridColumns
		const row = Math.floor(index / columns) + rowDelta
		const column = (index % columns) + columnDelta
		if (row < 0 || column < 0 || column >= columns) {
			return null
		}
		const next = row * columns + column
		const all = tiles()
		return next < all.length ? all[next] : null
	}

	function firstTileOfLastRow() {
		const all = tiles()
		const start = Math.floor((all.length - 1) / gridColumns) * gridColumns
		return all[start]
	}

	function firstTank(type) {
		if (!Services.tanks) {
			return null
		}
		const models = Services.tanks.allTankModels
		for (let i = 0; i < models.length; ++i) {
			if (models[i].type === type && models[i].count > 0) {
				return models[i].deviceAt(0)
			}
		}
		return null
	}

	function tankCount(type) {
		if (!Services.tanks) {
			return 0
		}
		let count = 0
		const models = Services.tanks.allTankModels
		for (let i = 0; i < models.length; ++i) {
			if (models[i].type === type) {
				count += models[i].count
			}
		}
		return count
	}

	onActiveFocusChanged: {
		if (activeFocus && Global.keyNavigationEnabled) {
			const fromBottom = (Global.mainView?.swipeView?.focusEdgeHint ?? 0) === Qt.BottomEdge
			if (fromBottom) {
				firstTileOfLastRow().focus = true
			} else {
				batteryTile.focus = true
			}
		}
	}

	GridLayout {
		anchors.fill: parent
		anchors.margins: Theme.geometry_overviewPage_widget_spacing
		columns: root.gridColumns
		columnSpacing: Theme.geometry_overviewPage_widget_spacing
		rowSpacing: Theme.geometry_overviewPage_widget_spacing

		Rectangle {
			id: batteryTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: Theme.color_overviewPage_widget_background
			border.color: batteryTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focus: true
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.right: root.tileNeighbor(0, 0, 1)
			KeyNavigation.down: root.tileNeighbor(0, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					text: CommonWords.battery
					color: Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: {
						const soc = Global.system && Global.system.battery ? Global.system.battery.stateOfCharge : NaN
						if (isNaN(soc)) {
							return "--"
						}
						//% "%1%"
						return qsTrId("navexample_percent").arg(Math.round(soc))
					}
					color: {
						const soc = Global.system && Global.system.battery ? Global.system.battery.stateOfCharge : NaN
						if (isNaN(soc) || soc > 30) {
							return isNaN(soc) ? Theme.color_font_primary : Theme.color_ok
						}
						if (soc <= 15) {
							return Theme.color_critical
						}
						return Theme.color_warning
					}
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					text: {
						const power = Global.system && Global.system.battery ? Global.system.battery.power : NaN
						if (isNaN(power)) {
							//% "No battery"
							return qsTrId("navexample_no_battery")
						}
						//% "%1 W"
						const watts = qsTrId("navexample_watts").arg(Math.abs(Math.round(power)))
						const mode = VenusOS.battery_modeFromPower(power)
						if (mode === VenusOS.Battery_Mode_Charging) {
							//% "Charging %1"
							return qsTrId("navexample_charging").arg(watts)
						}
						if (mode === VenusOS.Battery_Mode_Discharging) {
							//% "Discharging %1"
							return qsTrId("navexample_discharging").arg(watts)
						}
						return watts
					}
					color: Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}
		}

		Rectangle {
			id: solarTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: Theme.color_overviewPage_widget_background
			border.color: solarTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.left: root.tileNeighbor(1, 0, -1)
			KeyNavigation.right: root.tileNeighbor(1, 0, 1)
			KeyNavigation.down: root.tileNeighbor(1, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					text: CommonWords.solar
					color: Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: {
						const power = Global.system && Global.system.solar ? Global.system.solar.power : NaN
						if (isNaN(power)) {
							//% "No PV"
							return qsTrId("navexample_no_pv")
						}
						//% "%1 W"
						return qsTrId("navexample_watts").arg(Math.abs(Math.round(power)))
					}
					color: {
						const power = Global.system && Global.system.solar ? Global.system.solar.power : NaN
						return !isNaN(power) && power > 0 ? Theme.color_ok : Theme.color_font_primary
					}
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					text: {
						const count = Global.solarChargers ? Global.solarChargers.model.count : 0
						if (count === 0) {
							//% "No chargers"
							return qsTrId("navexample_no_chargers")
						}
						//% "%n charger(s)"
						return qsTrId("navexample_charger_count", count)
					}
					color: Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}
		}

		Rectangle {
			id: propaneTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: Theme.color_overviewPage_widget_background
			border.color: propaneTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.left: root.tileNeighbor(2, 0, -1)
			KeyNavigation.right: root.tileNeighbor(2, 0, 1)
			KeyNavigation.up: root.tileNeighbor(2, -1, 0)
			KeyNavigation.down: root.tileNeighbor(2, 1, 0)

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					//% "Propane"
					text: qsTrId("navexample_propane")
					color: Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: {
						const tank = root.firstTank(VenusOS.Tank_Type_LPG)
						if (!tank || isNaN(tank.level)) {
							return "--"
						}
						//% "%1%"
						return qsTrId("navexample_percent").arg(Math.round(tank.level))
					}
					color: {
						const tank = root.firstTank(VenusOS.Tank_Type_LPG)
						if (!tank || isNaN(tank.level)) {
							return Theme.color_font_primary
						}
						if (tank.level <= 15) {
							return Theme.color_critical
						}
						if (tank.level <= 30) {
							return Theme.color_warning
						}
						return Theme.color_ok
					}
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					text: {
						const count = root.tankCount(VenusOS.Tank_Type_LPG)
						if (!Services.tanks) {
							//% "No tanks"
							return qsTrId("navexample_no_tanks")
						}
						if (count === 0) {
							//% "No propane tanks"
							return qsTrId("navexample_no_propane_tanks")
						}
						//% "%n tank(s)"
						return qsTrId("navexample_tank_count", count)
					}
					color: Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}
		}

		Rectangle {
			id: waterTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: Theme.color_overviewPage_widget_background
			border.color: waterTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.up: root.tileNeighbor(3, -1, 0)
			KeyNavigation.down: root.tileNeighbor(3, 1, 0)
			KeyNavigation.left: root.tileNeighbor(3, 0, -1)
			KeyNavigation.right: root.tileNeighbor(3, 0, 1)

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					//% "Water"
					text: qsTrId("navexample_water")
					color: Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: {
						const tank = root.firstTank(VenusOS.Tank_Type_FreshWater)
						if (!tank || isNaN(tank.level)) {
							return "--"
						}
						//% "%1%"
						return qsTrId("navexample_percent").arg(Math.round(tank.level))
					}
					color: Theme.color_ok
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					text: {
						const count = root.tankCount(VenusOS.Tank_Type_FreshWater)
						if (!Services.tanks) {
							//% "No tanks"
							return qsTrId("navexample_no_tanks")
						}
						if (count === 0) {
							//% "No fresh water"
							return qsTrId("navexample_no_fresh_water")
						}
						//% "%n tank(s)"
						return qsTrId("navexample_tank_count", count)
					}
					color: Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}
		}

		Rectangle {
			id: pumpTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: root.fakePumpOn ? Theme.color_ok : Theme.color_overviewPage_widget_background
			border.color: pumpTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.up: root.tileNeighbor(4, -1, 0)
			KeyNavigation.left: root.tileNeighbor(4, 0, -1)
			KeyNavigation.right: root.tileNeighbor(4, 0, 1)

			Behavior on color {
				ColorAnimation { duration: 200 }
			}

			Keys.enabled: Global.keyNavigationEnabled
			Keys.onSpacePressed: root.fakePumpOn = !root.fakePumpOn
			Keys.onReturnPressed: root.fakePumpOn = !root.fakePumpOn

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					//% "Pump"
					text: qsTrId("navexample_pump")
					color: root.fakePumpOn ? Theme.color_button_down_text : Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: root.fakePumpOn ? CommonWords.on : CommonWords.off
					color: root.fakePumpOn ? Theme.color_button_down_text : Theme.color_font_primary
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					//% "Tap to toggle"
					text: qsTrId("navexample_tap_to_toggle")
					color: root.fakePumpOn ? Theme.color_button_down_text : Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: {
					pumpTile.focus = true
					root.fakePumpOn = !root.fakePumpOn
				}
			}
		}

		Rectangle {
			id: dcTile

			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: Theme.geometry_overviewPage_widget_radius
			color: Theme.color_overviewPage_widget_background
			border.color: dcTile.activeFocus ? Theme.color_focus_highlight : Theme.color_overviewPage_widget_border
			border.width: Theme.geometry_overviewPage_widget_border_width
			focusPolicy: Qt.TabFocus
			KeyNavigationHighlight.active: activeFocus
			KeyNavigation.up: root.tileNeighbor(5, -1, 0)
			KeyNavigation.left: root.tileNeighbor(5, 0, -1)
			KeyNavigation.right: root.tileNeighbor(5, 0, 1)

			Column {
				anchors.fill: parent
				anchors.margins: Theme.geometry_overviewPage_widget_content_horizontalMargin
				spacing: Theme.geometry_overviewPage_widget_spacing

				Text {
					//% "DC system"
					text: qsTrId("navexample_dc_system")
					color: Theme.color_font_secondary
					font.pixelSize: root.titlePixelSize
					font.bold: true
				}
				Text {
					text: {
						const power = Global.system && Global.system.dc ? Global.system.dc.power : NaN
						if (isNaN(power)) {
							return "--"
						}
						//% "%1 W"
						return qsTrId("navexample_watts").arg(Math.abs(Math.round(power)))
					}
					color: Theme.color_font_primary
					font.pixelSize: root.valuePixelSize
					font.bold: true
				}
				Text {
					text: {
						const voltage = Global.system && Global.system.dc ? Global.system.dc.voltage : NaN
						if (isNaN(voltage)) {
							//% "No DC data"
							return qsTrId("navexample_no_dc_data")
						}
						//% "%1 V"
						return qsTrId("navexample_volts").arg(voltage.toFixed(1))
					}
					color: Theme.color_font_secondary
					font.pixelSize: root.detailPixelSize
				}
			}
		}
	}
}
