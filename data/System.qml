/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

QtObject {
	id: root

	property int state

	// Provides convenience properties for total AC/DC loads.
	property QtObject loads: QtObject {
		readonly property real power: Utils.sumRealNumbers(acPower, dcPower)
		readonly property real acPower: ac.consumption.power
		readonly property real dcPower: dc.power

		// Unlike for power, the AC and DC currents cannot be combined because amps for AC and DC
		// sources are on different scales. So if they are both present, the total is NaN.
		readonly property real current: (acCurrent || 0) !== 0 && (dcCurrent || 0) !== 0
				? NaN
				: (acCurrent || 0) === 0 ? dcCurrent : acCurrent
		readonly property real acCurrent: ac.consumption.current
		readonly property real dcCurrent: dc.current

		// Max AC power is calculated using com.victronenergy.vebus/Ac/Out/NominalInverterPower.
		// Assume NominalInverterPower = 80% of max AC load power.
		readonly property real maximumAcPower: (!Global.inverters || isNaN(Global.inverters.totalNominalInverterPower))
				? NaN : Global.inverters.totalNominalInverterPower * (100 / 80)
	}

	property QtObject solar: QtObject {
		readonly property real power: isNaN(acPower) && isNaN(dcPower)
				? NaN
				: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
		property real acPower: NaN
		property real dcPower: NaN

		// Unlike for power, the AC and DC currents cannot be combined because amps for AC and DC
		// sources are on different scales. So if they are both present, the total is NaN.
		readonly property real current: (acCurrent || 0) !== 0 && (dcCurrent || 0) !== 0
				? NaN
				: (acCurrent || 0) === 0 ? dcCurrent : acCurrent
		property real acCurrent: NaN
		property real dcCurrent: NaN

		function reset() {
			acPower = NaN
			dcPower = NaN
			acCurrent = NaN
			dcCurrent = NaN
		}
	}

	property SystemAc ac: SystemAc {}
	property SystemDc dc: SystemDc {}

	property QtObject veBus: QtObject {
		property string serviceUid
		property real power
	}

	function reset() {
		solar.reset()
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
			//% "Discharging"
			return qsTrId("inverters_state_discharging")
		case VenusOS.System_State_Sustain:
			//% "Sustain"
			return qsTrId("inverters_state_sustain")
		case VenusOS.System_State_Recharge:
			//% "Recharge"
			return qsTrId("inverters_state_recharge")
		case VenusOS.System_State_ScheduledRecharge:
			//% "Scheduled recharge"
			return qsTrId("inverters_state_scheduledrecharge")
		}
		return ""
	}

	Component.onCompleted: Global.system = root
}
