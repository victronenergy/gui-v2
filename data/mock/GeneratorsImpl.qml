/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property Generator generator: Generator {
		serviceUid: "mock/com.victronenergy.generator.startstop0"

		Component.onCompleted: {
			_deviceInstance.setValue(0)
			_productName.setValue("Start/Stop generator")
			_state.setValue(VenusOS.Generators_State_Running)
			_runningBy.setValue(VenusOS.Generators_RunningBy_Soc)
			setAutoStart(true)
		}

		property Connections _stateUpdate: Connections {
			target: root.generator._manualStart
			function onValueChanged() {
				if (target.value === 1) {
					root.generator._state.setValue(VenusOS.Generators_State_Running)
					root.generator._runningBy.setValue(VenusOS.Generators_RunningBy_Manual)
				} else if (target.value === 0) {
					root.generator._state.setValue(VenusOS.Generators_State_Stopped)
					root.generator._runningBy.setValue(VenusOS.Generators_RunningBy_NotRunning)
				}
			}

			property Timer _runTimeTick: Timer {
				running: root.generator.state === VenusOS.Generators_State_Running
				interval: 1000
				repeat: true
				onTriggered: root.generator._runtime.setValue(root.generator.runtime + 1)
			}
		}

		// Some dummy system settings
		property VeQuickItem _accumulatedTotal: VeQuickItem {
			uid: root.generator.serviceUid + "/AccumulatedTotal"
			Component.onCompleted: setValue(3600)
		}
		property VeQuickItem _error: VeQuickItem {
			uid: root.generator.serviceUid + "/Error"
			Component.onCompleted: setValue(1)
		}
		property VeQuickItem _nextStartTimer: VeQuickItem {
			uid: root.generator.serviceUid + "/NextTestRun"
			Component.onCompleted: setValue(Date.now() / 1000 + 80)
		}
		property VeQuickItem _serviceCounterReset: VeQuickItem {
			uid: root.generator.serviceUid + "/ServiceCounterReset"
			Component.onCompleted: setValue(0)
		}
		property VeQuickItem _testRunIntervalRuntime: VeQuickItem {
			uid: root.generator.serviceUid + "/TestRunIntervalRuntime"
			Component.onCompleted: setValue(5678)
		}
		property VeQuickItem _capabilities: VeQuickItem {
			uid: root.generator.serviceUid + "/Capabilities"
			Component.onCompleted: setValue(1)
		}
	}

	property Connections _mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetGeneratorsRequested(config) {
			if (config) {
				if (config.running === true) {
					const duration = config.duration || 0
					root.generator.start(duration)
				} else if (config.running === false) {
					root.generator.stop()
				}
			}
		}
	}
}
