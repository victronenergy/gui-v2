/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var dummyBattery: MockDevice {
		property real stateOfCharge: 64.12335
		property real voltage: 55.1534
		property real power: voltage * current
		property real current: 14.243
		property real temperature_celsius: 28.33
		property real timeToGo: (24 * 60 * 60) + 190 * 60 // 1d 3h 10m
		readonly property string icon: Global.batteries.batteryIcon(dummyBattery)
		readonly property int mode: Global.batteries.batteryMode(dummyBattery)

		name: "Fake battery"

		Component.onCompleted: {
			Global.batteries.addBattery(dummyBattery)
			Global.batteries.system = dummyBattery
		}
	}

	property Connections batteryConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetBatteryRequested(config) {
			if (config) {
				for (var propName in config) {
					Global.batteries.system[propName] = config[propName]
				}
			}
		}
	}

	property SequentialAnimation socAnimation: SequentialAnimation {
		running: Global.mockDataSimulator.timersActive
		loops: Animation.Infinite

		ScriptAction {
			script: {
				Global.batteries.system.power = Math.abs(Global.batteries.system.power)
				Global.batteries.system.current = Math.abs(Global.batteries.system.current)
			}
		}
		NumberAnimation {
			target: Global.batteries.system
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
				Global.batteries.system.power *= -1
				Global.batteries.system.current *= -1
			}
		}
		NumberAnimation {
			target: Global.batteries.system
			property: "stateOfCharge"
			to: 0
			duration: 2 * 60 * 1000
		}
	}
}
