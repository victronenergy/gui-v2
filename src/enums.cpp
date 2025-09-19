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

Enums::DcMeter_Type Enums::dcMeter_type(const QString &serviceType, int monitorMode) const
{
	// These service types directly reflect the DC meter type, regardless of the /MonitorMode value.
	static const QHash<QString, DcMeter_Type> serviceTypes = {
		{ QStringLiteral("alternator"), DcMeter_Type_Alternator },
		{ QStringLiteral("dcsystem"), DcMeter_Type_DcSystem },
		{ QStringLiteral("fuelcell"), DcMeter_Type_FuelCell },
		{ QStringLiteral("dcgenset"), DcMeter_Type_Genset },
		{ QStringLiteral("motordrive"), DcMeter_Type_ElectricDrive },
		{ QStringLiteral("solarcharger"), DcMeter_Type_SolarCharger },
	};
	if (const auto it = serviceTypes.find(serviceType); it != serviceTypes.end()) {
		return it.value();
	}

	// For dcload and dcsource services, the /MonitorMode indicates the type of DC load/source.
	if (serviceType == "dcsource") {
		switch (monitorMode) {
		case MonitorMode_DcSource_Generic: return DcMeter_Type_GenericSource;
		case MonitorMode_DcSource_AcCharger: return DcMeter_Type_AcCharger;
		case MonitorMode_DcSource_DcCharger: return DcMeter_Type_DcCharger;
		case MonitorMode_DcSource_WaterGenerator: return DcMeter_Type_WaterGenerator;
		case MonitorMode_DcSource_ShaftGenerator: return DcMeter_Type_ShaftGenerator;
		case MonitorMode_DcSource_WindCharger: return DcMeter_Type_WindCharger;
		default: return DcMeter_Type_GenericSource;
		}
	} else if (serviceType == "dcload") {
		switch (monitorMode) {
		case MonitorMode_DcLoad_Generic: return DcMeter_Type_GenericLoad;
		case MonitorMode_DcLoad_Fridge: return DcMeter_Type_Fridge;
		case MonitorMode_DcLoad_WaterPump: return DcMeter_Type_WaterPump;
		case MonitorMode_DcLoad_BilgePump: return DcMeter_Type_BilgePump;
		case MonitorMode_DcLoad_Inverter: return DcMeter_Type_Inverter;
		case MonitorMode_DcLoad_WaterHeater: return DcMeter_Type_WaterHeater;
		default: return DcMeter_Type_GenericLoad;
		}
	} else {
		return DcMeter_Type_GenericMeter;
	}
}

QString Enums::dcMeter_typeToText(DcMeter_Type type) const
{
	switch (type) {
	case DcMeter_Type_AcCharger:
		//% "AC charger"
		return qtTrId("dcMeter_ac_charger");
	case DcMeter_Type_Alternator:
		//% "Alternator"
		return qtTrId("dcMeter_alternator");
	case DcMeter_Type_BilgePump:
		//% "Bilge pump"
		return qtTrId("dcMeter_bilge_pump");
	case DcMeter_Type_DcCharger:
		//% "DC/DC charger"
		return qtTrId("dcMeter_dccharger");
	case DcMeter_Type_DcSystem:
		//% "DC system"
		return qtTrId("dcMeter_dc_system");
	case DcMeter_Type_ElectricDrive:
		//% "Electric drive"
		return qtTrId("dcMeter_electric_drive");
	case DcMeter_Type_Fridge:
		//% "Fridge"
		return qtTrId("dcMeter_fridge");
	case DcMeter_Type_FuelCell:
		//% "Fuel cell"
		return qtTrId("dcMeter_fuelcell");
	case DcMeter_Type_GenericLoad:
		//% "Generic load"
		return qtTrId("dcMeter_generic_load");
	case DcMeter_Type_GenericMeter:
		//% "Generic meter"
		return qtTrId("dcMeter_generic_meter");
	case DcMeter_Type_GenericSource:
		//% "Generic source"
		return qtTrId("dcMeter_generic_source");
	case DcMeter_Type_Genset:
		//% "DC genset"
		return qtTrId("dcMeter_dc_genset");
	case DcMeter_Type_Inverter:
		//% "Inverter"
		return qtTrId("dcMeter_inverter");
	case DcMeter_Type_ShaftGenerator:
		//% "Shaft generator"
		return qtTrId("dcMeter_shaft_generator");
	case DcMeter_Type_SolarCharger:
		//% "Solar charger"
		return qtTrId("dcMeter_solar_charger");
	case DcMeter_Type_WaterGenerator:
		//% "Water generator"
		return qtTrId("dcMeter_water_generator");
	case DcMeter_Type_WaterHeater:
		//% "Water heater"
		return qtTrId("dcMeter_water_heater");
	case DcMeter_Type_WaterPump:
		//% "Water pump"
		return qtTrId("dcMeter_water_pump");
	case DcMeter_Type_WindCharger:
		//% "Wind charger"
		return qtTrId("dcMeter_wind_charger");
	}
	return QString();
}

