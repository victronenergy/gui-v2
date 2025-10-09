/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VeQuickItemsQuotient {
	id: root

	readonly property string units: _speedUnits.valid ? _speedUnits.value : ""
	readonly property real speed: {
		switch (units) {
		case "km/h":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METRES_PER_KILOMETRE
		case "mph":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METRES_PER_MILE
		case "kt":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METRES_PER_NAUTICAL_MILE
		default: // metres per second
			return numerator
		}
	}

	readonly property VeQuickItem _speedUnits : VeQuickItem {
		uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	objectName: "Boat.Gps"
	numeratorUid: Global.system.serviceUid ? Global.system.serviceUid + "/GpsSpeed" : "" // metres per second
	denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max" : ""
	sourceUnit: VenusOS.Units_Speed_MetresPerSecond
	displayUnit: Global.systemSettings.speedUnit
}
