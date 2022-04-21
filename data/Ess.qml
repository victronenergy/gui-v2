/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	readonly property int state: _getState()
	readonly property int minimumStateOfCharge: veMinimumSocLimit.value || 0
	readonly property int stateOfChargeLimit: veSocLimit.value || 0

	function setState(s) {
		// Hub 4 mode
		if (s === VenusOS.Ess_State_ExternalControl && veHub4Mode.value !== VenusOS.Ess_Hub4ModeState_Disabled) {
			veHub4Mode.setValue(VenusOS.Ess_Hub4ModeState_Disabled)
		} else if (s !== VenusOS.Ess_State_ExternalControl && veHub4Mode.value === VenusOS.Ess_Hub4ModeState_Disabled) {
			veHub4Mode.setValue(VenusOS.Ess_Hub4ModeState_PhaseCompensation)
		}

		// BatteryLife state
		switch (s) {
		case VenusOS.Ess_State_OptimizedWithBatteryLife:
			if (!_isBatteryLifeActive(veState.value)) {
				veState.setValue(VenusOS.Ess_BatteryLifeState_BatteryLifeStateRestart)
			}
			break
		case VenusOS.Ess_State_OptimizedWithoutBatteryLife:
			if (!_isBatterySocGuardActive(veState.value)) {
				veState.setValue(VenusOS.Ess_BatteryLifeState_BatterySocGuardDefault)
			}
			break
		case VenusOS.Ess_State_KeepBatteriesCharged:
			veState.setValue(VenusOS.Ess_BatteryLifeState_BatteryKeepCharged)
			break
		case VenusOS.Ess_State_ExternalControl:
			veState.setValue(VenusOS.Ess_BatteryLifeState_BatteryLifeStateDisabled)
			break
		}
	}

	function setMinimumStateOfCharge(soc) {
		veMinimumSocLimit.setValue(soc)
	}

	function _getState() {
		let hub4Mode = veHub4Mode.value
		let currentState = veState.value
		if (hub4Mode === undefined || currentState === undefined) {
			return -1
		}

		if (hub4Mode === VenusOS.Ess_Hub4ModeState_Disabled) {
			return VenusOS.Ess_State_ExternalControl
		} else if (_isBatteryLifeActive(currentState)) {
			return VenusOS.Ess_State_OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			return VenusOS.Ess_State_OptimizedWithoutBatteryLife
		} else if (currentState === VenusOS.Ess_BatteryLifeState_BatteryKeepCharged) {
			return VenusOS.Ess_State_KeepBatteriesCharged
		}
		return VenusOS.Ess_State_OptimizedWithBatteryLife
	}

	function _isBatteryLifeActive(s) {
		return s >= VenusOS.Ess_BatteryLifeState_BatteryLifeStateRestart
				&& s <= VenusOS.Ess_BatteryLifeState_BatteryLifeStateLowSocCharge
	}

	function _isBatterySocGuardActive(s) {
		return s >= VenusOS.Ess_BatteryLifeState_BatterySocGuardDefault
				&& s <= VenusOS.Ess_BatteryLifeState_BatterySocGuardLowSocCharge
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
}