QString Enums::dcMeter_iconForType(DcMeter_Type type) const
{
	switch (type) {
	case DcMeter_Type_Alternator:
		return "qrc:/images/alternator.svg";
	case DcMeter_Type_GenericSource:
		return "qrc:/images/generator.svg";
	case DcMeter_Type_WindCharger:
		return "qrc:/images/wind.svg";
	default:
		return "qrc:/images/icon_dc_24.svg";
	}
}

QString Enums::dcMeter_iconForMultipleTypes() const
{
	return "qrc:/images/icon_dc_24.svg";
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
	case SwitchableOutput_Type_Toggle:
		//% "Toggle"
		return qtTrId("switchable_output_toggle");
	case SwitchableOutput_Type_Dimmable:
		//% "Dimmable"
		return qtTrId("switchable_output_dimmable");
	case SwitchableOutput_Type_TemperatureSetpoint:
		//% "Temperature setpoint"
		return qtTrId("switchable_output_temperature_setpoint");
	case SwitchableOutput_Type_SteppedSwitch:
		//% "Stepped switch"
		return qtTrId("switchable_output_Stepped_Switch");
	case SwitchableOutput_Type_Slave:
		//% "Slave of %1"
		if (channelId.length() > 0) {
			return qtTrId("switchable_output_slave_of").arg(channelId);
		} else {
			//% "Slave"
			return qtTrId("switchable_output_slave");
		}
	case SwitchableOutput_Type_Dropdown:
		//% "Dropdown"
		return qtTrId("switchable_output_dropdown");
	case SwitchableOutput_Type_BasicSlider:
		//% "Basic slider"
		return qtTrId("switchable_output_basic_slider");
	case SwitchableOutput_Type_NumericInput:
		//% "Numeric input"
		return qtTrId("switchable_output_numeric_input");
	case SwitchableOutput_Type_ThreeStateSwitch:
		//% "Three-state switch"
		return qtTrId("switchable_output_three_state_switch");
	case SwitchableOutput_Type_BilgePump:
		//% "Bilge pump"
		return qtTrId("switchable_output_bilge_pump");
	default:
		//% "Unsupported type: %1"
		return qtTrId("switchable_output_unsupported").arg(value);
	}
}

QString Enums::switchableOutput_statusToText(SwitchableOutput_Status value, SwitchableOutput_Type type) const
{
	switch (value) {
	case SwitchableOutput_Status_Off:
		if (type == SwitchableOutput_Type_BilgePump) {
			//% "Not running"
			return qtTrId("switchable_output_not_running");
		} else {
			//% "Off"
			return qtTrId("switchable_output_off");
		}
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
		//% "Fault"
		return qtTrId("switchable_output_fault");
	case SwitchableOutput_Status_On:
		if (type == SwitchableOutput_Type_BilgePump) {
			//% "Running"
			return qtTrId("switchable_output_running");
		} else {
			//% "On"
			return qtTrId("switchable_output_on");
		}
	case SwitchableOutput_Status_Short_Fault:
		//% "Short"
		return qtTrId("switchable_output_short");
	case SwitchableOutput_Status_Disabled:
		//% "Disabled"
		return qtTrId("switchable_output_disabled");
	case SwitchableOutput_Status_TripLowVoltage:
		//% "Trip low voltage"
		return qtTrId("switchable_output_trip_low_voltage");
	default:
		return QString::number(static_cast<int>(value));
	}
}

QString Enums::tank_fluidTypeToText(Tank_Type type) const
{
	switch (type) {
	case Tank_Type_Fuel:
		//% "Fuel"
		return qtTrId("tank_type_fuel");
	case Tank_Type_FreshWater:
		//% "Fresh water"
		return qtTrId("tank_type_fresh_water");
	case Tank_Type_WasteWater:
		//% "Waste water"
		return qtTrId("tank_type_waste_water");
	case Tank_Type_LiveWell:
		//% "Live well"
		return qtTrId("tank_type_live_well");
	case Tank_Type_Oil:
		//% "Oil"
		return qtTrId("tank_type_oil");
	case Tank_Type_BlackWater:
		//% "Black water"
		return qtTrId("tank_type_black_water");
	case Tank_Type_Gasoline:
		//% "Gasoline"
		return qtTrId("tank_type_gasoline");
	case Tank_Type_Diesel:
		//% "Diesel"
		return qtTrId("tank_type_diesel");
	case Tank_Type_LPG:
		//% "LPG"
		return qtTrId("tank_type_lpg");
	case Tank_Type_LNG:
		//% "LNG"
		return qtTrId("tank_type_lng");
	case Tank_Type_HydraulicOil:
		//% "Hydraulic oil"
		return qtTrId("tank_type_hydraulic_oil");
	case Tank_Type_RawWater:
		//% "Raw water"
		return qtTrId("tank_type_raw_water");
	default:
		return QString();
	}
}

Enums* Enums::create(QQmlEngine *engine, QJSEngine *jsEngine)
{
	Q_UNUSED(engine)
	Q_UNUSED(jsEngine)

	static Enums *instance = new Enums;
	return instance;
}

}
}
