/*
** Copyright (C) 2022 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_ENUMS_H
#define VICTRON_VENUSOS_GUI_V2_ENUMS_H

#include <QQmlEngine>
#include <QObject>

namespace Victron {
namespace VenusOS {

/*
** Define all enums here in C++ rather than in QML files.
*/

class Enums : public QObject
{
	Q_OBJECT

public:
	explicit Enums(QObject *parent = nullptr);
	~Enums() override;

	static QObject* instance(QQmlEngine *engine, QJSEngine *);

	enum AsymmetricRoundedRectangle_RoundedSide {
		AsymmetricRoundedRectangle_RoundedSide_All,    // allow all sides to be rounded, show all borders
		AsymmetricRoundedRectangle_RoundedSide_Left,   // round left, hide right border
		AsymmetricRoundedRectangle_RoundedSide_Right,  // round right, hide left border
		AsymmetricRoundedRectangle_RoundedSide_Top,    // round top, hide bottom border
		AsymmetricRoundedRectangle_RoundedSide_Bottom, // round bottom, hide top border
		AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal // no rounding, show top/bottom borders only
	};
	Q_ENUM(AsymmetricRoundedRectangle_RoundedSide)

	enum EnvironmentGaugePanel_Size {
		EnvironmentGaugePanel_Size_Compact,
		EnvironmentGaugePanel_Size_Expanded
	};
	Q_ENUM(EnvironmentGaugePanel_Size)

	enum Gauges_ValueType {
		Gauges_ValueType_NeutralPercentage,
		Gauges_ValueType_RisingPercentage,
		Gauges_ValueType_FallingPercentage
	};
	Q_ENUM(Gauges_ValueType)

	enum StatusBar_LeftButton {
		StatusBar_LeftButton_None,
		StatusBar_LeftButton_ControlsInactive,
		StatusBar_LeftButton_ControlsActive,
		StatusBar_LeftButton_Back
	};
	Q_ENUM(StatusBar_LeftButton)

	enum StatusBar_RightButton {
		StatusBar_RightButton_None,
		StatusBar_RightButton_SidePanelInactive,
		StatusBar_RightButton_SidePanelActive,
		StatusBar_RightButton_Add,
		StatusBar_RightButton_Refresh
	};
	Q_ENUM(StatusBar_RightButton)

	enum Units_Type {
		// Volume unit values are those expected by com.victronenergy.settings/Settings/System/VolumeUnit
		Units_Volume_CubicMeter = 0,
		Units_Volume_Liter = 1,
		Units_Volume_GallonImperial = 2,
		Units_Volume_GallonUS = 3,

		Units_Percentage,
		Units_Volt,
		Units_Watt,
		Units_Amp,
		Units_Energy_KiloWattHour,
		Units_Temperature_Celsius,
		Units_Temperature_Fahrenheit,
	};
	Q_ENUM(Units_Type)
	
	enum User_AccessType {
		User_AccessType_User,
		User_AccessType_Installer,
		User_AccessType_SuperUser,
		User_AccessType_Service
	};
	Q_ENUM(User_AccessType)

	enum OverviewWidget_Type {
		OverviewWidget_Type_Unknown,
		OverviewWidget_Type_Grid,
		OverviewWidget_Type_Shore,
		OverviewWidget_Type_AcGenerator,
		OverviewWidget_Type_DcGenerator,
		OverviewWidget_Type_Alternator,
		OverviewWidget_Type_Wind,
		OverviewWidget_Type_Solar,
		OverviewWidget_Type_Inverter,
		OverviewWidget_Type_Battery,
		OverviewWidget_Type_AcLoads,
		OverviewWidget_Type_DcLoads
	};
	Q_ENUM(OverviewWidget_Type)

	enum OverviewWidget_Size {
		OverviewWidget_Size_Zero = 0,
		OverviewWidget_Size_XS,
		OverviewWidget_Size_S,
		OverviewWidget_Size_M,
		OverviewWidget_Size_L,
		OverviewWidget_Size_XL
	};
	Q_ENUM(OverviewWidget_Size)

