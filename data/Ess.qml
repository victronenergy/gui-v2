/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	enum State {
		OptimizedWithBatteryLife,
		OptimizedWithoutBatteryLife,
		KeepBatteriesCharged,
		ExternalControl // Used internally to determine overall ESS state
	}

	// For internal use
	enum Hub4ModeState {
		Hub4PhaseCompensation = 1,
		Hub4PhaseSplit = 2,
		Hub4Disabled = 3
	}

	// For internal use
	enum BatteryLifeState {
		BatteryLifeStateDisabled = 0,
		BatteryLifeStateRestart = 1,
		BatteryLifeStateDefault = 2,
		BatteryLifeStateAbsorption = 3,
		BatteryLifeStateFloat = 4,
		BatteryLifeStateDischarged = 5,
		BatteryLifeStateForceCharge = 6,
		BatteryLifeStateSustain = 7,
		BatteryLifeStateLowSocCharge = 8,
		BatteryKeepCharged = 9,
		BatterySocGuardDefault = 10,
		BatterySocGuardDischarged = 11,
		BatterySocGuardLowSocCharge = 12
	}

	readonly property int state: _getState()
	readonly property int minimumStateOfCharge: veMinimumSocLimit.value || 0
	readonly property int stateOfChargeLimit: veSocLimit.value || 0

	function setState(s) {
		// Hub 4 mode
		if (s === Ess.State.ExternalControl && veHub4Mode.value !== Ess.Hub4ModeState.Hub4Disabled) {
			veHub4Mode.setValue(Ess.Hub4ModeState.Hub4Disabled)
		} else if (s !== Ess.State.ExternalControl && veHub4Mode.value === Ess.Hub4ModeState.Hub4Disabled) {
			veHub4Mode.setValue(Ess.Hub4ModeState.Hub4PhaseCompensation)
		}

		// BatteryLife state
		switch (s) {
		case Ess.State.OptimizedWithBatteryLife:
			if (!_isBatteryLifeActive(veState.value)) {
				veState.setValue(Ess.BatteryLifeState.BatteryLifeStateRestart)
			}
			break
		case Ess.State.OptimizedWithoutBatteryLife:
			if (!_isBatterySocGuardActive(veState.value)) {
				veState.setValue(Ess.BatteryLifeState.BatterySocGuardDefault)
			}
			break
		case Ess.State.KeepBatteriesCharged:
			veState.setValue(Ess.BatteryLifeState.BatteryKeepCharged)
			break
		case Ess.State.ExternalControl:
			veState.setValue(Ess.BatteryLifeState.BatteryLifeStateDisabled)
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

		if (hub4Mode === Ess.Hub4ModeState.Hub4Disabled) {
			return Ess.State.ExternalControl
		} else if (_isBatteryLifeActive(currentState)) {
			return Ess.State.OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			return Ess.State.OptimizedWithoutBatteryLife
		} else if (currentState === Ess.BatteryLifeState.BatteryKeepCharged) {
			return Ess.State.KeepBatteriesCharged
		}
		return Ess.State.OptimizedWithBatteryLife
	}

	function _isBatteryLifeActive(s) {
		return s >= Ess.BatteryLifeState.BatteryLifeStateRestart
				&& s <= Ess.BatteryLifeState.BatteryLifeStateLowSocCharge
	}

	function _isBatterySocGuardActive(s) {
		return s >= Ess.BatteryLifeState.BatterySocGuardDefault
				&& s <= Ess.BatteryLifeState.BatterySocGuardLowSocCharge
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
