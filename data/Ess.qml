/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
//import Victron.Velib

Item {
	id: root

	readonly property int state: -1 // _getState()
	readonly property int minimumStateOfCharge: 0 // veMinimumSocLimit.value || 0
	readonly property int stateOfChargeLimit: 0 // veSocLimit.value || 0

	function setState(s) {
/*
		// Hub 4 mode
		if (s === Enums.Ess_State_ExternalControl && veHub4Mode.value !== Enums.Ess_Hub4ModeState_Disabled) {
			veHub4Mode.setValue(Enums.Ess_Hub4ModeState_Disabled)
		} else if (s !== Enums.Ess_State_ExternalControl && veHub4Mode.value === Enums.Ess_Hub4ModeState_Disabled) {
			veHub4Mode.setValue(Enums.Ess_Hub4ModeState_PhaseCompensation)
		}

		// BatteryLife state
		switch (s) {
		case Enums.Ess_State_OptimizedWithBatteryLife:
			if (!_isBatteryLifeActive(veState.value)) {
				veState.setValue(Enums.Ess_BatteryLifeState_BatteryLifeStateRestart)
			}
			break
		case Enums.Ess_State_OptimizedWithoutBatteryLife:
			if (!_isBatterySocGuardActive(veState.value)) {
				veState.setValue(Enums.Ess_BatteryLifeState_BatterySocGuardDefault)
			}
			break
		case Enums.Ess_State_KeepBatteriesCharged:
			veState.setValue(Enums.Ess_BatteryLifeState_BatteryKeepCharged)
			break
		case Enums.Ess_State_ExternalControl:
			veState.setValue(Enums.Ess_BatteryLifeState_BatteryLifeStateDisabled)
			break
		}
*/
	}

	function setMinimumStateOfCharge(soc) {
//		veMinimumSocLimit.setValue(soc)
	}
/*
	function _getState() {
		let hub4Mode = veHub4Mode.value
		let currentState = veState.value
		if (hub4Mode === undefined || currentState === undefined) {
			return -1
		}

		if (hub4Mode === Enums.Ess_Hub4ModeState_Disabled) {
			return Enums.Ess_State_ExternalControl
		} else if (_isBatteryLifeActive(currentState)) {
			return Enums.Ess_State_OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			return Enums.Ess_State_OptimizedWithoutBatteryLife
		} else if (currentState === Enums.Ess_BatteryLifeState_BatteryKeepCharged) {
			return Enums.Ess_State_KeepBatteriesCharged
		}
		return Enums.Ess_State_OptimizedWithBatteryLife
	}

	function _isBatteryLifeActive(s) {
		return s >= Enums.Ess_BatteryLifeState_BatteryLifeStateRestart
				&& s <= Enums.Ess_BatteryLifeState_BatteryLifeStateLowSocCharge
	}

	function _isBatterySocGuardActive(s) {
		return s >= Enums.Ess_BatteryLifeState_BatterySocGuardDefault
				&& s <= Enums.Ess_BatteryLifeState_BatterySocGuardLowSocCharge
	}

	VeQuickItem {
		id: veState
		uid: veSettings.childUId("/Settings/CGwacs/BatteryLife/State")
	}

	VeQuickItem {
		id: veHub4Mode
		uid: veSettings.childUId("/Settings/CGwacs/Hub4Mode")
	}

	VeQuickItem {
		id: veMinimumSocLimit
		uid: veSettings.childUId("/Settings/CGwacs/BatteryLife/MinimumSocLimit")
	}

	VeQuickItem {
		id: veSocLimit
		uid: veSettings.childUId("/Settings/CGwacs/BatteryLife/SocLimit")
	}
*/
}
