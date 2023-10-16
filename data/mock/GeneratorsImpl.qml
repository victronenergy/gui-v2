/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator generatorObjects: Instantiator {
		model: 1    // TODO randomly generate multiple generators sometimes

		onObjectAdded: function(index, object) {
			Global.generators.addGenerator(object)
		}

		MockDevice {
			id: generator

			property int state: VenusOS.Generators_State_Running
			property bool autoStart: true
			property int manualStartTimer: 60 * 60
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

			function setAutoStart(auto) {
				autoStart = auto ? 1 : 0
			}

			property Timer runTimerTimer: Timer {
				interval: 1000
				repeat: true
				onTriggered: generator.runtime += 1
			}

			serviceUid: "com.victronenergy.generator.ttyUSB" + deviceInstance
			name: "Generator" + deviceInstance
		}
	}
}
