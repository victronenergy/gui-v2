/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	Instantiator {
		model: [
			"mock/com.victronenergy.generator.startstop0",
			"mock/com.victronenergy.generator.startstop1"
		]

		delegate: Item {
			Generator {
				id: generator
				serviceUid: modelData
			}

			Connections {
				target: generator._manualStart
				enabled: generator.valid

				// When the user does a manual start/stop, update the generator state.
				function onValueChanged() {
					if (target.value === 1) {
						generator._state.setValue(VenusOS.Generators_State_Running)
						generator._runningBy.setValue(VenusOS.Generators_RunningBy_Manual)
					} else if (target.value === 0) {
						generator._state.setValue(VenusOS.Generators_State_Stopped)
						generator._runningBy.setValue(VenusOS.Generators_RunningBy_NotRunning)
						generator._runtime.setValue(0)
					}
				}

				// When the generator is running, update the /Runtime.
				property Timer _runTimeTick: Timer {
					running: MockManager.timersActive
							 && generator.state === VenusOS.Generators_State_Running
					interval: 1000
					repeat: true
					onTriggered: {
						generator._runtime.setValue(generator.runtime + 1)
					}
				}
			}
		}
	}
}
