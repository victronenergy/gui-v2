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
		readonly property string icon: (power === 0 || power === NaN)
				? "/images/battery.svg"
				: power > 0
				  ? "/images/battery_charging.svg"
				  : "/images/battery_discharging.svg"
		readonly property int mode: (power === 0 || power === NaN)
				? VenusOS.Battery_Mode_Idle
				: (power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)

		name: "Fake battery"

		Component.onCompleted: {
			Global.batteries.addBattery(dummyBattery)
		}
	}

	property Connections batteryConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetBatteryRequested(config) {
			if (config) {
				for (var propName in config) {
					Global.batteries.first[propName] = config[propName]
				}
			}
		}
	}

	property SequentialAnimation socAnimation: SequentialAnimation {
		running: Global.mockDataSimulator.timersActive && !!Global.batteries.first
		loops: Animation.Infinite

		ScriptAction {
			script: {
				Global.batteries.first.power = Math.abs(Global.batteries.first.power)
				Global.batteries.first.current = Math.abs(Global.batteries.first.current)
			}
		}
		NumberAnimation {
			target: Global.batteries.first
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
				Global.batteries.first.power *= -1
				Global.batteries.first.current *= -1
			}
		}
		NumberAnimation {
			target: Global.batteries.first
			property: "stateOfCharge"
			to: 0
			duration: 2 * 60 * 1000
		}
	}
}
