/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		for (let i = 0; i < generatorObjects.count; ++i) {
			Global.generators.addGenerator(generatorObjects.objectAt(i))
		}
		Global.generators.first = generatorObjects.objectAt(0)
	}

	property Instantiator generatorObjects: Instantiator {
		model: 1    // TODO randomly generate multiple generators sometimes

		QtObject {
			id: generator

			property int state: VenusOS.Generators_State_Running
			property int manualStartTimer
			property int runtime: 35
			property int runningBy: VenusOS.Generators_RunningBy_Soc

			function start(durationSecs) {
				manualStartTimer = durationSecs
				state = VenusOS.Generators_State_Running
				runningBy = VenusOS.Generators_RunningBy_Manual
				runTimerTimer.start()
			}

			function stop() {
				state = VenusOS.Generators_State_Stopped
				runningBy = VenusOS.Generators_RunningBy_NotRunning
				runTimerTimer.stop()
			}

			property Timer runTimerTimer: Timer {
				interval: 1000
				repeat: true
				onTriggered: generator.runtime += 1
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
