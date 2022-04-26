/*
** Copyright (C) 2022 Victron Energy B.V.
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
		state = VenusOS.Ess_State_OptimizedWithBatteryLife
		minimumStateOfCharge = 0
		stateOfChargeLimit = 0
	}

	Component.onCompleted: Global.ess = root
}
