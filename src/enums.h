/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
	QML_NAMED_ELEMENT(VenusOS)
	QML_SINGLETON

public:
	explicit Enums(QObject *parent = nullptr);
	~Enums() override;

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
		Units_None = 0,
		Units_Volume_CubicMeter,
		Units_Volume_Liter,
		Units_Volume_GallonImperial,
		Units_Volume_GallonUS,
		Units_Percentage,
		Units_Volt,
		Units_VoltAmpere,
		Units_Watt,
		Units_Amp,
		Units_Hertz,
		Units_Energy_KiloWattHour,
		Units_AmpHour,
		Units_WattsPerSquareMeter,
		Units_Temperature_Kelvin,
		Units_Temperature_Celsius,
		Units_Temperature_Fahrenheit,
		Units_RevolutionsPerMinute,
		Units_Speed_MetresPerSecond,
		Units_Hectopascal,
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
		OverviewWidget_Type_AcInput,
		OverviewWidget_Type_DcGenerator,
		OverviewWidget_Type_Alternator,
		OverviewWidget_Type_FuelCell,
		OverviewWidget_Type_Wind,
		OverviewWidget_Type_Solar,
		OverviewWidget_Type_VeBusDevice,
		OverviewWidget_Type_Battery,
		OverviewWidget_Type_AcLoads,
		OverviewWidget_Type_DcLoads,
		OverviewWidget_Type_Evcs
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

	enum AcInputs_InputSource {
		AcInputs_InputSource_NotAvailable = 0,
		AcInputs_InputSource_Grid,
		AcInputs_InputSource_Generator,
		AcInputs_InputSource_Shore,
		AcInputs_InputSource_Inverting = 240
	};
	Q_ENUM(AcInputs_InputSource)

	enum DcInputs_InputType {
		DcInputs_InputType_AcCharger,
		DcInputs_InputType_Alternator,
		DcInputs_InputType_DcCharger,
		DcInputs_InputType_DcGenerator,
		DcInputs_InputType_DcSystem,
		DcInputs_InputType_FuelCell,
		DcInputs_InputType_ShaftGenerator,
		DcInputs_InputType_WaterGenerator,
		DcInputs_InputType_Wind
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

	enum Battery_TimeToGo_Format {
		Battery_TimeToGo_ShortFormat,
		Battery_TimeToGo_LongFormat
	};
	Q_ENUM(Battery_TimeToGo_Format)

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
		Generators_State_Stopped = 0,
		Generators_State_Running = 1,
		Generators_State_WarmUp = 2,
		Generators_State_CoolDown = 3,
		Generators_State_Stopping = 4,
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
		Generators_RunningBy_InverterHighTemperature,
		Generators_RunningBy_InverterOverload
	};
	Q_ENUM(Generators_RunningBy)

	enum VeBusDevice_ProductType {
		VeBusDevice_ProductType_EuProduct = 0,
		VeBusDevice_ProductType_UsProduct
	};
	Q_ENUM(VeBusDevice_ProductType)

	enum InverterCharger_Mode {
		InverterCharger_Mode_ChargerOnly = 1,
		InverterCharger_Mode_InverterOnly,
		InverterCharger_Mode_On,
		InverterCharger_Mode_Off
	};
	Q_ENUM(InverterCharger_Mode)

	enum VeBusDevice_ChargeState {
		VeBusDevice_ChargeState_InitializingCharger,
		VeBusDevice_ChargeState_Bulk,
		VeBusDevice_ChargeState_Absorption,
		VeBusDevice_ChargeState_Float,
		VeBusDevice_ChargeState_Storage,
		VeBusDevice_ChargeState_AbsorbRepeat,
		VeBusDevice_ChargeState_ForcedAbsorb,
		VeBusDevice_ChargeState_Equalize,
		VeBusDevice_ChargeState_BulkStopped,
		VeBusDevice_ChargeState_Unknown
	};
	Q_ENUM(VeBusDevice_ChargeState)

	enum VeBusDevice_Bms_Type { // TODO: this is not documented, it is hard coded in gui-v1. Update when doco becomes available
		VeBusDevice_Bms_Type_VeBus = 2
	};
	Q_ENUM(VeBusDevice_Bms_Type)

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
		System_State_Sustain = 0xF4,

		System_State_Wakeup = 0xF5,
		System_State_RepeatedAbsorption = 0xF6,
		System_State_AutoEqualize = 0xF7,
		System_State_BatterySafe = 0xF8,
		System_State_LoadDetect = 0xF9,
		System_State_Blocked = 0xFA,
		System_State_Test = 0xFB,
		System_State_ExternalControl = 0xFC,

		// These are not VEBUS states, they are system states used with ESS
		System_State_Discharging = 0x100,
		System_State_SystemSustain = 0x101,
		System_State_Recharge = 0x102,
		System_State_ScheduledRecharge = 0x103,
		System_State_DynamicESS = 0x104
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
		Tank_Status_ReversePolarity,
		Tank_Status_Unknown,
		Tank_Status_Error
	};
	Q_ENUM(Tank_Status)

	enum ModalDialog_DoneOptions {
		ModalDialog_DoneOptions_NoOptions,
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
		DigitalInput_Type_Disabled,
		DigitalInput_Type_PulseMeter,
		DigitalInput_Type_DoorAlarm,
		DigitalInput_Type_BilgePump,
		DigitalInput_Type_BilgeAlarm,
		DigitalInput_Type_BurglarAlarm,
		DigitalInput_Type_SmokeAlarm,
		DigitalInput_Type_FireAlarm,
		DigitalInput_Type_CO2Alarm,
		DigitalInput_Type_Generator
	};
	Q_ENUM(DigitalInput_Type)

	enum DigitalInput_State {
		DigitalInput_State_Low,
		DigitalInput_State_High,
		DigitalInput_State_Off,
		DigitalInput_State_On,
		DigitalInput_State_No,
		DigitalInput_State_Yes,
		DigitalInput_State_Open,
		DigitalInput_State_Closed,
		DigitalInput_State_OK,
		DigitalInput_State_Alarm,
		DigitalInput_State_Running,
		DigitalInput_State_Stopped
	};
	Q_ENUM(DigitalInput_State)

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

	enum Link_NetworkStatus {
		Link_NetworkStatus_Slave,
		Link_NetworkStatus_GroupMaster,
		Link_NetworkStatus_InstanceMaster,
		Link_NetworkStatus_GroupAndInstanceMaster,
		Link_NetworkStatus_Standalone,
		Link_NetworkStatus_StandaloneAndGroupMaster
	};
	Q_ENUM(Link_NetworkStatus)

	enum Evcs_Status {
		Evcs_Status_Disconnected,
		Evcs_Status_Connected,
		Evcs_Status_Charging,
		Evcs_Status_Charged,
		Evcs_Status_WaitingForSun,
		Evcs_Status_WaitingForRFID,
		Evcs_Status_WaitingForStart,
		Evcs_Status_LowStateOfCharge,
		Evcs_Status_GroundTestError,
		Evcs_Status_WeldedContactsError,
		Evcs_Status_CpInputTestError,
		Evcs_Status_ResidualCurrentDetected,
		Evcs_Status_UndervoltageDetected,
		Evcs_Status_OvervoltageDetected,
		Evcs_Status_OverheatingDetected,
		Evcs_Status_ChargingLimit = 20,
		Evcs_Status_StartCharging,
		Evcs_Status_SwitchingToThreePhase,
		Evcs_Status_SwitchingToSinglePhase
	};
	Q_ENUM(Evcs_Status)

	enum Evcs_Mode {
		Evcs_Mode_Manual,
		Evcs_Mode_Auto,
		Evcs_Mode_Scheduled
	};
	Q_ENUM(Evcs_Mode)

	enum Evcs_Position {
		Evcs_Position_ACOutput,
		Evcs_Position_ACInput
	};
	Q_ENUM(Evcs_Position)

	enum PvInverter_StatusCode {
		PvInverter_StatusCode_Startup0,
		PvInverter_StatusCode_Startup1,
		PvInverter_StatusCode_Startup2,
		PvInverter_StatusCode_Startup3,
		PvInverter_StatusCode_Startup4,
		PvInverter_StatusCode_Startup5,
		PvInverter_StatusCode_Startup6,
		PvInverter_StatusCode_Running,
		PvInverter_StatusCode_Standby,
		PvInverter_StatusCode_BootLoading,
		PvInverter_StatusCode_Error,
		PvInverter_StatusCode_RunningMPPT,
		PvInverter_StatusCode_RunningThrottled
	};
	Q_ENUM(PvInverter_StatusCode)

	enum PvInverter_Position {
		PvInverter_Position_ACInput,
		PvInverter_Position_ACOutput,
		PvInverter_Position_ACInput2,
	};
	Q_ENUM(PvInverter_Position)

	enum Genset_StatusCode {
		Genset_StatusCode_Standby,
		Genset_StatusCode_Startup1,
		Genset_StatusCode_Startup2,
		Genset_StatusCode_Startup3,
		Genset_StatusCode_Startup4,
		Genset_StatusCode_Startup5,
		Genset_StatusCode_Startup6,
		Genset_StatusCode_Startup7,
		Genset_StatusCode_Running,
		Genset_StatusCode_Stopping,
		Genset_StatusCode_Error,
	};
	Q_ENUM(Genset_StatusCode)

	enum Alarm_Level {
		Alarm_Level_OK,
		Alarm_Level_Warning,
		Alarm_Level_Alarm
	};
	Q_ENUM(Alarm_Level)

	Q_INVOKABLE QString dcInputIcon(DcInputs_InputType type);
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_ENUMS_H
