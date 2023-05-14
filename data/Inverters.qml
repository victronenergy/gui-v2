/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "inverter"
	}

	function addInverter(inverter) {
		model.addObject(inverter)
	}

	function removeInverter(inverter) {
		model.removeObject(inverter.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function inverterModeToText(m) {
		switch (m) {
		case VenusOS.Inverters_Mode_On:
			return CommonWords.onOrOff(1)
		case VenusOS.Inverters_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("inverters_mode_charger_only")
		case VenusOS.Inverters_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("inverters_mode_inverter_only")
		case VenusOS.Inverters_Mode_Off:
			return CommonWords.onOrOff(0)
		default:
			return ""
		}
	}

	function inverterStateToText(s) {
		switch (s) {
		case VenusOS.System_State_Off:
			//: System state = 'Off'
			//% "Off"
			return qsTrId("inverters_state_off")
		case VenusOS.System_State_LowPower:
			//: System state = 'Low power'
			//% "Low power"
			return qsTrId("inverters_state_lowpower")
		case VenusOS.System_State_FaultCondition:
			//: System state = 'Fault condition'
			//% "Fault"
			return qsTrId("inverters_state_faultcondition")
		case VenusOS.System_State_BulkCharging:
			//: System state = 'Bulk charging'
			//% "Bulk"
			return qsTrId("inverters_state_bulkcharging")
		case VenusOS.System_State_AbsorptionCharging:
			//: System state = 'Absorption charging'
			//% "Absorption"
			return qsTrId("inverters_state_absorptioncharging")
		case VenusOS.System_State_FloatCharging:
			//: System state = 'Float charging'
			//% "Float"
			return qsTrId("inverters_state_floatcharging")
		case VenusOS.System_State_StorageMode:
			//: System state = 'Storage mode'
			//% "Storage"
			return qsTrId("inverters_state_storagemode")
		case VenusOS.System_State_EqualizationCharging:
			//: System state = 'Equalization charging'
			//% "Equalize"
			return qsTrId("inverters_state_equalisationcharging")
		case VenusOS.System_State_PassThrough:
			//: System state = 'Pass-thru'
			//% "Pass-through"
			return qsTrId("inverters_state_passthrough")
		case VenusOS.System_State_Inverting:
			//: System state = 'Inverting'
			//% "Inverting"
			return qsTrId("inverters_state_inverting")
		case VenusOS.System_State_Assisting:
			//: System state = 'Assisting'
			//% "Assisting"
			return qsTrId("inverters_state_assisting")
		case VenusOS.System_State_Discharging:
			//: System state = 'Discharging'
			//% "Discharging"
			return qsTrId("inverters_state_discharging")
		}
		return ""
	}

	Component.onCompleted: Global.inverters = root
}
