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

	enum SpinBox_FocusMode {
		SpinBox_FocusMode_NoAction,
		SpinBox_FocusMode_Navigate,
		SpinBox_FocusMode_Edit
	};
	Q_ENUM(SpinBox_FocusMode)

	enum Units_Type {
		Units_None = 0,
		Units_Volume_CubicMeter,
		Units_Volume_Liter,
		Units_Volume_GallonImperial,
		Units_Volume_GallonUS,
		Units_Percentage,
		Units_Volt_AC,
		Units_Volt_DC,
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
		Units_Speed_KilometersPerHour,
		Units_Speed_MilesPerHour,
		Units_Speed_Knots,
		Units_Hectopascal,
		Units_Kilopascal,
		Units_CardinalDirection,
		Units_PowerFactor,
		Units_Time_Day,
		Units_Time_Hour,
		Units_Time_Minute,
		Units_Altitude_Meter,
		Units_Altitude_Foot
	};
	Q_ENUM(Units_Type)

	enum Units_Scale {
		Units_Scale_None = 0,
		Units_Scale_Kilo,
		Units_Scale_Mega,
		Units_Scale_Giga,
		Units_Scale_Tera,
	};
	Q_ENUM(Units_Scale)

	enum Units_Precision {
		Units_Precision_Default       = -1, // per-unit default precision
		Units_Precision_ZeroDecimals  = 0,
		Units_Precision_OneDecimal    = 1,
		Units_Precision_TwoDecimals   = 2,
		Units_Precision_ThreeDecimals = 3
	};
	Q_ENUM(Units_Precision)

	enum User_AccessType {
		User_AccessType_User,
		User_AccessType_Installer,
		User_AccessType_SuperUser,
		User_AccessType_Service
	};
	Q_ENUM(User_AccessType)

	enum OverviewWidget_Type {
		OverviewWidget_Type_Unknown,
		OverviewWidget_Type_AcInputPriority,
		OverviewWidget_Type_AcInputOther,
		OverviewWidget_Type_DcGenerator,
		OverviewWidget_Type_Alternator,
		OverviewWidget_Type_FuelCell,
		OverviewWidget_Type_Wind,
		OverviewWidget_Type_Solar,
		OverviewWidget_Type_VeBusDevice,
		OverviewWidget_Type_Battery,
		OverviewWidget_Type_AcLoads,
		OverviewWidget_Type_DcLoads,
		OverviewWidget_Type_EssentialLoads,
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

	enum OverviewWidget_PreferredSize {
		OverviewWidget_PreferredSize_Any,
		OverviewWidget_PreferredSize_PreferLarge,
		OverviewWidget_PreferredSize_LargeOnly
	};
	Q_ENUM(OverviewWidget_PreferredSize)

	enum WidgetConnector_Location {
		WidgetConnector_Location_Left,
		WidgetConnector_Location_Right,
		WidgetConnector_Location_Top,
		WidgetConnector_Location_Bottom
	};
	Q_ENUM(WidgetConnector_Location)

	enum WidgetConnector_Straighten {
		WidgetConnector_Straighten_None,
		WidgetConnector_Straighten_StartToEnd,
		WidgetConnector_Straighten_EndToStart
	};
	Q_ENUM(WidgetConnector_Straighten)

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

	enum Battery_State {
		Battery_State_Running = 9,
		Battery_State_Error = 10,
		Battery_State_Unknown = 11,
		Battery_State_Shutdown = 12,
		Battery_State_Updating = 13,
		Battery_State_Standby = 14,
		Battery_State_GoingToRun = 15,
		Battery_State_Precharging = 16,
		Battery_State_ContactorCheck = 17,
		Battery_State_Pending = 18
	};
	Q_ENUM(Battery_State)

	enum Battery_Balancer_Status {
		Battery_Balancer_Unknown = 0,
		Battery_Balancer_Balanced,
		Battery_Balancer_Balancing,
		Battery_Balancer_Imbalance
	};
	Q_ENUM(Battery_Balancer_Status)

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
		Generators_State_StoppedByTankLevel = 5,
		Generators_State_Error = 10
	};
	Q_ENUM(Generators_State)

	enum Generators_RunningBy {
		Generators_RunningBy_NotRunning = 0,
		Generators_RunningBy_Manual,
		Generators_RunningBy_PeriodicRun,
		Generators_RunningBy_LossOfCommunication,
		Generators_RunningBy_Soc,
		Generators_RunningBy_AcLoad,
		Generators_RunningBy_BatteryCurrent,
		Generators_RunningBy_BatteryVoltage,
		Generators_RunningBy_InverterHighTemperature,
		Generators_RunningBy_InverterOverload
	};
	Q_ENUM(Generators_RunningBy)

	enum Inverter_Mode {
		Inverter_Mode_On = 2,
		Inverter_Mode_Off = 4,
		Inverter_Mode_Eco = 5
	};
	Q_ENUM(Inverter_Mode)

	enum InverterCharger_Mode {
		InverterCharger_Mode_ChargerOnly = 1,
		InverterCharger_Mode_InverterOnly,
		InverterCharger_Mode_On,
		InverterCharger_Mode_Off,
		InverterCharger_Mode_Passthrough = 251,
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

	enum VeBusDevice_Backup_Restore_Action {
		VeBusDevice_Backup_Restore_Action_None = 0,
		VeBusDevice_Backup_Restore_Action_Backup,
		VeBusDevice_Backup_Restore_Action_Restore,
		VeBusDevice_Backup_Restore_Action_Delete
	};
	Q_ENUM(VeBusDevice_Backup_Restore_Action)

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
		System_State_ScheduledCharge = 0x103,
		System_State_DynamicESS = 0x104
	};
	Q_ENUM(System_State)

	enum System_HubSetting {
		System_HubSetting_Hub_1 = 1,
		System_HubSetting_Hub_2,
		System_HubSetting_Hub_3,
		System_HubSetting_Ess
	};
	Q_ENUM(System_HubSetting)

	enum BriefView_Unit {
		BriefView_Unit_None,
		BriefView_Unit_Absolute,
		BriefView_Unit_Percentage
	};
	Q_ENUM(BriefView_Unit)

	enum BriefView_CentralGauge_Type {
		BriefView_CentralGauge_None,
		BriefView_CentralGauge_BatteryId,
		BriefView_CentralGauge_SystemBattery,
		BriefView_CentralGauge_TankAggregate,
		BriefView_CentralGauge_TankId
	};
	Q_ENUM(BriefView_CentralGauge_Type)

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

		// Added for convenience as these options are combined with the tanks on Brief page gauges
		Tank_Type_None = 999,
		Tank_Type_Battery = 1000
	};
	Q_ENUM(Tank_Type)

	enum Tank_Status {
		Tank_Status_Ok = 0,
		Tank_Status_Open_Circuit,
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
		ModalDialog_DoneOptions_SetAndCancel
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

	enum Switch_ForcedMode {
		Switch_ForcedOff = 2,
		Switch_ForcedOn = 3
	};
	Q_ENUM(Switch_ForcedMode)

	enum Switch_DeviceState {
		Switch_DeviceState_Connected = 0x100,
		Switch_DeviceState_Over_Temperature,
		Switch_DeviceState_Temperature_Warning,
		Switch_DeviceState_Channel_Fault,
		Switch_DeviceState_Channel_Tripped,
		Switch_DeviceState_Under_Voltage
	};
	Q_ENUM(Switch_DeviceState)

	enum SwitchableOutput_Type {
		SwitchableOutput_Type_Momentary = 0,
		SwitchableOutput_Type_Latching,
		SwitchableOutput_Type_Dimmable,
		SwitchableOutput_Type_Slave = 5
	};
	Q_ENUM(SwitchableOutput_Type)

	enum SwitchableOutput_Status {
		SwitchableOutput_Status_Off,
		SwitchableOutput_Status_Powered,
		SwitchableOutput_Status_Tripped,
		SwitchableOutput_Status_Over_Temperature = 0x04,
		SwitchableOutput_Status_Output_Fault =0x08,
		SwitchableOutput_Status_On = 0x09,  //inputActive + active
		SwitchableOutput_Status_Short_Fault = 0x10,
		SwitchableOutput_Status_Disabled = 0x20,
		SwitchableOutput_Status_TripLowVoltage = 0x22
	};
	Q_ENUM(SwitchableOutput_Status)

	enum Notification_Type {
		Notification_Warning,
		Notification_Alarm,
		Notification_Info
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
		CanBusProfile_RvC,
		CanBusProfile_HighVoltage,
		CanBusProfile_None500
	};
	Q_ENUM(CanBusProfile_Type)

	enum CanBusConfig_Type {
		// "any" means, any of the for Venus tested protocols, before supporting the
		// hv-can-bus (CAN-fd). That is classic CAN up to 500 kbit/s.
		CanBusConfig_AnyBus,
		CanBusConfig_ForcedCanBusBms,
		CanBusConfig_ForcedVeCan,
		// High Voltage CAN can send CAN fd frames as well. Hence CAN interfaces must
		// explicitly indicate it is supported, not only that CAN-fd messages are
		// supported, but also to assure the device can keep up with the higher
		// througput. The HV protocol uses upto 1Mbit/s at the moment.
		CanBusConfig_AnyBusAndHv
	};
	Q_ENUM(CanBusConfig_Type)

	enum Relay_Function {
		Relay_Function_Alarm = 0,
		Relay_Function_GeneratorStartStop,
		Relay_Function_Manual,
		Relay_Function_Tank_Pump,
		Relay_Function_Temperature,
		Relay_Function_GensetHelperRelay
	};
	Q_ENUM(Relay_Function)

	enum Temperature_DeviceType {
		Temperature_DeviceType_Battery = 0,
		Temperature_DeviceType_Fridge,
		Temperature_DeviceType_Generic,
		Temperature_DeviceType_Room,
		Temperature_DeviceType_Outdoor,
		Temperature_DeviceType_WaterHeater,
		Temperature_DeviceType_Freezer
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

	enum Security_Profile {
		Security_Profile_Secured,
		Security_Profile_Weak,
		Security_Profile_Unsecured,
		Security_Profile_Indeterminate
	};
	Q_ENUM(Security_Profile)

	enum Vrm_PortalMode {
		Vrm_PortalMode_Off,
		Vrm_PortalMode_ReadOnly,
		Vrm_PortalMode_Full
	};
	Q_ENUM(Vrm_PortalMode)

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
		DigitalInput_Type_Generator,
		// 10 is not used
		DigitalInput_Type_TouchInputControl = 11
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
		SolarCharger_State_Fault = 2,
		SolarCharger_State_Bulk,
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
		Evcs_Status_SwitchingToSinglePhase,
		Evcs_Status_StopCharging
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
		Evcs_Position_ACInput,
		Evcs_Position_Unknown = 100
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

	enum TrackerName_Format {
		TrackerName_WithDevicePrefix,
		TrackerName_NoDevicePrefix
	};
	Q_ENUM(TrackerName_Format)

	enum InputValidation_Result {
		InputValidation_Result_Unknown,
		InputValidation_Result_OK,
		InputValidation_Result_Warning,
		InputValidation_Result_Error,
	};
	Q_ENUM(InputValidation_Result)

	enum InputValidation_ValidateMode {
		InputValidation_ValidateOnly,
		InputValidation_ValidateAndSave,
	};
	Q_ENUM(InputValidation_ValidateMode)

	enum OnboardingState {
		OnboardingState_NotDone,
		OnboardingState_DoneNative = 0x01,
		OnboardingState_DoneWasm = 0x02
	};
	Q_ENUM(OnboardingState)
	Q_DECLARE_FLAGS(OnboardingStateFlag, OnboardingState)

	enum StartPage_Mode {
		StartPage_Mode_AutoSelect,
		StartPage_Mode_UserSelect
	};
	Q_ENUM(StartPage_Mode)

	enum StartPage_Type {
		StartPage_Type_None,
		StartPage_Type_Brief_SidePanelClosed,
		StartPage_Type_Brief_SidePanelOpened,
		StartPage_Type_Overview,
		StartPage_Type_Levels_Tanks,
		StartPage_Type_Levels_Environment,
		StartPage_Type_BatteryList,
		StartPage_Type_Boat
	};
	Q_ENUM(StartPage_Type)

	enum ListItem_BottomContentSizeMode {
		ListItem_BottomContentSizeMode_Stretch,
		ListItem_BottomContentSizeMode_Compact
	};
	Q_ENUM(ListItem_BottomContentSizeMode)

	enum ListLink_Mode {
		ListLink_Mode_LinkButton,
		ListLink_Mode_QRCode
	};
	Q_ENUM(ListLink_Mode)

	enum ModificationChecks_SystemHooksState {
		ModificationChecks_SystemHooksState_NonePresent      = 0,
		ModificationChecks_SystemHooksState_RcLocalDisabled  = 1,
		ModificationChecks_SystemHooksState_RcSLocalDisabled = 2,
		ModificationChecks_SystemHooksState_RcLocal          = 4,
		ModificationChecks_SystemHooksState_RcSLocal         = 8,
		ModificationChecks_SystemHooksState_HookLoadedAtBoot = 16
	};
	Q_ENUM(ModificationChecks_SystemHooksState)

	enum MotorDriveGear {
		MotorDriveGear_Neutral,
		MotorDriveGear_Reverse,
		MotorDriveGear_Forward
	};
	Q_ENUM(MotorDriveGear)

	Q_INVOKABLE QString battery_modeToText(Battery_Mode mode) const;
	Q_INVOKABLE Battery_Mode battery_modeFromPower(qreal power) const;
	Q_INVOKABLE QString battery_iconFromMode(Battery_Mode mode) const;

	Q_INVOKABLE QString dcInput_typeToText(DcInputs_InputType type) const;

	Q_INVOKABLE QString digitalInput_typeToText(DigitalInput_Type type) const;
	Q_INVOKABLE QString digitalInput_stateToText(DigitalInput_State state) const;

	Q_INVOKABLE QString pvInverter_statusCodeToText(PvInverter_StatusCode statusCode) const;

	Q_INVOKABLE QString solarCharger_stateToText(SolarCharger_State state) const;

	Q_INVOKABLE QString switch_deviceStateToText(Switch_DeviceState value) const;
	Q_INVOKABLE QString switchableOutput_typeToText(SwitchableOutput_Type value, const QString &channelId = QString()) const;
	Q_INVOKABLE QString switchableOutput_statusToText(SwitchableOutput_Status value) const;
};

}
}

Q_DECLARE_OPERATORS_FOR_FLAGS(Victron::VenusOS::Enums::OnboardingStateFlag)

#endif // VICTRON_VENUSOS_GUI_V2_ENUMS_H
