/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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

			property int state: VenusOS.Generators_State_Stopped
			property bool autoStart: true
			property int manualStartTimer: 60 * 60
			property int runtime
			property int runningBy: VenusOS.Generators_RunningBy_NotRunning

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
				runtime = 0
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
