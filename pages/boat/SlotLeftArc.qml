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
	required property bool animationEnabled

	implicitHeight: batteryGauge.visible ? batteryGauge.height : shoreArc.visible ? shoreArc.height : 0
	implicitWidth: batteryGauge.visible ? batteryGauge.width : shoreArc.visible ? shoreArc.width : 0

	Boat.BatteryArc {
		id: batteryGauge

		visible: (root.gps.valid || root.motorDrives.dcConsumption.quotient.valid) && !isNaN(Global.system.battery.stateOfCharge)
		animationEnabled: root.animationEnabled
	}

	Boat.ShoreArc {
		id: shoreArc

		visible: !batteryGauge.visible
		animationEnabled: root.animationEnabled
	}
}
