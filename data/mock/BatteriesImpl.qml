/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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

		serviceUid: "mock/com.victronenergy.battery.ttyUSB" + deviceInstance
		name: "Battery" + deviceInstance

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
				root.chargeTimer.beginCharging()
			}
		}
		PauseAnimation {
			duration: 2 * 60 * 1000 // wait for charge
		}
		PauseAnimation {
			duration: 10 * 1000
		}
		ScriptAction {
			script: {
				// negative value == discharging
				Global.batteries.system.power *= -1
				Global.batteries.system.current *= -1
				root.chargeTimer.beginDischarging()
			}
		}
		PauseAnimation {
			duration: 2 * 60 * 1000 // wait for discharge
		}
	}

	// Use a Timer rather than NumberAnimations because otherwise we get
	// a heap of animated property value updates showing up in the profiler.
	property Timer chargeTimer: Timer {
		running: false
		repeat: true
		interval: 1000
		property real stepSize: 1.0 // will take 100 steps to charge to 100% from 0%.
		function beginCharging() { stepSize = 1.0; start() }
		function beginDischarging() { stepSize = -1.0; start() }
		onTriggered: {
			var newSoc = Global.batteries.system.stateOfCharge + stepSize
			if (newSoc >= 0 && newSoc <= 100) { Global.batteries.system.stateOfCharge = newSoc }
			else if (newSoc > 100) { Global.batteries.system.stateOfCharge = 100; stop() }
			else if (newSoc < 0) { Global.batteries.system.stateOfCharge = 0; stop() }
			else { stop() }
		}
	}
}
