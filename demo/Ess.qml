/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property int state: VenusOS.Ess_State_OptimizedWithBatteryLife
	property int minimumStateOfCharge: 60
	property int stateOfChargeLimit: 80

	function setState(s) {
		state = s
	}

	function setMinimumStateOfCharge(soc) {
		minimumStateOfCharge = soc
	}
}
