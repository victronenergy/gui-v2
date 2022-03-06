/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils
import "../data" as DBusData

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

			property int state: DBusData.Generators.GeneratorState.Running
			property int manualStartTimer
			property int runtime: 35
			property int runningBy: DBusData.Generators.GeneratorRunningBy.Soc

			function start(durationSecs) {
				manualStartTimer = durationSecs
				state = DBusData.Generators.GeneratorState.Running
				runningBy = DBusData.Generators.GeneratorRunningBy.Manual
				runTimerTimer.start()
			}

			function stop() {
				state = DBusData.Generators.GeneratorState.Stopped
				runningBy = DBusData.Generators.GeneratorRunningBy.NotRunning
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
