/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property bool manualConfig

	function populate() {
		const gridInput = {
			source: VenusOS.AcInputs_InputSource_Grid,
			serviceType: "vebus",
			serviceName: "com.victronenergy.vebus.ttyUSB0",
			connected: 0,
			phaseCount: 3,
		}
		const generatorInput = {
			source: VenusOS.AcInputs_InputSource_Generator,
			serviceType: "genset",
			serviceName: "com.victronenergy.genset.ttyUSB0",
			connected: 1,
			phaseCount: 3,
		}
		setInputs([ gridInput, generatorInput ])
	}

	function setInputs(inputs) {
		inputObjects.model = inputs
		for (let i = 0; i < inputs.length; ++i) {
			if (inputs[i].connected === 1) {
				acSource.setValue(inputs[i].source)
				return
			}
		}
		acSource.setValue(undefined)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetAcInputsRequested(config) {
			if (config) {
				root.manualConfig = true
				setInputs(config)
			}
		}
	}

	readonly property VeQuickItem acSource: VeQuickItem {
		uid: Global.system.serviceUid + "/Ac/ActiveIn/Source"

		// Every 10 seconds, switch between Ac/0 and Ac/1 as the active source
		property Timer _sourceSwitchTimer: Timer {
			running: Global.mockDataSimulator.timersActive && !root.manualConfig
			repeat: true
			interval: 10000
			onTriggered: {
				const firstInput = Global.acInputs.input1Info
				const secondInput = Global.acInputs.input2Info
				if (!!firstInput && !!secondInput) {
					const inputToConnect = acSource.value === firstInput.source ? secondInput : firstInput
					const inputToDisconnect = acSource.value === firstInput.source ? firstInput : secondInput
					inputToConnect._connected.setValue(1)
					inputToDisconnect._connected.setValue(0)
					acSource.setValue(inputToConnect.source)
				}
			}
		}
	}

	readonly property Instantiator inputObjects: Instantiator {
		model: null

		delegate: QtObject {
			id: input

			required property int index
			required property var modelData

			readonly property AcInputSystemInfo inputSysInfo: AcInputSystemInfo {
				bindPrefix: Global.system.serviceUid + "/Ac/In/" + input.index

				// For convenience, if this is a vebus service, then use the value of
				// com.victronenergy.system/VebusService as the /ServiceName for this input (i.e.
				// pretend this input is on that vebus service).
				readonly property string vebusServiceUid: Global.system.veBus.serviceUid
				onVebusServiceUidChanged: {
					if (serviceType === "vebus") {
						_serviceName.setValue(vebusServiceUid)
					}
				}

				Component.onCompleted: {
					_deviceInstance.setValue(input.index)
					for (let configProperty in input.modelData) {
						const configValue = input.modelData[configProperty]
						if (configProperty === "phaseCount") {
							_numberOfPhases.setValue(configValue)
						} else {
							inputSysInfo["_" + configProperty].setValue(configValue)
						}
					}

					// Hardcode the min/max currents
					_minimumCurrent.setValue(-20)
					_maximumCurrent.setValue(20)
				}
			}
		}
	}

	readonly property VeQuickItem _numberOfPhases: VeQuickItem {
		uid: Global.system.serviceUid + "/Ac/ActiveIn/NumberOfPhases"
		Component.onCompleted: {
			setValue(3)
		}
	}

	property Timer _measurementsTimer: Timer {
		property int testEnergyCounter: -5

		running: Global.mockDataSimulator.timersActive
		repeat: true
		interval: 3000
		triggeredOnStart: true
		onTriggered: {
			if (!Global.acInputs.activeInput) {
				return
			}

			// Cycle between positive -> negative -> zero energy.
			// Positive energy value = imported energy, flowing towards inverter/charger.
			// Negative energy value = exported energy, flowing towards grid.
			const negativeEnergyFlow = testEnergyCounter < 0
			const zeroEnergyFlow = testEnergyCounter === 0

			const phases = Global.acInputs.activeInput._phases._phaseObjects
			let totalPower = NaN
			for (let i = 0; i < phases.count; ++i) {
				const phase = phases.objectAt(i)
				if (zeroEnergyFlow) {
					phase._power.setValue(NaN)
					phase._current.setValue(NaN)
				} else {
					const current = Math.random() * 20 * (negativeEnergyFlow ? -1 : 1)
					phase._current.setValue(current)
					phase._power.setValue(current * 10)
				}
				totalPower = Units.sumRealNumbers(totalPower, phase._power.value)
			}

			// For vebus/grid/genset services, forcibly update the total power
			const inputServiceLoader = Global.acInputs.activeInput._acInputService
			if (inputServiceLoader && inputServiceLoader.item && inputServiceLoader.hasTotalPower) {
				inputServiceLoader.item._power.setValue(totalPower)
			}

			testEnergyCounter++
			if (testEnergyCounter >= 5) {
				testEnergyCounter = -5
			}
		}
	}


	Component.onCompleted: {
		populate()
	}
}
