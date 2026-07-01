/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS

Item {
	id: root

	required property Gps gps
	required property MotorDrives motorDrives
	required property bool isShoreConnected
	required property bool isBatteryCharging

	implicitHeight: batteryPercentage.visible ? batteryPercentage.height
				: shoreGauge.visible ? shoreGauge.height
				: 0
	implicitWidth: batteryPercentage.visible ? batteryPercentage.width
				: shoreGauge.visible ? shoreGauge.width
				: 0

	Boat.BatteryPercentage {
		id: batteryPercentage

		visible: (root.gps.valid || root.motorDrives.dcConsumption.quotient.valid) && !isNaN(Global.system.battery.stateOfCharge)
		gps: root.gps
		motorDrives: root.motorDrives
		isShoreConnected: root.isShoreConnected
		isBatteryCharging: root.isBatteryCharging
	}

	Boat.ShoreGauge {
		id: shoreGauge

		visible: !batteryPercentage.visible
		isShoreConnected: root.isShoreConnected
	}
}
