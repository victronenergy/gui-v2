/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("system")
	readonly property int state: _systemState.valid ? _systemState.value : VenusOS.System_State_Off

	readonly property bool hasGridMeter: _gridDeviceType.valid
	readonly property bool hasAcOutSystem: _hasAcOutSystem.valid && _hasAcOutSystem.value === 1
	readonly property bool hasVebusEss: _systemType.value === "ESS" || _systemType.value === "Hub-4"
	readonly property bool hasEss: hasVebusEss || _systemType.value === "AC System"
	readonly property bool showInputLoads: load.acIn.hasPower
			&& (hasVebusEss ? (hasGridMeter && _withoutGridMeter.value === 0) : hasGridMeter)
	readonly property bool feedbackEnabled: _feedbackEnabled.value === 1

	readonly property ActiveSystemBattery battery: ActiveSystemBattery {
		systemServiceUid: root.serviceUid
	}

	readonly property QtObject load: SystemLoad {
		systemServiceUid: root.serviceUid
	}

	readonly property QtObject dc: QtObject {
		readonly property real power: (_hasDcSystem.valid && _hasDcSystem.value && _dcSystemPower.valid) ? _dcSystemPower.value : NaN
		readonly property real current: (isNaN(power) || isNaN(voltage) || voltage === 0) ? NaN : power / voltage
		readonly property real voltage: _dcBatteryVoltage.valid ? _dcBatteryVoltage.value : NaN
		readonly property real maximumPower: _maximumDcPower.valid ? _maximumDcPower.value : NaN
		readonly property real preferredQuantity: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp ? current : power

		readonly property VeQuickItem _dcSystemPower: VeQuickItem {
			uid: root.serviceUid + "/Dc/System/Power"
		}

		readonly property VeQuickItem _dcBatteryVoltage: VeQuickItem {
			uid: root.serviceUid + "/Dc/Battery/Voltage"
		}

		readonly property VeQuickItem _maximumDcPower: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/System/Power/Max"
		}

		readonly property VeQuickItem _hasDcSystem: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
		}
	}

	property QtObject solar: QtObject {
		readonly property real power: Units.sumRealNumbers(acPower, dcPower)
		property real acPower: _pvMonitor.totalPower
		property real dcPower: _dcPvPower.valid ? _dcPvPower.value : NaN
		readonly property real maximumPower: _maximumPower.valid ? _maximumPower.value : NaN

		// In cases where the overall current cannot be determined, the value is NaN.
		readonly property real current: {
			if (Global.pvInverters.model.count > 0) {
				if (Global.solarDevices.model.count > 0) {
					// If both PV chargers and PV inverters are present, return NaN as the current
					// cannot be summed across AC and DC systems.
					return NaN
				}
				if (_pvMonitor.maxPhaseCount > 1) {
					// If any PV inverter has more than one phase, return NaN as current values
					// cannot be summed across multiple phases.
					return NaN
				}
				// There are one or more PV inverters, which are all single-phase, so it's safe to
				// return a total current as they should all have the same PV output voltage.
				return _pvMonitor.totalCurrent
			} else if (Global.solarDevices.model.count > 0) {
				return _dcPvCurrent.valid ? _dcPvCurrent.value : NaN
			}
			return NaN
		}

		readonly property VeQuickItem _maximumPower: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Pv/Power/Max"
		}

		readonly property PvMonitor _pvMonitor: PvMonitor {
			systemServiceUid: root.serviceUid
		}

		readonly property VeQuickItem _dcPvPower: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Power"
		}

		readonly property VeQuickItem _dcPvCurrent: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Current"
		}
	}

	readonly property QtObject veBus: QtObject {
		readonly property string serviceUid: BackendConnection.serviceUidFromName(_serviceName.value || "", _deviceInstance.value || 0)

		readonly property VeQuickItem _serviceName: VeQuickItem { uid: root.serviceUid + "/VebusService" }
		readonly property VeQuickItem _deviceInstance: VeQuickItem { uid: root.serviceUid + "/VebusInstance" }
	}

	readonly property VeQuickItem _systemState: VeQuickItem {
		uid: root.serviceUid + "/SystemState/State"
	}

	readonly property VeQuickItem _systemType: VeQuickItem {
		uid: root.serviceUid + "/SystemType"
	}

	readonly property VeQuickItem _gridDeviceType: VeQuickItem {
		uid: root.serviceUid + "/Ac/Grid/DeviceType"
	}

	readonly property VeQuickItem _hasAcOutSystem: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
	}

	readonly property VeQuickItem _withoutGridMeter: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter"
	}

	readonly property VeQuickItem _feedbackEnabled: VeQuickItem {
		uid: root.serviceUid + "/Ac/ActiveIn/FeedbackEnabled"
	}

	function systemStateToText(s) {
		switch (s) {
		case VenusOS.System_State_Off:
			return CommonWords.off
		case VenusOS.System_State_LowPower:
			//% "AES mode"
			return qsTrId("inverters_state_aes_mode")
		case VenusOS.System_State_FaultCondition:
			//% "Fault condition"
			return qsTrId("inverters_state_faultcondition")
		case VenusOS.System_State_BulkCharging:
			//% "Bulk charging"
			return qsTrId("inverters_state_bulkcharging")
		case VenusOS.System_State_AbsorptionCharging:
			//% "Absorption charging"
			return qsTrId("inverters_state_absorptioncharging")
		case VenusOS.System_State_FloatCharging:
			//% "Float charging"
			return qsTrId("inverters_state_floatcharging")
		case VenusOS.System_State_StorageMode:
			//% "Storage mode"
			return qsTrId("inverters_state_storagemode")
		case VenusOS.System_State_EqualizationCharging:
			//% "Equalization charging"
			return qsTrId("inverters_state_equalisationcharging")
		case VenusOS.System_State_PassThrough:
			//% "Pass-thru"
			return qsTrId("inverters_state_passthru")
		case VenusOS.System_State_Inverting:
			//% "Inverting"
			return qsTrId("inverters_state_inverting")
		case VenusOS.System_State_Assisting:
			//% "Assisting"
			return qsTrId("inverters_state_assisting")
		case VenusOS.System_State_PowerSupplyMode:
			//% "Power supply mode"
			return qsTrId("inverters_state_powersupplymode")
		case VenusOS.System_State_Sustain:
			//% "Sustain"
			return qsTrId("inverters_state_sustain")

		case VenusOS.System_State_Wakeup:
			//% "Wake up"
			return qsTrId("inverters_state_wakeup")
		case VenusOS.System_State_RepeatedAbsorption:
			//% "Repeated absorption"
			return qsTrId("inverters_state_repeatedabsorption")
		case VenusOS.System_State_AutoEqualize:
			//% "Auto equalize"
			return qsTrId("inverters_state_autoequalize")
		case VenusOS.System_State_BatterySafe:
			//% "Battery safe"
			return qsTrId("inverters_state_battery_safe")
		case VenusOS.System_State_LoadDetect:
			//% "Load detect"
			return qsTrId("inverters_state_loaddetect")
		case VenusOS.System_State_Blocked:
			//% "Blocked"
			return qsTrId("inverters_state_blocked")
		case VenusOS.System_State_Test:
			//% "Test"
			return qsTrId("inverters_state_test")
		case VenusOS.System_State_ExternalControl:
			//% "External control"
			return qsTrId("inverters_state_externalccontrol")

		case VenusOS.System_State_Discharging:
			return CommonWords.discharging
		case VenusOS.System_State_SystemSustain:
			//% "Sustain"
			return qsTrId("inverters_state_system_sustain")
		case VenusOS.System_State_Recharge:
			//% "Recharge"
			return qsTrId("inverters_state_recharge")
		case VenusOS.System_State_ScheduledCharge:
			//% "Scheduled"
			return qsTrId("inverters_state_scheduledcharge")
		case VenusOS.System_State_DynamicESS:
			//% "Dynamic ESS"
			return qsTrId("inverters_state_dynamic_ess")
		default:
			return CommonWords.unknown_status
		}
	}

	Component.onCompleted: Global.system = root
}
