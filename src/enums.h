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
		Gauges_ValueType_RisingPercentage,
		Gauges_ValueType_FallingPercentage
	};
	Q_ENUM(Gauges_ValueType)

	enum StatusBar_NavigationButtonStyle {
		StatusBar_NavigationButtonStyle_ControlsInactive,
		StatusBar_NavigationButtonStyle_ControlsActive,
		StatusBar_NavigationButtonStyle_Back
	};
	Q_ENUM(StatusBar_NavigationButtonStyle)

	enum ToastNotification_Category {
		ToastNotification_Category_None,
		ToastNotification_Category_Informative,
		ToastNotification_Category_Confirmation,
		ToastNotification_Category_Warning,
		ToastNotification_Category_Error
	};
	Q_ENUM(ToastNotification_Category)

	enum Units_Type {
		Units_Percentage,
		Units_Potential_Volt,
		Units_Energy_Watt,
		Units_Energy_Amp,
		Units_Temperature_Celsius,
		Units_Temperature_Fahrenheit,
		Units_Volume_CubicMeter,
		Units_Volume_Liter,
		Units_Volume_GallonUS,
		Units_Volume_GallonImperial
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

	enum System_State {
		System_State_Off = 0,
		System_State_LowPower,
		System_State_FaultCondition,
		System_State_BulkCharging,
		System_State_AbsorptionCharging,
		System_State_FloatCharging,
		System_State_StorageMode,
		System_State_EqualizationCharging,
		System_State_PassThrough,
		System_State_Inverting,
		System_State_Assisting,
		System_State_Discharging = 256,
		System_State_Sustain = 257
	};
	Q_ENUM(System_State)

	enum Tank_Type {
		Tank_Type_Fuel = 0,
		Tank_Type_FreshWater,
		Tank_Type_WasteWater,
		Tank_Type_LiveWell,
		Tank_Type_Oil,
		Tank_Type_BlackWater,
		Tank_Type_Gasoline,
		Tank_Type_Battery = 255
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

	enum SystemSettings_DemoMode {
		SystemSettings_DemoModeInactive,
		SystemSettings_DemoModeActive,
		SystemSettings_DemoModeUnknown = 255
	};
	Q_ENUM(SystemSettings_DemoMode)

	enum DVCC_Mode {
		DVCC_ForcedOff = 2,
		DVCC_ForcedOn = 3
	};
	Q_ENUM(DVCC_Mode)

	enum Notification_Type {
		Notification_Inactive,
		Notification_Warning,
		Notification_Alarm,
		Notification_Info
	};
	Q_ENUM(Notification_Type)

	enum PageSettingsLogger_MountState {
		PageSettingsLogger_NotMounted,
		PageSettingsLogger_Mounted,
		PageSettingsLogger_UnmountRequested,
		PageSettingsLogger_UnmountBusy
	};
	Q_ENUM(PageSettingsLogger_MountState)

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


	Q_INVOKABLE QString acInputIcon(AcInputs_InputType type);
	Q_INVOKABLE QString dcInputIcon(DcInputs_InputType type);
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_ENUMS_H
