/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectName: "pvInverters"
	}

	function addInverter(inverter) {
		model.addDevice(inverter)
	}

	function removeInverter(inverter) {
		model.removeDevice(inverter.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function statusCodeToText(statusCode) {
		switch (statusCode) {
		case VenusOS.PvInverter_StatusCode_Startup0:
			//% "Startup 0"
			return qsTrId("pvinverters_statusCode_startup_0")
		case VenusOS.PvInverter_StatusCode_Startup1:
			//% "Startup 1"
			return qsTrId("pvinverters_statusCode_startup_1")
		case VenusOS.PvInverter_StatusCode_Startup2:
			//% "Startup 2"
			return qsTrId("pvinverters_statusCode_startup_2")
		case VenusOS.PvInverter_StatusCode_Startup3:
			//% "Startup 3"
			return qsTrId("pvinverters_statusCode_startup_3")
		case VenusOS.PvInverter_StatusCode_Startup4:
			//% "Startup 4"
			return qsTrId("pvinverters_statusCode_startup_4")
		case VenusOS.PvInverter_StatusCode_Startup5:
			//% "Startup 5"
			return qsTrId("pvinverters_statusCode_startup_5")
		case VenusOS.PvInverter_StatusCode_Startup6:
			//% "Startup 6"
			return qsTrId("pvinverters_statusCode_startup_6")
		case VenusOS.PvInverter_StatusCode_Running:
			//% "Running"
			return qsTrId("pvinverters_statusCode_running")
		case VenusOS.PvInverter_StatusCode_Standby:
			//% "Standby"
			return qsTrId("pvinverters_statusCode_standby")
		case VenusOS.PvInverter_StatusCode_BootLoading:
			//% "Boot loading"
			return qsTrId("pvinverters_statusCode_boot_loading")
		case VenusOS.PvInverter_StatusCode_Error:
			//% "Error"
			return qsTrId("pvinverters_statusCode_error")
		case VenusOS.PvInverter_StatusCode_RunningMPPT:
			//% "Running (MPPT)"
			return qsTrId("pvinverters_statusCode_running_mppt")
		case VenusOS.PvInverter_StatusCode_RunningThrottled:
			//% "Running (Throttled)"
			return qsTrId("pvinverters_statusCode_running_throttled")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.pvInverters = root
}
