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
		uid: Services.settings ? Services.settings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	objectName: "Boat.Gps"
	numeratorUid: Services.system.serviceUid ? Services.system.serviceUid + "/GpsSpeed" : "" // metres per second
	denominatorUid: Services.settings ? Services.settings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max" : ""
	sourceUnit: VenusOS.Units_Speed_MetresPerSecond
	displayUnit: Services.settings.speedUnit
}
