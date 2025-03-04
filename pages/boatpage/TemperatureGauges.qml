/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.BoatPageComponents as BoatPageComponents
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

Column {
	readonly property Device motorDrive: Global.allDevicesModel.motorDriveDevices.firstObject

	spacing: Theme.geometry_boatPage_motorDrive_temperaturesColumn_spacing

	BoatPageComponents.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveTemperature
		iconSource: "qrc:/images/icon_engine_temp_32.svg"
	}

	BoatPageComponents.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveCoolantTemperature
		iconSource: "qrc:/images/icon_temp_coolant_32.svg"
	}

	BoatPageComponents.TemperatureGauge {
		anchors.right: parent.right
		dataItem: _motorDriveControllerTemperature
		iconSource: "qrc:/images/icon_motorController_32.svg"
	}

	VeQuickItem {
		id: _motorDriveTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Motor/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: _motorDriveCoolantTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Coolant/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: _motorDriveControllerTemperature

		uid: motorDrive ? motorDrive.serviceUid + "/Controller/Temperature" : ""
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}
}

