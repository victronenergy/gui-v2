/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a gps device.
*/
DevicePage {
	id: root

	property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListText {
			text: CommonWords.status
			secondaryText: {
				if (connected.valid && connected.value) {
					if (fix.valid && fix.value) {
						//% "GPS OK (fix)"
						return qsTrId("settings_gps_ok_fix")
					}
					//% "GPS connected, but no GPS fix"
					return qsTrId("settings_gps_ok_no_fix")
				}
				//% "No GPS connected"
				return qsTrId("settings_gps_not_connected")
			}
		}

		ListText {
			//% "Latitude"
			text: qsTrId("settings_gps_latitude")
			dataItem.uid: bindPrefix + "/Position/Latitude"
			secondaryText: dataItem.valid ? Global.systemSettings.formatLatitude(dataItem.value) : "--"
		}

		ListText {
			//% "Longitude"
			text: qsTrId("settings_gps_longitude")
			dataItem.uid: bindPrefix + "/Position/Longitude"
			secondaryText: dataItem.valid ? Global.systemSettings.formatLongitude(dataItem.value) : "--"
		}

		ListText {
			text: CommonWords.speed
			dataItem.uid: bindPrefix + "/Speed"
			secondaryText: {
				if (!dataItem.valid) {
					return "--"
				}
				if (speedUnit.value === "km/h") {
					//: GPS speed data, in kilometres per hour
					//% "%1 km/h"
					return qsTrId("settings_gps_speed_kmh").arg(Units.formatNumber(dataItem.value * 3.6, 1))
				} else if (speedUnit.value === "mph") {
					//: GPS speed data, in miles per hour
					//% "%1 mph"
					return qsTrId("settings_gps_speed_mph").arg(Units.formatNumber(dataItem.value * 2.236936, 1))
				} else if (speedUnit.value === "kt") {
					//: GPS speed data, in knots
					//% "%1 kt"
					return qsTrId("settings_gps_speed_kt").arg(Units.formatNumber(dataItem.value * (3600/1852), 1))
				} else {
					//: GPS speed data, in metres per second
					//% "%1 m/s"
					return qsTrId("settings_gps_speed_ms").arg(Units.formatNumber(dataItem.value, 2))
				}
			}
		}

		ListQuantity {
			//% "Course"
			text: qsTrId("settings_gps_course")
			dataItem.uid: bindPrefix + "/Course"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_CardinalDirection
		}

		ListQuantity {
			//% "Altitude"
			text: qsTrId("settings_gps_altitude")
			dataItem.uid: root.bindPrefix + "/Altitude"
			dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Altitude_Metre)
			dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.altitudeUnit)
			unit: Global.systemSettings.altitudeUnit
		}

		ListText {
			//% "Number of satellites"
			text: qsTrId("settings_gps_num_satellites")
			dataItem.uid: bindPrefix + "/NrOfSatellites"
		}
	}

	VeQuickItem {
		id: connected
		uid: bindPrefix + "/Connected"
	}

	VeQuickItem {
		id: fix
		uid: bindPrefix + "/Fix"
	}

	VeQuickItem {
		id: speedUnit
		uid: Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit"
	}
}
