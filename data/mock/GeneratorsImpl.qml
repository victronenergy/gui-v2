/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	Generator {
		id: startstop0
		serviceUid: "mock/com.victronenergy.generator.startstop0"
	}

	Connections {
		target: startstop0._manualStart
		enabled: startstop0.valid

		// When the user does a manual start/stop, update the generator state.
		function onValueChanged() {
			if (target.value === 1) {
				startstop0._state.setValue(VenusOS.Generators_State_Running)
				startstop0._runningBy.setValue(VenusOS.Generators_RunningBy_Manual)
			} else if (target.value === 0) {
				startstop0._state.setValue(VenusOS.Generators_State_Stopped)
				startstop0._runningBy.setValue(VenusOS.Generators_RunningBy_NotRunning)
				startstop0._runtime.setValue(0)
			}
		}

		// When the generator is running, update the /Runtime.
		property Timer _runTimeTick: Timer {
			running: MockManager.timersActive
					 && startstop0.state === VenusOS.Generators_State_Running
			interval: 1000
			repeat: true
			onTriggered: {
				startstop0._runtime.setValue(startstop0.runtime + 1)
			}
		}
	}
}
