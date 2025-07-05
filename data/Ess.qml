/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemSettingsUid
	readonly property int state: _getState()
	readonly property int minimumStateOfCharge: _minimumSocLimit.valid ? _minimumSocLimit.value : 0
	readonly property int stateOfChargeLimit: _socLimit.valid ? _socLimit.value : 0

	readonly property var stateModel: [
		{
			//% "Keep batteries charged"
			display: qsTrId("ess_state_keep_batteries_charged"),
			//% "Keep charged"
			buttonText: qsTrId("ess_state_keep_batteries_charged_button"),
			value: VenusOS.Ess_State_KeepBatteriesCharged
		},
		{
			//% "Optimized with BatteryLife"
			display: qsTrId("ess_state_optimized_with_batterylife"),
			//% "Optimized + BatteryLife"
			buttonText: qsTrId("ess_state_optimized_with_batterylife_button"),
			value: VenusOS.Ess_State_OptimizedWithBatteryLife
		},
		{
			//% "Optimized without BatteryLife"
			display: qsTrId("ess_state_optimized_without_batterylife"),
			//% "Optimized"
			buttonText: qsTrId("ess_state_optimized_without_batterylife_button"),
			value: VenusOS.Ess_State_OptimizedWithoutBatteryLife
		},
		{
			//% "External control"
			display: qsTrId("ess_state_external_control"),
			value: VenusOS.Ess_State_ExternalControl
		}
	]

	function isBatteryLifeActive(batteryLifeState) {
		return batteryLifeState >= VenusOS.Ess_BatteryLifeState_Restart
				&& batteryLifeState <= VenusOS.Ess_BatteryLifeState_LowSocCharge
	}

	function essStateToText(s) {
		for (let i = 0; i < stateModel.length; ++i) {
			const row = stateModel[i]
			if (row.value === s) {
				return row.display
			}
		}
		return ""
	}

	function essStateToButtonText(s) {
		for (let i = 0; i < stateModel.length; ++i) {
			const row = stateModel[i]
			if (row.value === s) {
				return (row.buttonText === undefined) ? row.display : row.buttonText
			}
		}
		return ""
	}

	function setState(essState) {
		if (root.state === VenusOS.Ess_State_ExternalControl) {
			// When changing away from External Control, /CGwacs/Hub4Mode is reset, so user
			// should verify the settings changes.
			//% "Make sure to check the Multiphase regulation setting"
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("ess_check_multiphase_regulation_setting"), 10000)
		}

		// Hub 4 mode
		if (essState === VenusOS.Ess_State_ExternalControl && _hub4Mode.value !== VenusOS.Ess_Hub4ModeState_Disabled) {
			_hub4Mode.setValue(VenusOS.Ess_Hub4ModeState_Disabled)
		} else if (essState !== VenusOS.Ess_State_ExternalControl && _hub4Mode.value === VenusOS.Ess_Hub4ModeState_Disabled) {
			_hub4Mode.setValue(VenusOS.Ess_Hub4ModeState_PhaseCompensation)
		}

		// BatteryLife state
		let batteryLifeState = null
		switch (essState) {
		case VenusOS.Ess_State_OptimizedWithBatteryLife:
			if (!isBatteryLifeActive(_batteryLifeState.value)) {
				batteryLifeState = VenusOS.Ess_BatteryLifeState_Restart
			}
			break
		case VenusOS.Ess_State_OptimizedWithoutBatteryLife:
			if (!_isBatterySocGuardActive(_batteryLifeState.value)) {
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
			_batteryLifeState.setValue(batteryLifeState)
		}
	}

	function _getState() {
		let hub4Mode = _hub4Mode.value
		let currentState = _batteryLifeState.value
		if (hub4Mode === undefined || currentState === undefined) {
			return -1
		}

		let essState = VenusOS.Ess_State_OptimizedWithBatteryLife
		if (hub4Mode === VenusOS.Ess_Hub4ModeState_Disabled) {
			essState = VenusOS.Ess_State_ExternalControl
		} else if (isBatteryLifeActive(currentState)) {
			essState = VenusOS.Ess_State_OptimizedWithBatteryLife
		} else if (_isBatterySocGuardActive(currentState)) {
			essState = VenusOS.Ess_State_OptimizedWithoutBatteryLife
		} else if (currentState === VenusOS.Ess_BatteryLifeState_KeepCharged) {
			essState = VenusOS.Ess_State_KeepBatteriesCharged
		}
		return essState
	}

	function setMinimumStateOfCharge(soc) {
		_minimumSocLimit.setValue(soc)
	}

	function _isBatterySocGuardActive(essState) {
		return essState >= VenusOS.Ess_BatteryLifeState_SocGuardDefault
				&& essState <= VenusOS.Ess_BatteryLifeState_SocGuardLowSocCharge
	}

	readonly property VeQuickItem _batteryLifeState: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/CGwacs/BatteryLife/State"
	}

	readonly property VeQuickItem _hub4Mode: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/CGwacs/Hub4Mode"
	}

	readonly property VeQuickItem _minimumSocLimit: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/CGwacs/BatteryLife/MinimumSocLimit"
	}

	readonly property VeQuickItem _socLimit: VeQuickItem {
		uid: root.systemSettingsUid + "/Settings/CGwacs/BatteryLife/SocLimit"
	}
}
