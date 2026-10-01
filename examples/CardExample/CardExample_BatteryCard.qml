import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	property bool fakePumpOn: false

	implicitWidth: Theme.geometry_controlCard_maximumWidth
	implicitHeight: contentColumn.implicitHeight + 24
	focus: true
	focusPolicy: Qt.TabFocus

	ListItemBackground {
		anchors.fill: parent
	}

	ColumnLayout {
		id: contentColumn
		anchors {
			fill: parent
			margins: 12
		}
		spacing: 8

		// ── Header ──
		RowLayout {
			spacing: 8
			CP.ColorImage {
				source: "qrc:/CardExample/icon_brick.svg"
				color: Theme.color_font_primary
				sourceSize.width: 20
				sourceSize.height: 20
			}
			Label {
				text: "Plugin Dashboard"
				font.pixelSize: Theme.font_control_title
				color: Theme.color_font_primary
			}
		}

		// ── Battery row ──
		RowLayout {
			Layout.fillWidth: true
			spacing: 8
			Label {
				text: "Battery"
				color: Theme.color_font_secondary
				font.pixelSize: 14
				Layout.preferredWidth: 60
			}
			Label {
				text: {
					var soc = Global.system.battery.stateOfCharge
					if (isNaN(soc)) return "--"
					return Math.round(soc) + "%"
				}
				color: {
					var soc = Global.system.battery.stateOfCharge
					if (isNaN(soc)) return Theme.color_font_primary
					if (soc <= 15) return Theme.color_critical
					if (soc <= 30) return Theme.color_warning
					return Theme.color_ok
				}
				font.pixelSize: 14
				font.bold: true
			}
			Label {
				text: {
					var p = Global.system.battery.power
					if (isNaN(p)) return ""
					return (p < 0 ? "Chg " : "Dis ") + Math.abs(Math.round(p)) + "W"
				}
				color: Theme.color_font_secondary
				font.pixelSize: 12
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignRight
			}
		}

		// ── Solar row ──
		RowLayout {
			Layout.fillWidth: true
			spacing: 8
			Label {
				text: "Solar"
				color: Theme.color_font_secondary
				font.pixelSize: 14
				Layout.preferredWidth: 60
			}
			Label {
				text: {
					var p = Global.system.solar.power
					return isNaN(p) ? "--" : Math.round(p) + " W"
				}
				color: {
					var p = Global.system.solar.power
					return (!isNaN(p) && p > 0) ? Theme.color_ok : Theme.color_font_primary
				}
				font.pixelSize: 14
				font.bold: true
			}
			Label {
				text: {
					var c = Global.solarChargers ? Global.solarChargers.model.count : 0
					return c > 0 ? c + " mppt" : ""
				}
				color: Theme.color_font_secondary
				font.pixelSize: 12
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignRight
			}
		}

		// ── Water row ──
		RowLayout {
			Layout.fillWidth: true
			spacing: 8
			Label {
				text: "Water"
				color: Theme.color_font_secondary
				font.pixelSize: 14
				Layout.preferredWidth: 60
			}
			Label {
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
				font.pixelSize: 14
				font.bold: true
			}
			Label {
				text: "fresh"
				color: Theme.color_font_secondary
				font.pixelSize: 12
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignRight
			}
		}

		// ── Fake pump button ──
		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: 40
			radius: 6
			color: root.fakePumpOn ? Theme.color_ok : Theme.color_overviewPage_widget_background
			border.color: Theme.color_overviewPage_widget_border
			border.width: 1

			Behavior on color {
				ColorAnimation { duration: 200 }
			}

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 12
				anchors.rightMargin: 12

				Label {
					text: "Water Pump"
					color: root.fakePumpOn ? "white" : Theme.color_font_primary
					font.pixelSize: 14
				}
				Item { Layout.fillWidth: true }
				Label {
					text: root.fakePumpOn ? "ON" : "OFF"
					color: root.fakePumpOn ? "white" : Theme.color_font_secondary
					font.pixelSize: 14
					font.bold: true
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.fakePumpOn = !root.fakePumpOn
			}
		}
	}
}
