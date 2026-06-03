/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Boat as Boat
import Victron.VenusOS

Item {
	id: root

	required property VeQuickItemsQuotient gps
	required property MotorDrives motorDrives

	implicitHeight: {
		if (batteryPercentage.visible) {
			return batteryPercentage.height;
		}
		if (shoreGauge.visible) {
			return shoreGauge.height;
		}
		return 0;
	}
	implicitWidth: {
		if (batteryPercentage.visible) {
			return batteryPercentage.width;
		}
		if (shoreGauge.visible) {
			return shoreGauge.width;
		}
		return 0;
	}

	Boat.BatteryPercentage {
		id: batteryPercentage

		visible: (root.gps.valid || root.motorDrives.dcConsumption.quotient.valid) && !isNaN(Global.system.battery.stateOfCharge)
		motorDrives: root.motorDrives
	}

	Boat.ShoreGauge {
		id: shoreGauge

		visible: !batteryPercentage.visible
	}
}