	enum WidgetConnector_Location {
		WidgetConnector_Location_Left,
		WidgetConnector_Location_Right,
		WidgetConnector_Location_Top,
		WidgetConnector_Location_Bottom
	};
	Q_ENUM(WidgetConnector_Location)

	enum WidgetConnector_AnimationMode {
		WidgetConnector_AnimationMode_NotAnimated,
		WidgetConnector_AnimationMode_StartToEnd,
		WidgetConnector_AnimationMode_EndToStart
	};
	Q_ENUM(WidgetConnector_AnimationMode)

	enum AcInputs_InputType {
		AcInputs_InputType_Unused = 0,
		AcInputs_InputType_Grid,
		AcInputs_InputType_Generator,
		AcInputs_InputType_Shore
	};
	Q_ENUM(AcInputs_InputType)

	enum DcInputs_InputType {
		DcInputs_InputType_Unknown = 0,
		DcInputs_InputType_Alternator,
		DcInputs_InputType_DcGenerator,
		DcInputs_InputType_Wind
		// DcInputs_InputType_Solar ?
	};
	Q_ENUM(DcInputs_InputType)

	enum EnvironmentInput_Status {
		EnvironmentInput_Status_Ok = 0,
		EnvironmentInput_Status_Disconnected,
		EnvironmentInput_Status_ShortCircuited,
		EnvironmentInput_Status_ReversePolarity,
		EnvironmentInput_Status_Unknown
	};
	Q_ENUM(EnvironmentInput_Status)

	enum Battery_Mode {
		Battery_Mode_Idle,
		Battery_Mode_Charging,
		Battery_Mode_Discharging
	};
	Q_ENUM(Battery_Mode)

	enum Ess_State {
		Ess_State_OptimizedWithBatteryLife,
		Ess_State_OptimizedWithoutBatteryLife,
		Ess_State_KeepBatteriesCharged,
		Ess_State_ExternalControl
	};
	Q_ENUM(Ess_State)

	enum Ess_Hub4ModeState {
		Ess_Hub4ModeState_PhaseCompensation = 1,
		Ess_Hub4ModeState_PhaseSplit = 2,
		Ess_Hub4ModeState_Disabled = 3
	};
	Q_ENUM(Ess_Hub4ModeState)

	enum Ess_BatteryLifeState {
		Ess_BatteryLifeState_Disabled = 0,
		Ess_BatteryLifeState_Restart,
		Ess_BatteryLifeState_Default,
		Ess_BatteryLifeState_Absorption,
		Ess_BatteryLifeState_Float,
		Ess_BatteryLifeState_Discharged,
		Ess_BatteryLifeState_ForceCharge,
		Ess_BatteryLifeState_Sustain,
		Ess_BatteryLifeState_LowSocCharge,
		Ess_BatteryLifeState_KeepCharged,
		Ess_BatteryLifeState_SocGuardDefault,
		Ess_BatteryLifeState_SocGuardDischarged,
		Ess_BatteryLifeState_SocGuardLowSocCharge
	};
	Q_ENUM(Ess_BatteryLifeState)

	enum Generators_State {
		Generators_State_Stopped = 0, // Not 2 as documented?
		Generators_State_Running = 1,
		Generators_State_Error = 10
	};
	Q_ENUM(Generators_State)

	enum Generators_RunningBy {
		Generators_RunningBy_NotRunning = 0,
		Generators_RunningBy_Manual,
		Generators_RunningBy_TestRun,
		Generators_RunningBy_LossOfCommunication,
		Generators_RunningBy_Soc,
		Generators_RunningBy_AcLoad,
		Generators_RunningBy_BatteryCurrent,
		Generators_RunningBy_BatteryVoltage,
		Generators_RunningBy_InverterHighTemp,
		Generators_RunningBy_InverterOverload
	};
	Q_ENUM(Generators_RunningBy)

	enum Inverters_ProductType {
		Inverters_ProductType_EuProduct = 0,
		Inverters_ProductType_UsProduct
	};
	Q_ENUM(Inverters_ProductType)

