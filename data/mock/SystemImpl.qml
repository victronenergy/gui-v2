/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		Global.system.state = VenusOS.System_State_AbsorptionCharging
		Global.system.ac.consumption.setPhaseCount(_phaseCount)
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetSystemRequested(config) {
			Global.system.state = VenusOS.System_State_Off

			if (config) {
				Global.system.state = config.state

				if (config.ac) {
					randomizeAcValues.running = true
				} else {
					randomizeAcValues.running = false
					Global.system.ac.consumption.setPhaseCount(0)
				}

				if (config.dc) {
					randomizeDcValues.running = true
				} else {
					randomizeDcValues.running = false
					Global.system.dc.reset()
				}
			}
		}
	}

	//--- AC data ---

	readonly property int _phaseCount: 1 + Math.floor(Math.random() * 3)

	property Timer randomizeAcValues: Timer {
		running: Global.demoManager.timersActive
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			// Use some wild fluctuations that can be seen in the Brief side panel graph
			const randomIndex = Math.floor(Math.random() * root._phaseCount)
			const power = Math.floor(Math.random() * 800)
			Global.system.ac.consumption.setPhaseData(randomIndex, { power: power, current: power * 0.01})
		}
	}

	//--- DC data ---

	property Timer randomizeDcValues: Timer {
		running: Global.demoManager.timersActive
		interval: 1000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			Global.system.dc.power = 500 + Math.floor(Math.random() * 100)
			Global.system.dc.voltage = 20 + Math.floor(Math.random() * 10)
		}
	}

	Component.onCompleted: {
		populate()
	}
}
