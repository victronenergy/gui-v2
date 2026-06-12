import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	title: "Quick Access"
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

	GridLayout {
		anchors.fill: parent
		anchors.margins: 12
		columns: 2
		columnSpacing: 10
		rowSpacing: 10

		// ── Battery ──
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: root.tileBorder
			border.width: root.tileBorderWidth

			Column {
				anchors.fill: parent
				anchors.margins: 14
				spacing: 4

				Text {
					text: "BATTERY"
					color: Theme.color_font_secondary
					font.pixelSize: 13
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
					font.pixelSize: 48
					font.bold: true
				}
				Text {
					text: {
						var p = Global.system.battery.power
						if (isNaN(p)) return "No battery"
						return (p < 0 ? "Charging " : "Discharging ") + fmtPower(p)
					}
					color: Theme.color_font_secondary
					font.pixelSize: 13
				}
			}
		}

		// ── Solar ──
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: root.tileBorder
			border.width: root.tileBorderWidth

			Column {
				anchors.fill: parent
				anchors.margins: 14
				spacing: 4

				Text {
					text: "SOLAR"
					color: Theme.color_font_secondary
					font.pixelSize: 13
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
					font.pixelSize: 48
					font.bold: true
				}
				Text {
					text: {
						var count = Global.solarChargers ? Global.solarChargers.model.count : 0
						if (count === 0) return "No chargers"
						return count + " charger" + (count > 1 ? "s" : "")
					}
					color: Theme.color_font_secondary
					font.pixelSize: 13
				}
			}
		}

		// ── Water ──
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.tileBackground
			border.color: root.tileBorder
			border.width: root.tileBorderWidth

			Column {
				anchors.fill: parent
				anchors.margins: 14
				spacing: 4

				Text {
					text: "WATER"
					color: Theme.color_font_secondary
					font.pixelSize: 13
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
					font.pixelSize: 48
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
						if (count === 0) return "No fresh water tanks"
						return count + " fresh water tank" + (count > 1 ? "s" : "")
					}
					color: Theme.color_font_secondary
					font.pixelSize: 13
				}
			}
		}

		// ── Fake Button ──
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			radius: root.tileRadius
			color: root.fakePumpOn ? Theme.color_ok : root.tileBackground
			border.color: root.tileBorder
			border.width: root.tileBorderWidth

			Behavior on color {
				ColorAnimation { duration: 200 }
			}

			Column {
				anchors.centerIn: parent
				spacing: 8

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					text: "WATER PUMP"
					color: root.fakePumpOn ? "white" : Theme.color_font_secondary
					font.pixelSize: 13
					font.bold: true
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					text: root.fakePumpOn ? "ON" : "OFF"
					color: root.fakePumpOn ? "white" : Theme.color_font_primary
					font.pixelSize: 48
					font.bold: true
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					text: "Tap to toggle"
					color: root.fakePumpOn ? Qt.rgba(1,1,1,0.7) : Theme.color_font_secondary
					font.pixelSize: 13
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.fakePumpOn = !root.fakePumpOn
			}
		}
	}
}
