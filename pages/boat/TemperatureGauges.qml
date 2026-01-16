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

	required property MotorDrive motorDrive

	spacing: Theme.geometry_boatPage_motorDrive_temperaturesColumn_spacing

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: motorDrive.motorTemperature
		iconSource: "qrc:/images/icon_engine_temp_32.svg"
	}

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: motorDrive.coolantTemperature
		iconSource: "qrc:/images/icon_temp_coolant_32.svg"
	}

	Boat.TemperatureGauge {
		anchors.right: parent.right
		dataItem: motorDrive.controllerTemperature
		iconSource: "qrc:/images/icon_motorController_32.svg"
	}
}

