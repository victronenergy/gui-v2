/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


Device {
	id: switchDev

	readonly property int state: _state.isValid ? _state.value : -1

	readonly property VeQuickItem _state: VeQuickItem {
		uid: switchDev.serviceUid + "/State"
	}
	property VeQItemTableModel channels: VeQItemTableModel {
		uids:  switchDev.serviceUid + "/Channel"
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	function switchStatusToText(val) {
		switch (val) {
		//channel status
		case VenusOS.Switch_Status_Active:
			return qsTrId("switchDev_active")
		case VenusOS.Switch_Status_Disabled:
			return CommonWords.disabled
		case VenusOS.Switch_Status_Input_Active:
			return CommonWords.active_status
		case VenusOS.Switch_Status_Off:
			return CommonWords.off
		case VenusOS.Switch_Status_On:
			return CommonWords.on
		case VenusOS.Switch_Status_Over_Temperature:
			return qsTrId("switchDev_Over_temperature")
		case VenusOS.Switch_Status_Short_Fault:
			return qsTrId("switchDev_short") //move to common
		case VenusOS.Switch_Status_Tripped:
			return qsTrId("switchDev_tripped")//move to common

		//module state
		case VenusOS.Switch_ModuleState_Channel_Fault:
			return qsTrId("switchDev_Channel_fault")
		case VenusOS.Switch_ModuleState_Channel_Tripped:
			return qsTrId("switchDev_Channel_Trippped")
		case VenusOS.Switch_ModuleState_Connected:
			return CommonWords.connected
		case VenusOS.Switch_ModuleState_Over_Temperature:
			return qsTrId("switchDev_Over_temperature")
		case VenusOS.Switch_ModuleState_Temperature_Warning:
			return qsTrId("switchDev_temperature_warning")
		case VenusOS.Switch_ModuleState_Under_Voltage:
			return qsTrId("switchDev_under_voltage")
		default:
			return ""
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

    function switchStatusToColor(val) {
        switch (val) {
        //channel status


        case VenusOS.Switch_Status_Disabled:
        case VenusOS.Switch_Status_Off:
        return {color:"WHITE"}

        case VenusOS.Switch_Status_Input_Active:
        case VenusOS.Switch_Status_On:
        case VenusOS.Switch_Status_Active:
            return {color: "GREEN"}

        case VenusOS.Switch_Status_Over_Temperature:
        case VenusOS.Switch_Status_Short_Fault:
        case VenusOS.Switch_Status_Tripped:
            return {color:"RED"}

        //module state
        case VenusOS.Switch_ModuleState_Channel_Fault:
        case VenusOS.Switch_ModuleState_Channel_Tripped:
        case VenusOS.Switch_ModuleState_Over_Temperature:
            return "RED"

        case VenusOS.Switch_ModuleState_Connected:
            return {color:"GREEN"}

        case VenusOS.Switch_ModuleState_Temperature_Warning:
        case VenusOS.Switch_ModuleState_Under_Voltage:
            return {color:"YELLOW"}

        default:
            return {color:"RED"}
        }
    }

	function switchFunctionToText(val){
		switch (val) {
		case VenusOS.Switch_Function_Momentary:
			return qsTrId("Momentary")
		case VenusOS.Switch_Function_Latching:
			return qsTrId("Latching")
		case VenusOS.Switch_Function_Dimmable:
			return qsTrId("Dimmable")
		default:
			return qsTrId("undefined")
		}

        // switch (val) {
        // case VenusOS.Switch_Function_Momentary:
        //     return qsTrId("Switches_Momentary")
        // case VenusOS.Switch_Function_Latching:
        //     return qsTrId("Switches_Latching")
        // case VenusOS.Switch_Function_Dimmable:
        //     return qsTrId("Switches_Dimmable")
        // default:
        //     return qsTrId("Switches_Undefined")
        // }
	}


	onValidChanged: {
		if (!!Global.switches) {
			if (valid) {
				Global.switches.model.addDevice(switchDev)
			} else {
				Global.switches.model.removeDevice(switchDev.serviceUid)
			}
		}
	}
}
