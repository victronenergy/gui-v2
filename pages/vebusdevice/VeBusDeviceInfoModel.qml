/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

ListModel {
	//% "VE.Bus version"
	ListElement { displayText: qsTrId("vebus_device_vebus_version");			pathSuffix: "/Devices/0/Version"}
	//% "MK2 device"
	ListElement { displayText: qsTrId("vebus_device_mk2_device");				pathSuffix: "/Interfaces/Mk2/ProductName"}
	//% "MK2 version"
	ListElement { displayText: qsTrId("vebus_device_mk2_version");				pathSuffix: "/Interfaces/Mk2/Version"}
	//% "Multi Control version"
	ListElement { displayText: qsTrId("vebus_device_multi_control_version");	pathSuffix: "/Devices/Dmc/Version"}
	//% "VE.Bus BMS version"
	ListElement { displayText: qsTrId("vebus_device_bms_version");				pathSuffix: "/Devices/Bms/Version"}
}
