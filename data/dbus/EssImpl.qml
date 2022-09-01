/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

QtObject {
	id: root

	readonly property int state: _getState()
	onStateChanged: Global.ess.state = state

	readonly property int minimumStateOfCharge: veMinimumSocLimit.value || 0
	readonly property int stateOfChargeLimit: veSocLimit.value || 0

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

	property Connections essConn: Connections {
		target: Global.ess

		function onSetStateRequested(s) {
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
			default:
				console.warn("Unrecognised ESS state:", s)
				break
			}
		}

		function onSetMinimumStateOfChargeRequested(soc) {
			veMinimumSocLimit.setValue(soc)
		}
	}

	property VeQuickItem veState: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/CGwacs/BatteryLife/State"
	}

	property VeQuickItem veHub4Mode: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/CGwacs/Hub4Mode"
	}

	property VeQuickItem veMinimumSocLimit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/CGwacs/BatteryLife/MinimumSocLimit"
	}

	property VeQuickItem veSocLimit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/CGwacs/BatteryLife/SocLimit"
	}
}