	enum Inverters_Mode {
		Inverters_Mode_ChargerOnly = 1,
		Inverters_Mode_InverterOnly,
		Inverters_Mode_On,
		Inverters_Mode_Off
	};
	Q_ENUM(Inverters_Mode)

	enum Relays_State {
		Relays_State_Inactive = 0,
		Relays_State_Active
	};
	Q_ENUM(Relays_State)

	// Values are from gui-v1 SystemState.qml
	enum System_State {
		System_State_Off = 0x00,
		System_State_LowPower = 0x01,
		System_State_FaultCondition = 0x02,
		System_State_BulkCharging = 0x03,
		System_State_AbsorptionCharging = 0x04,
		System_State_FloatCharging = 0x05,
		System_State_StorageMode = 0x06,
		System_State_EqualizationCharging = 0x07,
		System_State_PassThrough = 0x08,
		System_State_Inverting = 0x09,
		System_State_Assisting = 0x0A,
		System_State_PowerSupplyMode = 0x0B,

		System_State_Wakeup = 0xF5,
		System_State_RepeatedAbsorption = 0xF6,
		System_State_AutoEqualize = 0xF7,
		System_State_BatterySafe = 0xF8,
		System_State_LoadDetect = 0xF9,
		System_State_Blocked = 0xFA,
		System_State_Test = 0xFB,
		System_State_ExternalControl = 0xFC,

		System_State_Discharging = 0x100,
		System_State_Sustain = 0x101,
		System_State_Recharge = 0x102,
		System_State_ScheduledRecharge = 0x103
	};
	Q_ENUM(System_State)

	enum Tank_Type {
		// These values align with tank types from dbus
		// see: https://github.com/victronenergy/venus/wiki/dbus#tank-levels
		Tank_Type_Fuel = 0,
		Tank_Type_FreshWater,
		Tank_Type_WasteWater,
		Tank_Type_LiveWell,
		Tank_Type_Oil,
		Tank_Type_BlackWater,
		Tank_Type_Gasoline,
		Tank_Type_Diesel,
		Tank_Type_LPG,
		Tank_Type_LNG,
		Tank_Type_HydraulicOil,
		Tank_Type_RawWater,

		// Added for convenience as battery is combined with tanks on Brief page
		Tank_Type_Battery = 1000
	};
	Q_ENUM(Tank_Type)

	enum Tank_Status {
		Tank_Status_Ok = 0,
		Tank_Status_Disconnected,
		Tank_Status_ShortCircuited,
		Tank_Status_Unknown
	};
	Q_ENUM(Tank_Status)

	enum ModalDialog_DoneOptions {
		ModalDialog_DoneOptions_OkOnly,
		ModalDialog_DoneOptions_OkAndCancel,
		ModalDialog_DoneOptions_SetAndClose
	};
	Q_ENUM(ModalDialog_DoneOptions)

	enum PageManager_InteractionMode {
		PageManager_InteractionMode_Interactive,
		PageManager_InteractionMode_EnterIdleMode,   // Fade out nav bar
		PageManager_InteractionMode_BeginFullScreen, // Slide out nav bar, expand UI layout
		PageManager_InteractionMode_Idle,
		PageManager_InteractionMode_EndFullScreen,   // Slide in nav bar, compress UI layout
		PageManager_InteractionMode_ExitIdleMode     // Fade in nav bar
	};
	Q_ENUM(PageManager_InteractionMode)

	enum DVCC_Mode {
		DVCC_ForcedOff = 2,
		DVCC_ForcedOn = 3
	};
	Q_ENUM(DVCC_Mode)

	enum Notification_Type {
		Notification_Inactive,
		Notification_Info,
		Notification_Confirm,
		Notification_Warning,
		Notification_Alarm
	};
	Q_ENUM(Notification_Type)

	enum Storage_MountState {
		Storage_NotMounted,
		Storage_Mounted,
		Storage_UnmountRequested,
		Storage_UnmountBusy
	};
	Q_ENUM(Storage_MountState)

	enum CanBusProfile_Type {
		CanBusProfile_Disabled,
		CanBusProfile_Vecan,
		CanBusProfile_VecanAndCanBms,
		CanBusProfile_CanBms500,
		CanBusProfile_Oceanvolt,
		CanBusProfile_None250,
		CanBusProfile_RvC
	};
	Q_ENUM(CanBusProfile_Type)

