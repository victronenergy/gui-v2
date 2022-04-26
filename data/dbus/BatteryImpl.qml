/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	property var veSystem

	property VeQuickItem veSoc: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/Soc")
		onValueChanged: Global.battery.stateOfCharge = value === undefined ? NaN : value
	}

	property VeQuickItem vePower: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/Power")
		onValueChanged: Global.battery.power = value === undefined ? NaN : value
	}

	property VeQuickItem veCurrent: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/Current")
		onValueChanged: Global.battery.current = value === undefined ? NaN : value
	}

	property VeQuickItem veTemperature: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/Temperature")
		onValueChanged: Global.battery.temperature = value === undefined ? NaN : value
	}

	property VeQuickItem veTimeToGo: VeQuickItem {
		uid: veSystem.childUId("/Dc/Battery/TimeToGo")
		onValueChanged: Global.battery.timeToGo = value === undefined ? NaN : value
	}
}
