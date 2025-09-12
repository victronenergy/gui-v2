/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS
import Victron.Gauges

Column {
	id: root

	required property string serviceUid

	spacing: Theme.geometry_boatPage_motorDrive_temperaturesColumn_spacing

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveTemperature
		iconSource: "qrc:/images/icon_engine_temp_32.svg"
	}

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveCoolantTemperature
		iconSource: "qrc:/images/icon_temp_coolant_32.svg"
	}

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveControllerTemperature
		iconSource: "qrc:/images/icon_motorController_32.svg"
	}

	VeQuickItem {
		id: _motorDriveTemperature

		uid: root.serviceUid ? root.serviceUid + "/Motor/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: _motorDriveCoolantTemperature

		uid: root.serviceUid ? root.serviceUid + "/Coolant/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: _motorDriveControllerTemperature

		uid: root.serviceUid ? root.serviceUid + "/Controller/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}
}

