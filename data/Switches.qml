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

	function switchStatusToText(val) {
		switch (val) {
		//channel status
		case VenusOS.Switch_Status_Output_Fault:
			//% "Output fault"
			return qsTrId("Switch_Output_Fault")
		case VenusOS.Switch_Status_Disabled:
			return CommonWords.disabled
		case VenusOS.Switch_Status_Powered:
			//% "Powered"
			return qsTrId("Switch_Input_Active")

		case VenusOS.Switch_Status_Off:
			return CommonWords.off
		case VenusOS.Switch_Status_On:
			return CommonWords.on
		case VenusOS.Switch_Status_Over_Temperature:
			//% "Over temperature"
			return qsTrId("Switches_Over_temperature")
		case VenusOS.Switch_Status_Short_Fault:
			//% "Short"
			return qsTrId("Switches_short") //move to common
		case VenusOS.Switch_Status_Tripped:
			//% "Tripped"
			return qsTrId("Switches_tripped")//move to common

		//module state
		case VenusOS.Switch_ModuleState_Channel_Fault:
			//% "Channel Fault"
			return qsTrId("Switches_Channel_fault")
		case VenusOS.Switch_ModuleState_Channel_Tripped:
			//% "Channel Tripped"
			return qsTrId("Switches_Channel_Trippped")
		case VenusOS.Switch_ModuleState_Connected:
			return CommonWords.running_status
		case VenusOS.Switch_ModuleState_Over_Temperature:
			//% "Over temperature"
			return qsTrId("Switches_Over_temperature")
		case VenusOS.Switch_ModuleState_Temperature_Warning:
			//% "Temperature Warning"
			return qsTrId("Switches_temperature_warning")
		case VenusOS.Switch_ModuleState_Under_Voltage:
			//% "Under voltage"
			return qsTrId("Switches_under_voltage")
		default:
			return val
		}
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


		case VenusOS.Switch_Status_Disabled:
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

	function switchStateToText(val) {
		switch (val) {
		case 0:
			return CommonWords.off
		case 1:
			return CommonWords.on
		default:
			return ""
		}
	}

	function switchFunctionToText(val,channel){
		switch (val) {
		case VenusOS.Switch_Function_Momentary:
			//% "Momentary"
			return qsTrId("Switches_Momentary")
		case VenusOS.Switch_Function_Latching:
			//% "Latching"
			return qsTrId("Switches_Latching")
		case VenusOS.Switch_Function_Dimmable:
			//% "Dimmable"
			return qsTrId("Switches_Dimmable")
		case VenusOS.Switch_Function_Slave:
			//% "Slave of %1"
			if (channel) return qsTrId("Switches_SlaveOf").arg(channel)
			//% "Slave"
			 else return qsTrId("Switches_Slave")
		default:
			//% "Undefined"
			return qsTrId("Switches_Undefined")
		}
	}

	Component.onCompleted: Global.switches = root
}
