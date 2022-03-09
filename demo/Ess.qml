/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils
import "../data" as DBusData

Item {
	id: root

	property int state: DBusData.Ess.State.OptimizedWithBatteryLife
	property int minimumStateOfCharge: 60
	property int stateOfChargeLimit: 80

	function setState(s) {
		state = s
	}

	function setMinimumStateOfCharge(soc) {
		minimumStateOfCharge = soc
	}
}
