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

QString Enums::battery_iconFromMode(Battery_Mode mode) const
{
	switch (mode) {
	case Battery_Mode_Charging:
		return "qrc:/images/icon_battery_charging_24.svg";
	case Battery_Mode_Discharging:
		return "qrc:/images/icon_battery_discharging_24.svg";
	default:
		return "qrc:/images/icon_battery_24.svg";
	}
}

QString Enums::dcInput_typeToText(DcInputs_InputType type) const
{
	switch (type) {
	case DcInputs_InputType_AcCharger:
		//% "AC charger"
		return qtTrId("dcInputs_ac_charger");
	case DcInputs_InputType_Alternator:
		//% "Alternator"
		return qtTrId("dcInputs_alternator");
	case DcInputs_InputType_DcCharger:
		//% "DC charger"
		return qtTrId("dcInputs_dccharger");
	case DcInputs_InputType_DcGenerator:
		//% "DC generator"
		return qtTrId("dcInputs_dc_generator");
	case DcInputs_InputType_DcSystem:
		//% "DC system"
		return qtTrId("dcInputs_dc_system");
	case DcInputs_InputType_FuelCell:
		//% "Fuel cell"
		return qtTrId("dcInputs_fuelcell");
	case DcInputs_InputType_ShaftGenerator:
		//% "Shaft generator"
		return qtTrId("dcInputs_shaft_generator");
	case DcInputs_InputType_WaterGenerator:
		//% "Water generator"
		return qtTrId("dcInputs_water_generator");
	case DcInputs_InputType_Wind:
		//% "Wind"
		return qtTrId("dcInputs_wind");
	}
	return QString();
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

QString Enums::pvInverter_statusCodeToText(PvInverter_StatusCode statusCode) const
{
	switch (statusCode) {
	case PvInverter_StatusCode_Startup0:
	case PvInverter_StatusCode_Startup1:
	case PvInverter_StatusCode_Startup2:
	case PvInverter_StatusCode_Startup3:
	case PvInverter_StatusCode_Startup4:
	case PvInverter_StatusCode_Startup5:
	case PvInverter_StatusCode_Startup6:
		//: PV inverter status code. %1 = the startup status number
		//% "Startup (%1)"
		return qtTrId("pvinverter_statusCode_startup").arg(statusCode);
	case PvInverter_StatusCode_Running:
		//: PV inverter status code
		//% "Running"
		return qtTrId("pvinverter_statusCode_running");
	case PvInverter_StatusCode_Standby:
		//: PV inverter status code
		//% "Standby"
		return qtTrId("pvinverter_statusCode_standby");
	case PvInverter_StatusCode_BootLoading:
		//: PV inverter status code
		//% "Boot loading"
		return qtTrId("pvinverters_statusCode_boot_loading");
	case PvInverter_StatusCode_Error:
		//: PV inverter status code
		//% "Error"
		return qtTrId("pvinverter_statusCode_error");
	case PvInverter_StatusCode_RunningMPPT:
		//: PV inverter status code
		//% "Running (MPPT)"
		return qtTrId("pvinverter_statusCode_running_mppt");
	case PvInverter_StatusCode_RunningThrottled:
		//: PV inverter status code
		//% "Running (Throttled)"
		return qtTrId("pvinverter_running_throttled");
	default:
		return QString();
	}
}

QString Enums::solarCharger_stateToText(SolarCharger_State state) const
{
	switch (state) {
	case SolarCharger_State_Off:
		//% "Off"
		return qtTrId("solarchargers_state_off");
	case SolarCharger_State_Fault:
		//% "Fault"
		return qtTrId("solarchargers_state_fault");
	case SolarCharger_State_Bulk:
		//% "Bulk"
		return qtTrId("solarchargers_state_bulk");
	case SolarCharger_State_Absorption:
		//% "Absorption"
		return qtTrId("solarchargers_state_absorption");
	case SolarCharger_State_Float:
		//% "Float"
		return qtTrId("solarchargers_state_float");
	case SolarCharger_State_Storage:
		//% "Storage"
		return qtTrId("solarchargers_state_storage");
	case SolarCharger_State_Equalize:
		//% "Equalize"
		return qtTrId("solarchargers_state_equalize");
	case SolarCharger_State_ExternalControl:
		//% "External control"
		return qtTrId("solarchargers_state_external control");
	default:
		return QString();
	}
}

QString Enums::switch_deviceStateToText(Switch_DeviceState value) const
{
	switch (value) {
	case Switch_DeviceState_Connected:
		//% "Running"
		return qtTrId("switch_state_running");
	case Switch_DeviceState_Over_Temperature:
		//% "Over temperature"
		return qtTrId("switch_state_over_temperature");
	case Switch_DeviceState_Temperature_Warning:
		//% "Temperature warning"
		return qtTrId("switch_state_temperature_warning");
	case Switch_DeviceState_Channel_Fault:
		//% "Channel Fault"
		return qtTrId("switch_state_channel_fault");
	case Switch_DeviceState_Channel_Tripped:
		//% "Channel Tripped"
		return qtTrId("switch_state_channel_Trippped");
	case Switch_DeviceState_Under_Voltage:
		//% "Under voltage"
		return qtTrId("switch_state_under_voltage");
	default:
		return QString::number(static_cast<int>(value));
	}
}

QString Enums::switchableOutput_typeToText(SwitchableOutput_Type value, const QString &channelId) const
{
	switch (value) {
	case SwitchableOutput_Type_Momentary:
		//% "Momentary"
		return qtTrId("switchable_output_momentary");
	case SwitchableOutput_Type_Latching:
		//% "Latching"
		return qtTrId("switchable_output_latching");
	case SwitchableOutput_Type_Dimmable:
		//% "Dimmable"
		return qtTrId("switchable_output_dimmable");
	case SwitchableOutput_Type_Slave:
		//% "Slave of %1"
		if (channelId.length() > 0) {
			return qtTrId("switchable_output_slave_of").arg(channelId);
		} else {
			//% "Slave"
			return qtTrId("switchable_output_slave");
		}
	default:
		//% "Unsupported type: %1"
		return qtTrId("switchable_output_unsupported").arg(value);
	}
}

QString Enums::switchableOutput_statusToText(SwitchableOutput_Status value) const{

	switch (value) {
	case SwitchableOutput_Status_Off:
		//% "Off"
		return qtTrId("switchable_output_off");
	case SwitchableOutput_Status_Powered:
		//% "Powered"
		return qtTrId("switchable_output_powered");
	case SwitchableOutput_Status_Tripped:
		//% "Tripped"
		return qtTrId("switchable_output_tripped");
	case SwitchableOutput_Status_Over_Temperature:
		//% "Over temperature"
		return qtTrId("switchable_output_over_temperature");
	case SwitchableOutput_Status_Output_Fault:
		//% "Output fault"
		return qtTrId("switchable_output_output_Fault");
	case SwitchableOutput_Status_On:
		//% "On"
		return qtTrId("switchable_output_on");
	case SwitchableOutput_Status_Short_Fault:
		//% "Short"
		return qtTrId("switchable_output_short");
	case SwitchableOutput_Status_Disabled:
		//% "Disabled"
		return qtTrId("switchable_output_disabled");
	case SwitchableOutput_Status_TripLowVoltage:
		//% "Disabled"
		return qtTrId("switchable_output_trip_low_voltage");
	default:
		return QString::number(static_cast<int>(value));
	}
}

}
}
