/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	readonly property DataPoint veSoc: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/Soc"
	}

	readonly property DataPoint veVoltage: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/Voltage"
	}

	readonly property DataPoint vePower: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/Power"
	}

	readonly property DataPoint veCurrent: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/Current"
	}

	readonly property DataPoint veTemperature: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/Temperature"
	}

	readonly property DataPoint veTimeToGo: DataPoint {
		source: "com.victronenergy.system/Dc/Battery/TimeToGo"
	}

	Component.onCompleted: {
		Global.battery.stateOfCharge = Qt.binding(function() {
			return veSoc.value === undefined ? NaN : veSoc.value
		})
		Global.battery.voltage = Qt.binding(function() {
			return veVoltage.value === undefined ? NaN : veVoltage.value
		})
		Global.battery.power = Qt.binding(function() {
			return vePower.value === undefined ? NaN : vePower.value
		})
		Global.battery.current = Qt.binding(function() {
			return veCurrent.value === undefined ? NaN : veCurrent.value
		})
		Global.battery.temperature_celsius = Qt.binding(function() {
			return veTemperature.value === undefined ? NaN : veTemperature.value
		})
		Global.battery.timeToGo = Qt.binding(function() {
			return veTimeToGo.value === undefined ? NaN : veTimeToGo.value
		})
	}
}
