/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		Global.battery.stateOfCharge = 64.12335
		Global.battery.voltage = 55.1534
		Global.battery.current = 14.243
		Global.battery.power = Global.battery.voltage * Global.battery.current
		Global.battery.temperature_celsius = 28.33
		Global.battery.timeToGo = 190 * 60
		_initialized = true
	}

	property bool _initialized

	property Connections batteryConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetBatteryRequested(config) {
			if (config) {
				for (var propName in config) {
					Global.battery[propName] = config[propName]
				}
			}
		}
	}

	property SequentialAnimation socAnimation: SequentialAnimation {
		running: Global.mockDataSimulator.timersActive && _initialized
		loops: Animation.Infinite

		ScriptAction {
			script: {
				Global.battery.power = Math.abs(Global.battery.power)
				Global.battery.current = Math.abs(Global.battery.current)
			}
		}
		NumberAnimation {
			target: Global.battery
			property: "stateOfCharge"
			to: 100
			duration: 2 * 60 * 1000
		}
		PauseAnimation {
			duration: 10 * 1000
		}
		ScriptAction {
			script: {
				// negative value == discharging
				Global.battery.power *= -1
				Global.battery.current *= -1
			}
		}
		NumberAnimation {
			target: Global.battery
			property: "stateOfCharge"
			to: 0
			duration: 2 * 60 * 1000
		}
	}

	Component.onCompleted: {
		populate()
	}
}
