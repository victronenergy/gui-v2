/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int state
	property int minimumStateOfCharge
	property int stateOfChargeLimit

	signal setStateRequested(state: int)
	signal setMinimumStateOfChargeRequested(soc: int)

	function reset() {
		state = Enums.Ess_State_OptimizedWithBatteryLife
		minimumStateOfCharge = 0
		stateOfChargeLimit = 0
	}

	function isBatteryLifeActive(batteryLifeState) {
		return batteryLifeState >= Enums.Ess_BatteryLifeState_Restart
				&& batteryLifeState <= Enums.Ess_BatteryLifeState_LowSocCharge
	}

	readonly property var stateModel: [
		//% "Keep batteries charged"
		{ display: qsTrId("ess_state_keep_batteries_charged"), value: Enums.Ess_State_KeepBatteriesCharged },
		//% "Optimized with battery life"
		{ display: qsTrId("ess_state_optimized_with_battery_life"), value: Enums.Ess_State_OptimizedWithBatteryLife },
		//% "Optimized without battery life"
		{ display: qsTrId("ess_state_optimized_without_battery_life"), value: Enums.Ess_State_OptimizedWithoutBatteryLife },
		//% "External control"
		{ display: qsTrId("ess_state_external_control"), value: Enums.Ess_State_ExternalControl },
	]

	function essStateToText(s) {
		for (let i = 0; i < stateModel.length; ++i) {
			const row = stateModel[i]
			if (row.value === s) {
				return row.display
			}
		}
		return ""
	}

	Component.onCompleted: Global.ess = root
}
