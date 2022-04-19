/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
//import Victron.Velib
import "../components/Utils.js" as Utils

Item {
	property real stateOfCharge: 0 // veBatterySoC.value || 0
	property real power: 0 // veBatteryPower.value || 0
	property real current: 0 // veBatteryCurrent.value || 0
	property real temperature: 0 // veBatteryTemp.value || 0
	property real timeToGo: 0 // veTimeToGo.value || 0    // in seconds
	property string icon: Utils.batteryIcon(root)
	property int mode: power === 0
			? Enums.Battery_Mode_Idle
			: (power > 0 ? Enums.Battery_Mode_Charging : Enums.Battery_Mode_Discharging)
/*
	VeQuickItem {
		id: veBatterySoC
		uid: veSystem.childUId("/Dc/Battery/Soc")
	}

	VeQuickItem {
		id: veBatteryPower
		uid: veSystem.childUId("/Dc/Battery/Power")
	}

	VeQuickItem {
		id: veBatteryCurrent
		uid: veSystem.childUId("/Dc/Battery/Current")
	}

	VeQuickItem {
		id: veBatteryTemp
		uid: veSystem.childUId("/Dc/Battery/Temperature")
	}

	VeQuickItem {
		id: veTimeToGo
		uid: veSystem.childUId("/Dc/Battery/TimeToGo")
	}
*/
}
