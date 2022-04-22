/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "../components/Utils.js" as Utils

Item {
	id: root

	property real stateOfCharge: 64.12
	property real power: 55.15
	property real current: 14.24
	property real temperature: 28.33
	property real timeToGo: 190 * 60
	property string icon: Utils.batteryIcon(root)
	property int mode: power === 0
			? VenusOS.Battery_Mode_Idle
			: (power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)
	property var chargeAnimation: chargeAnimation

	Item {
		id: chargeAnimation

		property bool running
	}

	/*
	SequentialAnimation on stateOfCharge {
		id: chargeAnimation
		loops: Animation.Infinite
		onRunningChanged: console.log("Battery animation 1: running:", running)

		ScriptAction {
			script: {
				root.power = Math.abs(root.power)
				root.current = Math.abs(root.current)
				onRunningChanged: console.log("Battery animation 2: running:", running)
			}
		}
		NumberAnimation {
			to: 100
			duration: 2 * 60 * 1000
			onRunningChanged: console.log("Battery animation 3: running:", running)
		}
		PauseAnimation {
			duration: 10 * 1000
			onRunningChanged: console.log("Battery animation 4: running:", running)
		}
		ScriptAction {
			script: {
				// negative value == discharging
				onRunningChanged: console.log("Battery animation 5: running:", running)
				root.power *= -1
				root.current *= -1
			}
		}
		NumberAnimation {
			onRunningChanged: console.log("Battery animation 6: running:", running)
			to: 0
			duration: 2 * 60 * 1000
		}
	}
	*/
	Component.onCompleted: console.log("blah")
}
