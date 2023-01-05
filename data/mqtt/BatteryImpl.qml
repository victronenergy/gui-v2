/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	property VeQuickItem veSoc: VeQuickItem {
		function _update() {
			Global.battery.stateOfCharge = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Soc"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem veVoltage: VeQuickItem {
		function _update() {
			Global.battery.voltage = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Voltage"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem vePower: VeQuickItem {
		function _update() {
			Global.battery.power = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Power"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem veCurrent: VeQuickItem {
		function _update() {
			Global.battery.current = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Current"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem veTemperature: VeQuickItem {
		function _update() {
			Global.battery.temperature_celsius = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/Temperature"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}

	property VeQuickItem veTimeToGo: VeQuickItem {
		function _update() {
			Global.battery.timeToGo = value === undefined ? NaN : value
		}
		uid: "mqtt/system/0/Dc/Battery/TimeToGo"
		Component.onCompleted: _update()
		onValueChanged: _update()
	}
}
