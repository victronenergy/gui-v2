/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		Global.system.state = VenusOS.System_State_AbsorptionCharging

		Global.system.ac.genset.resetPhases(_phaseCount)
		Global.system.ac.consumption.resetPhases(_phaseCount)
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
					Global.system.ac.genset.resetPhases(0)
					Global.system.ac.consumption.resetPhases(0)
				}

				if (config.dc) {
					randomizeDcValues.running = true
				} else {
					randomizeDcValues.running = false
					Global.system.dc.power = NaN
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
			let randomIndex = Math.floor(Math.random() * root._phaseCount)
			Global.system.ac.genset.setPhaseData(randomIndex, {
				power: Math.floor(Math.random() * 10000)
			})
			// For consumption, add some wild fluctuations that can be seen in the Brief side panel graph
			Global.system.ac.consumption.setPhaseData(randomIndex, {
				power: Math.floor(Math.random() * 800),
			})
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
		}
	}

	Component.onCompleted: {
		populate()
	}
}
