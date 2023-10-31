/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

ListModel {
	//% "energy"
	ListElement { displayText: qsTrId("vebus_ac_sensor_energy");	pathSuffix: "/Energy"}
	//% "power"
	ListElement {displayText: qsTrId("vebus_ac_sensor_power");		pathSuffix: "/Power"}
	//% "voltage"
	ListElement {displayText: qsTrId("vebus_ac_sensor_voltage");	pathSuffix: "/Voltage"}
	//% "current"
	ListElement {displayText: qsTrId("vebus_ac_sensor_current");	pathSuffix: "/Current"}
	//% "location"
	ListElement {displayText: qsTrId("vebus_ac_sensor_location");	pathSuffix: "/Location"}
	//% "phase"
	ListElement {displayText: qsTrId("vebus_ac_sensor_phase");		pathSuffix: "/Phase"}
}
