/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	Component.onCompleted: {
		generatorComponent.createObject(root, { serviceUid: "mock/com.victronenergy.generator.startstop0" } )
		generatorComponent.createObject(root, { serviceUid: "mock/com.victronenergy.generator.startstop1" } )
	}

	property Component generatorComponent: Component {
		Generator {
			id: generator

			onValidChanged: {
				if (!!Global.generators) {
					if (valid) {
						Global.generators.addGenerator(generator)
					} else {
						Global.generators.removeGenerator(generator)
					}
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(0)
				_productName.setValue("Start/Stop generator")
				_state.setValue(VenusOS.Generators_State_Running)
				_runningBy.setValue(VenusOS.Generators_RunningBy_Soc)
				setAutoStart(true)
			}

			property Connections _stateUpdate: Connections {
				target: generator._manualStart
				function onValueChanged() {
					if (target.value === 1) {
						generator._state.setValue(VenusOS.Generators_State_Running)
						generator._runningBy.setValue(VenusOS.Generators_RunningBy_Manual)
					} else if (target.value === 0) {
						generator._state.setValue(VenusOS.Generators_State_Stopped)
						generator._runningBy.setValue(VenusOS.Generators_RunningBy_NotRunning)
					}
				}

				property Timer _runTimeTick: Timer {
					running: generator.state === VenusOS.Generators_State_Running
					interval: 1000
					repeat: true
					onTriggered: generator._runtime.setValue(generator.runtime + 1)
				}
			}

			// Some dummy system settings
			property VeQuickItem _accumulatedTotal: VeQuickItem {
				uid: generator.serviceUid + "/AccumulatedTotal"
				Component.onCompleted: setValue(3600)
			}
			property VeQuickItem _error: VeQuickItem {
				uid: generator.serviceUid + "/Error"
				Component.onCompleted: setValue(1)
			}
			property VeQuickItem _nextStartTimer: VeQuickItem {
				uid: generator.serviceUid + "/NextTestRun"
				Component.onCompleted: setValue(Date.now() / 1000 + 80)
			}
			property VeQuickItem _serviceCounterReset: VeQuickItem {
				uid: generator.serviceUid + "/ServiceCounterReset"
				Component.onCompleted: setValue(0)
			}
			property VeQuickItem _testRunIntervalRuntime: VeQuickItem {
				uid: generator.serviceUid + "/TestRunIntervalRuntime"
				Component.onCompleted: setValue(5678)
			}
			property VeQuickItem _capabilities: VeQuickItem {
				uid: generator.serviceUid + "/Capabilities"
				Component.onCompleted: setValue(1)
			}

			property Connections _mockConn: Connections {
				target: Global.mockDataSimulator || null

				function onSetGeneratorsRequested(config) {
					if (config) {
						if (config.running === true) {
							const duration = config.duration || 0
							generator.start(duration)
						} else if (config.running === false) {
							generator.stop()
						}
					}
				}
			}
		}
	}
}
