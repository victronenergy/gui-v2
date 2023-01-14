/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: root

	readonly property int state: _getState()
	onStateChanged: Global.ess.state = state

	function _getState() {
		let hub4Mode = veHub4Mode.value
		let currentState = veBatteryLifeState.value
		if (hub4Mode === undefined || currentState === undefined) {
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
				if (!Global.ess.isBatteryLifeActive(veBatteryLifeState.value)) {
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

	readonly property DataPoint veBatteryLifeState: DataPoint {
		source: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/State"
	}

	readonly property DataPoint veHub4Mode: DataPoint {
		source: "com.victronenergy.settings/Settings/CGwacs/Hub4Mode"
	}

	readonly property DataPoint veMinimumSocLimit: DataPoint {
		source: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/MinimumSocLimit"
	}

	readonly property DataPoint veSocLimit: DataPoint {
		source: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/SocLimit"
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
