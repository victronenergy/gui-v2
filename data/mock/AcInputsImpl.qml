/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import Victron.Utils

QtObject {
	id: root

	property bool manualConfig

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetAcInputsRequested(config) {
			if (config) {
				root.manualConfig = true
				acSource.setValue(config.source)
				root.inputSysInfo._connected.setValue(1)
				_phaseModel._numberOfPhases.setValue(config.phaseCount || 1)
			}
		}
	}

	readonly property VeQuickItem acSource: VeQuickItem {
		uid: Global.system.serviceUid + "/Ac/ActiveIn/Source"

		// Every 10 seconds, switch to a different source
		property Timer _sourceSwitchTimer: Timer {
			readonly property var sources: [
				VenusOS.AcInputs_InputSource_Grid,
				VenusOS.AcInputs_InputSource_Generator,
				VenusOS.AcInputs_InputSource_Shore,
				VenusOS.AcInputs_InputSource_Inverting,
			]
			property int sourceIndex

			running: Global.mockDataSimulator.timersActive && !root.manualConfig
			repeat: true
			interval: 10000
			triggeredOnStart: true
			onTriggered: {
				if (acSource.value === undefined) {
					acSource.setValue(sources[0])
					return
				}
				const nextSource = Utils.modulo(sourceIndex + 1, sources.length)
				acSource.setValue(nextSource)
				sourceIndex++

				// Reset number of phases
				_phaseModel._numberOfPhases.setValue(1 + (Math.random() * 2))
			}
		}
	}

	readonly property AcInputSystemInfo inputSysInfo: AcInputSystemInfo {
		bindPrefix: Global.system.serviceUid + "/Ac/In/0"
		Component.onCompleted: {
			_deviceInstance.setValue(300)
			_serviceType.setValue("vebus")
			_connected.setValue(1)
		}

		// For convenience, always use the value of com.victronenergy.system/VebusService as the
		// ServiceName for this input (i.e. pretend this input is on that vebus service).
		readonly property string vebusServiceUid: Global.system.veBus.serviceUid
		onVebusServiceUidChanged: root.inputSysInfo._serviceName.setValue(vebusServiceUid)

		// Disconnects every 15 seconds, for 3 seconds
		property Timer _connectedTimer: Timer {
			running: Global.mockDataSimulator.timersActive && !root.manualConfig
			interval: 15000
			onTriggered: {
				if (inputSysInfo.connected) {
					inputSysInfo._connected.setValue(0)
					interval = 3000
					restart()
				} else {
					inputSysInfo._connected.setValue(1)
					interval = 15000
					restart()
				}
			}
		}
	}

	readonly property AcInputPhaseModel _phaseModel: AcInputPhaseModel {
		Component.onCompleted: {
			_numberOfPhases.setValue(3)
		}

		property Timer _measurementsTimer: Timer {
			property int testEnergyCounter: -5

			running: true
			repeat: true
			interval: 3000
			onTriggered: {
				// Cycle between positive -> negative -> zero energy.
				// Positive energy value = imported energy, flowing towards inverter/charger.
				// Negative energy value = exported energy, flowing towards grid.
				const negativeEnergyFlow = testEnergyCounter < 0
				const zeroEnergyFlow = testEnergyCounter === 0

				const phases = _phaseModel._phaseObjects
				let totalPower = NaN
				for (let i = 0; i < phases.count; ++i) {
					const phase = phases.objectAt(i)
					if (zeroEnergyFlow) {
						phase._power.setValue(NaN)
					} else {
						const value = negativeEnergyFlow
									? (Math.random() * 300) * -1
									: Math.random() * 300
						phase._power.setValue(value)
					}
					totalPower = Units.sumRealNumbers(totalPower, phase._power.value)
					phase._current.setValue(Math.random() * 10)
				}
				if (_inputService.serviceType === "vebus") {
					_inputService.item._power.setValue(totalPower)
				}
				testEnergyCounter++
				if (testEnergyCounter >= 5) {
					testEnergyCounter = -5
				}
			}
		}
	}

	property AcInputServiceLoader _inputService: AcInputServiceLoader {
		serviceUid: "mock/" + inputSysInfo.serviceName
		serviceType: inputSysInfo.serviceType
	}
}
