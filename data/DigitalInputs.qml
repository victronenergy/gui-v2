/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "digitalInputs"
	}

	function inputTypeToText(type) {
		switch (type) {
		case Enums.DigitalInput_Type_Disabled:
			return CommonWords.disabled
		case Enums.DigitalInput_Type_PulseMeter:
			//% "Pulse meter"
			return qsTrId("digitalinputs_type_pulsemeter")
		case Enums.DigitalInput_Type_DoorAlarm:
			//% "Door alarm"
			return qsTrId("digitalinputs_type_dooralarm")
		case Enums.DigitalInput_Type_BilgePump:
			//% "Bilge pump"
			return qsTrId("digitalinputs_type_bilgepump")
		case Enums.DigitalInput_Type_BilgeAlarm:
			//% "Bilge alarm"
			return qsTrId("digitalinputs_type_bilgealarm")
		case Enums.DigitalInput_Type_BurglarAlarm:
			//% "Burglar alarm"
			return qsTrId("digitalinputs_type_burglaralarm")
		case Enums.DigitalInput_Type_SmokeAlarm:
			//% "Smoke alarm"
			return qsTrId("digitalinputs_type_smokealarm")
		case Enums.DigitalInput_Type_FireAlarm:
			//% "Fire alarm"
			return qsTrId("digitalinputs_type_firealarm")
		case Enums.DigitalInput_Type_CO2Alarm:
			//% "CO2 alarm"
			return qsTrId("digitalinputs_type_co2alarm")
		case Enums.DigitalInput_Type_Generator:
			//% "Generator"
			return qsTrId("digitalinputs_type_generator")
		default:
			return ""
		}
	}

	function inputStateToText(state) {
		switch (state) {
		case Enums.DigitalInput_State_Low:
			//% "Low"
			return qsTrId("digitalinputs_state_low")
		case Enums.DigitalInput_State_High:
			//% "High"
			return qsTrId("digitalinputs_state_high")
		case Enums.DigitalInput_State_Off:
			return CommonWords.off
		case Enums.DigitalInput_State_On:
			return CommonWords.on
		case Enums.DigitalInput_State_No:
			return CommonWords.no
		case Enums.DigitalInput_State_Yes:
			return CommonWords.yes
		case Enums.DigitalInput_State_Open:
			return CommonWords.open_status
		case Enums.DigitalInput_State_Closed:
			return CommonWords.closed_status
		case Enums.DigitalInput_State_OK:
			return CommonWords.ok
		case Enums.DigitalInput_State_Alarm:
			//: Digital input is in 'alarm' state
			//% "Alarm"
			return qsTrId("digitalinputs_state_alarm")
		case Enums.DigitalInput_State_Running:
			return CommonWords.running_status
		case Enums.DigitalInput_State_Stopped:
			return CommonWords.stopped_status
		default:
			return ""
		}
	}

	Component.onCompleted: Global.digitalInputs = root
}
