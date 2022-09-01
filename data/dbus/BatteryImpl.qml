/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

QtObject {
	property VeQuickItem veSoc: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Soc"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.stateOfCharge = value === undefined ? NaN : value
	}

	property VeQuickItem veVoltage: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Voltage"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.voltage = value === undefined ? NaN : value
	}

	property VeQuickItem vePower: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Power"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.power = value === undefined ? NaN : value
	}

	property VeQuickItem veCurrent: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Current"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.current = value === undefined ? NaN : value
	}

	property VeQuickItem veTemperature: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/Temperature"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.temperature_celsius = value === undefined ? NaN : value
	}

	property VeQuickItem veTimeToGo: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Dc/Battery/TimeToGo"
		Component.onCompleted: valueChanged(this, value)
		onValueChanged: Global.battery.timeToGo = value === undefined ? NaN : value
	}
}
