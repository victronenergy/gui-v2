/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "switches"
	}



	function switchStatusToColor(val,text) {
		var switchRedStatus = "#600000"
		var switchRedText = "#FF8080"
		var switchGreenStatus = "#006000"
		var switchGreenText = "#80FF80"
		var switchYellowStatus = "#705000"
		var switchYellowText = "#e0e050"

		switch (val) {
		//channel status

		case VenusOS.Switch_Status_Off:
			if (text) return "WHITE"
			else return "GREY"

		case VenusOS.Switch_Status_Powered:
		case VenusOS.Switch_Status_On:
			if (text) return switchGreenText
				else return switchGreenStatus

		case VenusOS.Switch_Status_Output_Fault:
			if (text) return switchYellowText
				else return switchYellowStatus

		case VenusOS.Switch_Status_Disabled:
		case VenusOS.Switch_Status_TripLowVoltage:
		case VenusOS.Switch_Status_Over_Temperature:
		case VenusOS.Switch_Status_Short_Fault:
		case VenusOS.Switch_Status_Tripped:

			if (text) return switchRedText
				else return switchRedStatus

		//module state
		case VenusOS.Switch_ModuleState_Channel_Fault:
		case VenusOS.Switch_ModuleState_Channel_Tripped:
		case VenusOS.Switch_ModuleState_Over_Temperature:
			if (text) return switchRedText
				else return switchRedStatus

		case VenusOS.Switch_ModuleState_Connected:
			if (text) return switchGreenStatus
				else return switchGreenText

		case VenusOS.Switch_ModuleState_Temperature_Warning:
		case VenusOS.Switch_ModuleState_Under_Voltage:
			if (text) return switchYellowText
				else return switchYellowStatus

		default:
			if (text) return switchRedText
				else return switchRedStatus
		}
	}



	Component.onCompleted: Global.switches = root
}
