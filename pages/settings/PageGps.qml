/*
** Copyright (C) 2023 Victron Energy B.V.
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
			return val.toFixed(6)
		case VenusOS.GpsData_Format_DegreesMinutes: // e.g. 52° 20.693 N
			return "%1° %2 %3".arg(Math.floor(degrees).toFixed()).arg(minutes.toFixed(4)).arg(direction)
		default: // VenusOS.GpsData_Format_DegreesMinutesSeconds e.g. 52° 20' 41.6" N
			return "%1° %2' %3\" %4"
					.arg(Math.floor(degrees).toFixed())
					.arg(Math.floor(minutes).toFixed())
					.arg(seconds.toFixed(1))
					.arg(direction)
		}
	}

	GradientListView {
		model: ObjectModel {
			ListTextItem {
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

			ListTextItem {
				//% "Latitude"
				text: qsTrId("settings_gps_latitude")
				dataSource: bindPrefix + "/Position/Latitude"
				secondaryText: dataValid ? root.formatCoord(dataValue, ["N","S"], format.value) : "--"
			}

			ListTextItem {
				//% "Longitude"
				text: qsTrId("settings_gps_longitude")
				dataSource: bindPrefix + "/Position/Longitude"
				secondaryText: dataValid ? root.formatCoord(dataValue, ["E","W"], format.value) : "--"
			}

			ListTextItem {
				//% "Speed"
				text: qsTrId("settings_gps_speed")
				dataSource: bindPrefix + "/Speed"
				secondaryText: {
					if (!dataValid) {
						return "--"
					}
					if (speedUnit.value === "km/h") {
						//: GPS speed data, in kilometers per hour
						//% "%1 km/h"
						return qsTrId("settings_gps_speed_kmh").arg((dataValue * 3.6).toFixed(1))
					} else if (speedUnit.value === "mph") {
						//: GPS speed data, in miles per hour
						//% "%1 mph"
						return qsTrId("settings_gps_speed_mph").arg((dataValue * 2.236936).toFixed(1))
					} else if (speedUnit.value === "kt") {
						//: GPS speed data, in knots
						//% "%1 kt"
						return qsTrId("settings_gps_speed_kt").arg((dataValue * (3600/1852)).toFixed(1))
					} else {
						//: GPS speed data, in meters per second
						//% "%1 m/s"
						return qsTrId("settings_gps_speed_ms").arg(dataValue.toFixed(2))
					}
				}
			}

			ListTextItem {
				//% "Course"
				text: qsTrId("settings_gps_course")
				dataSource: bindPrefix + "/Course"
				secondaryText: dataValid ? "%1°".arg(dataValue.toFixed(1)) : ""
			}

			ListTextItem {
				//% "Altitude"
				text: qsTrId("settings_gps_altitude")
				dataSource: bindPrefix + "/Altitude"
			}

			ListTextItem {
				//% "Number of satellites"
				text: qsTrId("settings_gps_num_satellites")
				dataSource: bindPrefix + "/NrOfSatellites"
			}

			ListNavigationItem {
				//% "Device"
				text: qsTrId("settings_gps_device")

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}

	DataPoint {
		id: connected
		source: bindPrefix + "/Connected"
	}

	DataPoint {
		id: fix
		source: bindPrefix + "/Fix"
	}

	DataPoint {
		id: format
		source: "com.victronenergy.settings/Settings/Gps/Format"
	}

	DataPoint {
		id: speedUnit
		source: "com.victronenergy.settings/Settings/Gps/SpeedUnit"
	}
}
