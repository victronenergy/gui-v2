/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

QtObject {
	id: root

	readonly property int state: _getState()
	onStateChanged: if (!!Global.ess) Global.ess.state = state

	function _getState() {
		let hub4Mode = veHub4Mode.value
		let currentState = veBatteryLifeState.value
		if (!Global.ess || hub4Mode === undefined || currentState === undefined) {
			return -1
		}

		let essState = VenusOS.Ess_State_OptimizedWithBatteryLife
		if (hub4Mode === VenusOS.Ess_Hub4ModeState_Disabled) {
			essState = VenusOS.Ess_State_ExternalControl
		} else if (Global.ess.isBatteryLifeActive(currentState)) {
			essState = VenusOS.Ess_State_OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			essState = VenusOS.Ess_State_OptimizedWithoutBatteryLife
		} else if (currentState === VenusOS.Ess_BatteryLifeState_KeepCharged) {
			essState = VenusOS.Ess_State_KeepBatteriesCharged
		}
		return essState
	}

	function _isBatterySocGuardActive(essState) {
		return essState >= VenusOS.Ess_BatteryLifeState_SocGuardDefault
				&& essState <= VenusOS.Ess_BatteryLifeState_SocGuardLowSocCharge
	}

	property Connections essConn: Connections {
		target: Global.ess

		function onSetStateRequested(essState) {
			// Hub 4 mode
			if (essState === VenusOS.Ess_State_ExternalControl && veHub4Mode.value !== VenusOS.Ess_Hub4ModeState_Disabled) {
				veHub4Mode.setValue(VenusOS.Ess_Hub4ModeState_Disabled)
			} else if (essState !== VenusOS.Ess_State_ExternalControl && veHub4Mode.value === VenusOS.Ess_Hub4ModeState_Disabled) {
				veHub4Mode.setValue(VenusOS.Ess_Hub4ModeState_PhaseCompensation)
			}

			// BatteryLife state
			let batteryLifeState = null
			switch (essState) {
			case VenusOS.Ess_State_OptimizedWithBatteryLife:
				if (!!Global.ess && !Global.ess.isBatteryLifeActive(veBatteryLifeState.value)) {
					batteryLifeState = VenusOS.Ess_BatteryLifeState_Restart
				}
				break
			case VenusOS.Ess_State_OptimizedWithoutBatteryLife:
				if (!_isBatterySocGuardActive(veBatteryLifeState.value)) {
					batteryLifeState = VenusOS.Ess_BatteryLifeState_SocGuardDefault
				}
				break
			case VenusOS.Ess_State_KeepBatteriesCharged:
				batteryLifeState = VenusOS.Ess_BatteryLifeState_KeepCharged
				break
			case VenusOS.Ess_State_ExternalControl:
				batteryLifeState = VenusOS.Ess_BatteryLifeState_Disabled
				break
			default:
				console.warn("Unrecognised ESS state:", essState)
				break
			}
			if (batteryLifeState !== null) {
				veBatteryLifeState.setValue(batteryLifeState)
			}
		}

		function onSetMinimumStateOfChargeRequested(soc) {
			veMinimumSocLimit.setValue(soc)
		}
	}

	readonly property VeQuickItem veBatteryLifeState: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/State"
	}

	readonly property VeQuickItem veHub4Mode: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/Hub4Mode"
	}

	readonly property VeQuickItem veMinimumSocLimit: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/MinimumSocLimit"
	}

	readonly property VeQuickItem veSocLimit: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/SocLimit"
	}

	Component.onCompleted: {
		Global.ess.minimumStateOfCharge = Qt.binding(function() {
			return veMinimumSocLimit.value || 0
		})
		Global.ess.stateOfChargeLimit = Qt.binding(function() {
			return veSocLimit.value || 0
		})
	}
}
