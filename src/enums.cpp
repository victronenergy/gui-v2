/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "enums.h"

namespace Victron {
namespace VenusOS {

Enums::Enums(QObject *parent)
	: QObject(parent)
{
}

Enums::~Enums()
{
}

QString Enums::battery_modeToText(Battery_Mode mode) const
{
	switch (mode) {
	case Battery_Mode_Idle:
		//: Battery mode
		//% "Idle"
		return qtTrId("battery_mode_idle");
	case Battery_Mode_Charging:
		//: Battery mode
		//% "Charging"
		return qtTrId("battery_mode_charging");
	case Battery_Mode_Discharging:
		//: Battery mode
		//% "Discharging"
		return qtTrId("battery_mode_discharging");
	default:
		return QString();
	}
}

Enums::Battery_Mode Enums::battery_modeFromPower(qreal power) const
{
	if (qIsNaN(power) || power == 0) {
		return Battery_Mode_Idle;
	} else if (power > 0) {
		return Battery_Mode_Charging;
	} else {
		return Battery_Mode_Discharging;
	}
}


QString Enums::digitalInput_typeToText(DigitalInput_Type type) const
{
	switch (type) {
	case DigitalInput_Type_Disabled:
		//% "Disabled"
		return qtTrId("digitalinputs_type_disabled");
	case DigitalInput_Type_PulseMeter:
		//% "Pulse meter"
		return qtTrId("digitalinputs_type_pulsemeter");
	case DigitalInput_Type_DoorAlarm:
		//% "Door alarm"
		return qtTrId("digitalinputs_type_dooralarm");
	case DigitalInput_Type_BilgePump:
		//% "Bilge pump"
		return qtTrId("digitalinputs_type_bilgepump");
	case DigitalInput_Type_BilgeAlarm:
		//% "Bilge alarm"
		return qtTrId("digitalinputs_type_bilgealarm");
	case DigitalInput_Type_BurglarAlarm:
		//% "Burglar alarm"
		return qtTrId("digitalinputs_type_burglaralarm");
	case DigitalInput_Type_SmokeAlarm:
		//% "Smoke alarm"
		return qtTrId("digitalinputs_type_smokealarm");
	case DigitalInput_Type_FireAlarm:
		//% "Fire alarm"
		return qtTrId("digitalinputs_type_firealarm");
	case DigitalInput_Type_CO2Alarm:
		//% "CO2 alarm"
		return qtTrId("digitalinputs_type_co2alarm");
	case DigitalInput_Type_Generator:
		//% "Generator"
		return qtTrId("digitalinputs_type_generator");
	case DigitalInput_Type_TouchInputControl:
		//% "Touch input control"
		return qtTrId("digitalinputs_touch_input_control");
	default:
		return QString();
	}
}

QString Enums::digitalInput_stateToText(DigitalInput_State state) const
{
	switch (state) {
	case DigitalInput_State_Low:
		//: Digital input state
		//% "Low"
		return qtTrId("digitalinputs_state_low");
	case DigitalInput_State_High:
		//: Digital input state
		//% "High"
		return qtTrId("digitalinputs_state_high");
	case DigitalInput_State_Off:
		//: Digital input state
		//% "Off"
		return qtTrId("digitalinputs_state_off");
	case DigitalInput_State_On:
		//: Digital input state
		//% "On"
		return qtTrId("digitalinputs_state_on");
	case DigitalInput_State_No:
		//: Digital input state
		//% "No"
		return qtTrId("digitalinputs_state_no");
	case DigitalInput_State_Yes:
		//: Digital input state
		//% "Yes"
		return qtTrId("digitalinputs_state_yes");
	case DigitalInput_State_Open:
		//: Digital input open
		//% "Open"
		return qtTrId("digitalinputs_state_open");
	case DigitalInput_State_Closed:
		//: Digital input state
		//% "Closed"
		return qtTrId("digitalinputs_state_closed");
	case DigitalInput_State_OK:
		//: Digital input state
		//% "OK"
		return qtTrId("digitalinputs_state_ok");
	case DigitalInput_State_Alarm:
		//: Digital input state
		//% "Alarm"
		return qtTrId("digitalinputs_state_alarm");
	case DigitalInput_State_Running:
		//: Digital input state
		//% "Running"
		return qtTrId("digitalinputs_state_running");
	case DigitalInput_State_Stopped:
		//: Digital input state
		//% "Stopped"
		return qtTrId("digitalinputs_state_stopped");
	default:
		return QString();
	}
}

}
}
