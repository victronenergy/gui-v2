/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property real stateOfCharge
	property real power
	property real current
	property real temperature
	property real timeToGo      // in seconds
	property string icon: (power === 0 || power === NaN)
			? "../images/battery.svg"
			: power > 0
			  ? "../images/battery_charging.svg"
			  : "../images/battery_discharging.svg"
	property int mode: (power === 0 || power === NaN)
			? VenusOS.Battery_Mode_Idle
			: (power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)

	function reset() {
		stateOfCharge = NaN
		power = NaN
		current = NaN
		temperature = NaN
		timeToGo = NaN
	}

	Component.onCompleted: Global.battery = root
}
