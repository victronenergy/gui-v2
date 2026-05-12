/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS

Row {
	id: root

	required property MotorDrives motorDrives

	spacing: Theme.geometry_boatPage_temperature_row_spacing

	component ColumnHeader: Label {
		anchors.horizontalCenter: parent.horizontalCenter

		font.pixelSize: Theme.font_boatPage_temperature_columnHeader_pixelSize
		color: Theme.color_font_secondary
	}

	component Temperature: QuantityLabel {
		font.pixelSize: Theme.font_boatPage_temperature_value_pixelSize
		unit: Global.systemSettings.temperatureUnit
		unitText: Units.degreesSymbol
		unitColor: Theme.color_font_primary
		visible: !isNaN(value)
	}

	component TemperatureColumn : Column {
		required property string label
		required property string dataProperty

		spacing: Theme.geometry_boatPage_temperature_temperatureColumn_spacing

		visible: motorDrives.singleMotorDrive && motorDrives.singleMotorDrive[dataProperty].valid
				|| motorDrives.leftMotorDrive && motorDrives.leftMotorDrive[dataProperty].valid
				|| motorDrives.rightMotorDrive && motorDrives.rightMotorDrive[dataProperty].valid

		ColumnHeader {
			text: label
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter

			spacing: Theme.geometry_boatPage_temperature_temperatureRow_spacing

			Temperature {
				value: motorDrives.singleMotorDrive && motorDrives.singleMotorDrive[dataProperty].valid ? motorDrives.singleMotorDrive[dataProperty].value : NaN
			}

			Temperature {
				value: motorDrives.leftMotorDrive && motorDrives.leftMotorDrive[dataProperty].valid ? motorDrives.leftMotorDrive[dataProperty].value : NaN
			}

			Temperature {
				value: motorDrives.rightMotorDrive && motorDrives.rightMotorDrive[dataProperty].valid ? motorDrives.rightMotorDrive[dataProperty].value : NaN
			}
		}
	}

	component TemperatureSeparator: SeparatorBar {
		anchors.verticalCenter: parent.verticalCenter
		height: Theme.geometry_boatPage_temperature_temperatureSeparator_height
		width: Theme.geometry_boatPage_temperature_temperatureSeparator_width
	}

	Column {
		id: batteryTemperatureColumn
		spacing: Theme.geometry_boatPage_temperature_temperatureColumn_spacing

		ColumnHeader {
			//% "Battery"
			text: qsTrId("boat_page_temperature_battery_label")
		}

		Temperature {
			anchors.horizontalCenter: parent.horizontalCenter
			value: Global.system && Global.system.battery ? Global.system.battery.temperature : NaN
		}
	}

	TemperatureSeparator {
		visible: batteryTemperatureColumn.visible && (coolantTemperatureColumn.visible || controllerTemperatureColumn.visible || motorTemperatureColumn.visible)
	}

	TemperatureColumn {
		id: coolantTemperatureColumn

		//% "Coolant"
		label: qsTrId("boat_page_temperature_coolant_label")
		dataProperty: "coolantTemperature"
	}

	TemperatureSeparator {
		visible: coolantTemperatureColumn.visible && (controllerTemperatureColumn.visible || motorTemperatureColumn.visible)
	}

	TemperatureColumn {
		id: controllerTemperatureColumn

		//% "Controller"
		label: qsTrId("boat_page_temperature_controller_label")
		dataProperty: "controllerTemperature"
	}

	TemperatureSeparator {
		visible: controllerTemperatureColumn.visible && motorTemperatureColumn.visible
	}

	TemperatureColumn {
		id: motorTemperatureColumn

		//% "Motor"
		label: qsTrId("boat_page_temperature_motor_label")
		dataProperty: "motorTemperature"
	}
}

