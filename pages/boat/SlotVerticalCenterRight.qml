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

	implicitHeight: consumptionGauge.height
	implicitWidth: consumptionGauge.width

	Boat.ConsumptionGauge {
		id: consumptionGauge

		motorDrives: root.motorDrives
		gps: root.gps
	}
}
