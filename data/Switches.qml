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


	function switchableOutputStatusToColor(val,text) {

		switch (val) {
		//channel status

		case VenusOS.SwitchableOutput_Status_Off:
			if (text) return Theme.color_white
			else return Theme.color_gray8
		case VenusOS.SwitchableOutput_Status_Powered:
		case VenusOS.SwitchableOutput_Status_On:
			if (text) return Theme.color_switchableStatusText_ok
				else return Theme.color_switchableStatus_ok

		case VenusOS.SwitchableOutput_Status_Output_Fault:
			if (text) return Theme.color_switchableStatusText_warning
				else return Theme.color_switchableStatus_warning

		case VenusOS.SwitchableOutput_Status_Disabled:
		case VenusOS.SwitchableOutput_Status_TripLowVoltage:
		case VenusOS.SwitchableOutput_Status_Over_Temperature:
		case VenusOS.SwitchableOutput_Status_Short_Fault:
		case VenusOS.SwitchableOutput_Status_Tripped:

			if (text) return Theme.color_switchableStatusText_critical
				else return Theme.color_switchableStatus_critical

		default:
			if (text) return Theme.color_switchableStatusText_critical
				else return Theme.color_switchableStatus_critical
		}
	}
	function switchesOutputStatusToColor(val,text) {

		switch (val) {
		case VenusOS.Switch_ModuleState_Channel_Fault:
		case VenusOS.Switch_ModuleState_Channel_Tripped:
		case VenusOS.Switch_ModuleState_Over_Temperature:
			if (text) return Theme.color_switchableStatusText_critical
				else return Theme.color_switchableStatus_critical

		case VenusOS.Switch_ModuleState_Connected:
			if (text) return Theme.color_switchableStatus_ok
				else return Theme.color_switchableStatusText_ok

		case VenusOS.Switch_ModuleState_Temperature_Warning:
		case VenusOS.Switch_ModuleState_Under_Voltage:
			if (text) return Theme.color_switchableStatusText_warning
				else return Theme.color_switchableStatus_warning

		default:
			if (text) return Theme.color_switchableStatusText_critical
				else return Theme.color_switchableStatus_critical
		}
	}



	Component.onCompleted: Global.switches = root
}
