/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "pvInverters"
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
		case VenusOS.PvInverter_StatusCode_Startup1:
		case VenusOS.PvInverter_StatusCode_Startup2:
		case VenusOS.PvInverter_StatusCode_Startup3:
		case VenusOS.PvInverter_StatusCode_Startup4:
		case VenusOS.PvInverter_StatusCode_Startup5:
		case VenusOS.PvInverter_StatusCode_Startup6:
			return CommonWords.startup_status.arg(statusCode)
		case VenusOS.PvInverter_StatusCode_Running:
			return CommonWords.running_status
		case VenusOS.PvInverter_StatusCode_Standby:
			return CommonWords.standby
		case VenusOS.PvInverter_StatusCode_BootLoading:
			//% "Boot loading"
			return qsTrId("pvinverters_statusCode_boot_loading")
		case VenusOS.PvInverter_StatusCode_Error:
			return CommonWords.error
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
