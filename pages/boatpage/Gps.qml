/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VeQuickItemsQuotient {
	id: root

	property string activeGpsUid
	property string units: _speedUnits.valid ? _speedUnits.value : ""
	readonly property real speed: {
		switch (units) {
		case "km/h":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METERS_PER_KILOMETER
		case "mph":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METERS_PER_MILE
		case "kt":
			return numerator * Utils.SECONDS_PER_HOUR / Utils.METERS_PER_NAUTICAL_MILE
		default: // meters per second
			return numerator
		}
	}

	property VeQuickItem _speedUnits : VeQuickItem {
		uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	property Instantiator gpsDevices: Instantiator { // There can be multiple GPSes, for v1 of boat page we just pick the first one we find and use that.
		model: Global.allDevicesModel.gpsDevices
		delegate: QtObject {
			property var speed: VeQuickItem {
				uid: modelData.serviceUid + "/Speed"
				onValueChanged: {
					if (!activeGpsUid && valid) {
						console.log(modelData.serviceUid, "is now the active gps")
						root.activeGpsUid = modelData.serviceUid
					}
				}
			}
		}
	}

	objectName: "gps"
	numeratorUid: activeGpsUid ? activeGpsUid + "/Speed" : "" // meters per second
	denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max" : ""
	sourceUnit: VenusOS.Units_Speed_KilometersPerHour
	displayUnit: Global.systemSettings.speedUnit
}
