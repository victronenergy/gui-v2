/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
		case Enums.PvInverter_StatusCode_Startup0:
		case Enums.PvInverter_StatusCode_Startup1:
		case Enums.PvInverter_StatusCode_Startup2:
		case Enums.PvInverter_StatusCode_Startup3:
		case Enums.PvInverter_StatusCode_Startup4:
		case Enums.PvInverter_StatusCode_Startup5:
		case Enums.PvInverter_StatusCode_Startup6:
			return CommonWords.startup_status.arg(statusCode)
		case Enums.PvInverter_StatusCode_Running:
			return CommonWords.running_status
		case Enums.PvInverter_StatusCode_Standby:
			return CommonWords.standby
		case Enums.PvInverter_StatusCode_BootLoading:
			//% "Boot loading"
			return qsTrId("pvinverters_statusCode_boot_loading")
		case Enums.PvInverter_StatusCode_Error:
			return CommonWords.error
		case Enums.PvInverter_StatusCode_RunningMPPT:
			//% "Running (MPPT)"
			return qsTrId("pvinverters_statusCode_running_mppt")
		case Enums.PvInverter_StatusCode_RunningThrottled:
			//% "Running (Throttled)"
			return qsTrId("pvinverters_statusCode_running_throttled")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.pvInverters = root
}
