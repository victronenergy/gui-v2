/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	function formatCoord(val, dir, fmt) {
		const degrees = Math.abs(val)
		const minutes = (degrees % 1) * 60.0
		const seconds = (minutes % 1) * 60.0
		const direction = val >= 0 ? dir[0] : dir[1]

		switch (fmt) {
		case VenusOS.GpsData_Format_DecimalDegrees: // e.g. 52.34489
			return Units.formatNumber(val, 6)
		case VenusOS.GpsData_Format_DegreesMinutes: // e.g. 52° 20.693 N
			return "%1° %2 %3"
				.arg(Units.formatNumber(Math.floor(degrees)))
				.arg(Units.formatNumber(minutes, 4))
				.arg(direction)
		default: // VenusOS.GpsData_Format_DegreesMinutesSeconds e.g. 52° 20' 41.6" N
			return "%1° %2' %3\" %4"
					.arg(Units.formatNumber(Math.floor(degrees)))
					.arg(Units.formatNumber(Math.floor(minutes)))
					.arg(Units.formatNumber(seconds, 1))
					.arg(direction)
		}
	}

	GradientListView {
		model: VisibleItemModel {
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
				secondaryText: dataItem.valid ? root.formatCoord(dataItem.value, ["N","S"], format.value) : "--"
			}

			ListText {
				//% "Longitude"
				text: qsTrId("settings_gps_longitude")
				dataItem.uid: bindPrefix + "/Position/Longitude"
				secondaryText: dataItem.valid ? root.formatCoord(dataItem.value, ["E","W"], format.value) : "--"
			}

			ListText {
				text: CommonWords.speed
				dataItem.uid: bindPrefix + "/Speed"
				secondaryText: {
					if (!dataItem.valid) {
						return "--"
					}
					if (speedUnit.value === "km/h") {
						//: GPS speed data, in kilometers per hour
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
						//: GPS speed data, in meters per second
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
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Altitude_Meter)
				dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.altitudeUnit)
				unit: Global.systemSettings.altitudeUnit
			}

			ListText {
				//% "Number of satellites"
				text: qsTrId("settings_gps_num_satellites")
				dataItem.uid: bindPrefix + "/NrOfSatellites"
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
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
		id: format
		uid: Global.systemSettings.serviceUid + "/Settings/Gps/Format"
	}

	VeQuickItem {
		id: speedUnit
		uid: Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit"
	}
}
