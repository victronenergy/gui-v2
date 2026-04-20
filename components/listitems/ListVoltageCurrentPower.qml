/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	id: root

	required property string bindPrefix
	property int voltageUnit: VenusOS.Units_Volt_AC

	model: QuantityObjectModel {
		QuantityObject { object: voltage; unit: root.voltageUnit }
		QuantityObject { object: current; unit: VenusOS.Units_Amp }
		QuantityObject { object: power; unit: VenusOS.Units_Watt }
	}

	VeQuickItem {
		id: voltage
		uid: root.bindPrefix + "/Voltage"
	}
	VeQuickItem {
		id: current
		uid: root.bindPrefix + "/Current"
	}
	VeQuickItem {
		id: power
		uid: root.bindPrefix + "/Power"
	}
}
