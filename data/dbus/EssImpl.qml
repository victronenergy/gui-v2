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

	function _getState() {
		let hub4Mode = veHub4Mode.value
		let currentState = veState.value
		if (hub4Mode === undefined || currentState === undefined) {
			return -1
		}

		if (hub4Mode === VenusOS.Ess_Hub4ModeState_Disabled) {
			return VenusOS.Ess_State_ExternalControl
		} else if (Global.ess.isBatteryLifeActive(currentState)) {
			return VenusOS.Ess_State_OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			return VenusOS.Ess_State_OptimizedWithoutBatteryLife
		} else if (currentState === VenusOS.Ess_BatteryLifeState_KeepCharged) {
			return VenusOS.Ess_State_KeepBatteriesCharged
		}
		return VenusOS.Ess_State_OptimizedWithBatteryLife
	}

	function _isBatterySocGuardActive(s) {
		return s >= VenusOS.Ess_BatteryLifeState_SocGuardDefault
				&& s <= VenusOS.Ess_BatteryLifeState_SocGuardLowSocCharge
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
				if (!Global.ess.isBatteryLifeActive(veState.value)) {
					veState.setValue(VenusOS.Ess_BatteryLifeState_Restart)
				}
				break
			case VenusOS.Ess_State_OptimizedWithoutBatteryLife:
				if (!_isBatterySocGuardActive(veState.value)) {
					veState.setValue(VenusOS.Ess_BatteryLifeState_SocGuardDefault)
				}
				break
			case VenusOS.Ess_State_KeepBatteriesCharged:
				veState.setValue(VenusOS.Ess_BatteryLifeState_KeepCharged)
				break
			case VenusOS.Ess_State_ExternalControl:
				veState.setValue(VenusOS.Ess_BatteryLifeState_Disabled)
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
		onValueChanged: Global.ess.minimumStateOfCharge = value || 0
	}

	property VeQuickItem veSocLimit: VeQuickItem {
		uid: "dbus/com.victronenergy.settings/Settings/CGwacs/BatteryLife/SocLimit"
		onValueChanged: Global.ess.stateOfChargeLimit = value || 0
	}
}