	enum CanBusConfig_Type {
		CanBusConfig_AnyBus,
		CanBusConfig_ForcedCanBusBms,
		CanBusConfig_ForcedVeCan
	};
	Q_ENUM(CanBusConfig_Type)

	enum Relay_Function {
		Relay_Function_Alarm = 0,
		Relay_Function_GeneratorStartStop,
		Relay_Function_Manual,
		Relay_Function_Tank_Pump,
		Relay_Function_Temperature
	};
	Q_ENUM(Relay_Function)

	enum Temperature_DeviceType {
		Temperature_DeviceType_Battery = 0,
		Temperature_DeviceType_Fridge,
		Temperature_DeviceType_Generic
	};
	Q_ENUM(Temperature_DeviceType)

	enum Firmware_AutoUpdate {
		Firmware_AutoUpdate_Disabled,
		Firmware_AutoUpdate_CheckAndUpdate,
		Firmware_AutoUpdate_CheckOnly,
		Firmware_AutoUpdate_CheckAndDownloadOnly
	};
	Q_ENUM(Firmware_AutoUpdate)

	enum Firmware_UpdateType {
		Firmware_UpdateType_Online,
		Firmware_UpdateType_Offline
	};
	Q_ENUM(Firmware_UpdateType)

	enum DigitalInput_Type {
		DigitalInput_Disabled,
		DigitalInput_PulseMeter,
		DigitalInput_DoorAlarm,
		DigitalInput_BilgePump,
		DigitalInput_BilgeAlarm,
		DigitalInput_BurglarAlarm,
		DigitalInput_SmokeAlarm,
		DigitalInput_FireAlarm,
		DigitalInput_CO2Alarm,
		DigitalInput_Generator
	};
	Q_ENUM(DigitalInput_Type)

	enum GpsData_Format {
		GpsData_Format_DegreesMinutesSeconds,
		GpsData_Format_DecimalDegrees,
		GpsData_Format_DegreesMinutes
	};
	Q_ENUM(GpsData_Format)

	// These values are defined on the cerbo in /usr/sbin/resolv-watch script
	// that monitors which connection is the one active from all the avaiable ones.
	enum NetworkConnection_Type {
		NetworkConnection_None,
		NetworkConnection_Ethernet,
		NetworkConnection_WiFi,
		NetworkConnection_GSM
	};
	Q_ENUM(NetworkConnection_Type)

	enum NodeRed_Mode {
		NodeRed_Mode_Disabled,
		NodeRed_Mode_Enabled,
		NodeRed_Mode_EnabledWithSafeMode
	};
	Q_ENUM(NodeRed_Mode)

	enum SolarCharger_State {
		SolarCharger_State_Off,
		SolarCharger_State_Fault,
		SolarCharger_State_Buik,
		SolarCharger_State_Absorption,
		SolarCharger_State_Float,
		SolarCharger_State_Storage,
		SolarCharger_State_Equalize,
		SolarCharger_State_ExternalControl = 252,
	};
	Q_ENUM(SolarCharger_State)

	enum SolarCharger_AlarmType {
		SolarCharger_AlarmType_OK,
		SolarCharger_AlarmType_Warning,
		SolarCharger_AlarmType_Alarm
	};
	Q_ENUM(SolarCharger_AlarmType)

	enum SolarCharger_NetworkStatus {
		SolarCharger_NetworkStatus_Slave,
		SolarCharger_NetworkStatus_GroupMaster,
		SolarCharger_NetworkStatus_InstanceMaster,
		SolarCharger_NetworkStatus_GroupAndInstanceMaster,
		SolarCharger_NetworkStatus_Standalone,
		SolarCharger_NetworkStatus_StandaloneAndInstanceMaster
	};
	Q_ENUM(SolarCharger_NetworkStatus)

	Q_INVOKABLE QString acInputIcon(AcInputs_InputType type);
	Q_INVOKABLE QString dcInputIcon(DcInputs_InputType type);
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_ENUMS_H
