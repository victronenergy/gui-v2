/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("system")

	property int state

	// Provides convenience properties for total AC/DC loads.
	property QtObject loads: QtObject {
		readonly property real power: Units.sumRealNumbers(acPower, dcPower)
		readonly property real acPower: ac.consumption.power
		readonly property real dcPower: dc.power

		// Max AC power is calculated using com.victronenergy.vebus/Ac/Out/NominalInverterPower.
		// Assume NominalInverterPower = 80% of max AC load power.
		readonly property real maximumAcPower: (!Global.inverterChargers || isNaN(Global.inverterChargers.totalNominalInverterPower))
				? NaN : Global.inverterChargers.totalNominalInverterPower * (100 / 80)
	}

	property QtObject solar: QtObject {
		readonly property real power: Units.sumRealNumbers(acPower, dcPower)
		property real acPower: _pvMonitor.totalPower
		property real dcPower: _dcPvPower.numberValue
		readonly property real maximumPower: _maximumPower.numberValue

		// In cases where the overall current cannot be determined, the value is NaN.
		readonly property real current: {
			if (Global.pvInverters.model.count > 0) {
				if (Global.solarChargers.model.count > 0) {
					// If both PV chargers and PV inverters are present, return NaN as the current
					// cannot be summed across AC and DC systems.
					return NaN
				}
				if (_pvMonitor.maxPhaseCount > 1) {
					// If any PV inverter has more than one phase, return NaN as current values
					// cannot be summed across multiple phases.
					return NaN
				}
				return _pvMonitor.totalCurrent
			} else if (Global.solarChargers.model.count > 0) {
				return _dcPvCurrent.numberValue
			}
			return NaN
		}

		readonly property VeQuickItem _maximumPower: VeQuickItem {
			uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Pv/Power/Max"
		}

		readonly property PvMonitor _pvMonitor: PvMonitor {}

		readonly property VeQuickItem _dcPvPower: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Power"
		}

		readonly property VeQuickItem _dcPvCurrent: VeQuickItem {
			uid: root.serviceUid + "/Dc/Pv/Current"
		}
	}

	property SystemAc ac: SystemAc {}
	property SystemDc dc: SystemDc {}

	readonly property QtObject veBus: QtObject {
		readonly property string serviceUid: BackendConnection.serviceUidFromName(_serviceName.value || "", _deviceInstance.value || 0)
		readonly property real power: _power.numberValue

		readonly property VeQuickItem _serviceName: VeQuickItem { uid: root.serviceUid + "/VebusService" }
		readonly property VeQuickItem _deviceInstance: VeQuickItem { uid: root.serviceUid + "/VebusInstance" }
		readonly property VeQuickItem _power: VeQuickItem { uid: veBus.serviceUid ? veBus.serviceUid + "/Dc/0/Power" : "" }
	}

	function reset() {
		ac.reset()
		dc.reset()
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
		case VenusOS.System_State_ScheduledRecharge:
			//% "Scheduled recharge"
			return qsTrId("inverters_state_scheduledrecharge")
		case VenusOS.System_State_DynamicESS:
			//% "Dynamic ESS"
			return qsTrId("inverters_state_dynamic_ess")
		}
		return ""
	}

	Component.onCompleted: Global.system = root
}
