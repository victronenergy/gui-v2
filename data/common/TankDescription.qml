/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

// Provides a string description for a tank, equivalent to that provided by gui-v1 DBusTankService.

QtObject {
	id: root

	required property Device device

	readonly property string description: {
		if (device.customName.length > 0) {
			// If a custom name is available and set, use that as device description
			return device.customName
		} else if (_type.value >= 0 && device.deviceInstance >= 0) {
			//: Tank description. %1 = tank type (e.g. Fuel, Fresh water), %2 = tank device instance (a number)
			//% "%1 tank (%2)"
			return qsTrId("tank_description").arg(Gauges.tankProperties(_type.value).name).arg(device.deviceInstance)
		} else {
			return device.productName
		}
	}

	readonly property VeQuickItem _type: VeQuickItem {
		uid: root.device.serviceUid + "/FluidType"
	}
}
