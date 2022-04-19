/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
//import Victron.Velib
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
			? Enums.Battery_Mode_Idle
			: (power > 0 ? Enums.Battery_Mode_Charging : Enums.Battery_Mode_Discharging)
	property var chargeAnimation: chargeAnimation

	SequentialAnimation on stateOfCharge {
		id: chargeAnimation
		loops: Animation.Infinite

		ScriptAction {
			script: {
				root.power = Math.abs(root.power)
				root.current = Math.abs(root.current)
			}
		}
		NumberAnimation {
			to: 100
			duration: 2 * 60 * 1000
		}
		PauseAnimation {
			duration: 10 * 1000
		}
		ScriptAction {
			script: {
				// negative value == discharging
				root.power *= -1
				root.current *= -1
			}
		}
		NumberAnimation {
			to: 0
			duration: 2 * 60 * 1000
		}
	}
}
