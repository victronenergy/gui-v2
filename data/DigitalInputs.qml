/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "digitalInputs"
	}

	function inputTypeToText(type) {
		switch (type) {
		case VenusOS.DigitalInput_Type_Disabled:
			return CommonWords.disabled
		case VenusOS.DigitalInput_Type_PulseMeter:
			//% "Pulse meter"
			return qsTrId("digitalinputs_type_pulsemeter")
		case VenusOS.DigitalInput_Type_DoorAlarm:
			//% "Door alarm"
			return qsTrId("digitalinputs_type_dooralarm")
		case VenusOS.DigitalInput_Type_BilgePump:
			//% "Bilge pump"
			return qsTrId("digitalinputs_type_bilgepump")
		case VenusOS.DigitalInput_Type_BilgeAlarm:
			//% "Bilge alarm"
			return qsTrId("digitalinputs_type_bilgealarm")
		case VenusOS.DigitalInput_Type_BurglarAlarm:
			//% "Burglar alarm"
			return qsTrId("digitalinputs_type_burglaralarm")
		case VenusOS.DigitalInput_Type_SmokeAlarm:
			//% "Smoke alarm"
			return qsTrId("digitalinputs_type_smokealarm")
		case VenusOS.DigitalInput_Type_FireAlarm:
			//% "Fire alarm"
			return qsTrId("digitalinputs_type_firealarm")
		case VenusOS.DigitalInput_Type_CO2Alarm:
			//% "CO2 alarm"
			return qsTrId("digitalinputs_type_co2alarm")
		case VenusOS.DigitalInput_Type_Generator:
			//% "Generator"
			return qsTrId("digitalinputs_type_generator")
		default:
			return ""
		}
	}

	function inputStateToText(state) {
		switch (state) {
		case VenusOS.DigitalInput_State_Low:
			//% "Low"
			return qsTrId("digitalinputs_state_low")
		case VenusOS.DigitalInput_State_High:
			//% "High"
			return qsTrId("digitalinputs_state_high")
		case VenusOS.DigitalInput_State_Off:
			return CommonWords.off
		case VenusOS.DigitalInput_State_On:
			return CommonWords.on
		case VenusOS.DigitalInput_State_No:
			return CommonWords.no
		case VenusOS.DigitalInput_State_Yes:
			return CommonWords.yes
		case VenusOS.DigitalInput_State_Open:
			return CommonWords.open_status
		case VenusOS.DigitalInput_State_Closed:
			return CommonWords.closed_status
		case VenusOS.DigitalInput_State_OK:
			return CommonWords.ok
		case VenusOS.DigitalInput_State_Alarm:
			//: Digital input is in 'alarm' state
			//% "Alarm"
			return qsTrId("digitalinputs_state_alarm")
		case VenusOS.DigitalInput_State_Running:
			return CommonWords.running_status
		case VenusOS.DigitalInput_State_Stopped:
			return CommonWords.stopped_status
		default:
			return ""
		}
	}

	Component.onCompleted: Global.digitalInputs = root
}
