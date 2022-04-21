/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property var generator0

	property ListModel model: ListModel {
		Component.onCompleted: {
			for (let i = 0; i < instantiator.count; ++i) {
				append({ generator: instantiator.objectAt(i) })
			}
			generator0 = instantiator.objectAt(0)
		}
	}

	Instantiator {
		id: instantiator

		model: 1    // TODO randomly generate multiple generators sometimes

		QtObject {
			id: generator

			property int state: Enums.Generators_State_Running
			property int manualStartTimer
			property int runtime: 35
			property int runningBy: Enums.Generators_RunningBy_Soc

			function start(durationSecs) {
				manualStartTimer = durationSecs
				state = Enums.Generators_State_Running
				runningBy = Enums.Generators_RunningBy_Manual
				runTimerTimer.start()
			}

			function stop() {
				state = Enums.Generators_State_Stopped
				runningBy = Enums.Generators_RunningBy_NotRunning
				runTimerTimer.stop()
			}

			property Timer runTimerTimer: Timer {
				interval: 1000
				repeat: true
				onTriggered: generator.runtime += 1
			}
		}
	}
}
