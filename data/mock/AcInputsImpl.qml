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
				inputIndex: input.index

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
					const inputConnected = !!input.modelData["connected"]
					for (let configProperty in input.modelData) {
						const configValue = input.modelData[configProperty]
						if (configProperty === "phaseCount") {
							if (inputConnected) {
								_numberOfPhases.setValue(configValue)
							}
						} else {
							inputSysInfo["_" + configProperty].setValue(configValue)
						}
					}

					// Hardcode the min/max currents
					if (isNaN(_minimumCurrent.value)) {
						_minimumCurrent.setValue(-20)
					}
					if (isNaN(_maximumCurrent.value)) {
						_maximumCurrent.setValue(20)
					}
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
		running: Global.mockDataSimulator.timersActive && Global.acInputs.activeInput
		repeat: true
		interval: 3000
		triggeredOnStart: true
		onTriggered: {
			let totalPower = NaN
			for (let i = 0; i < Global.acInputs.activeInput.phases.count; ++i) {
				// For each phase, randomly choose between positive, negative and no energy.
				// Positive energy value = imported energy, flowing towards inverter/charger.
				// Negative energy value = exported energy, flowing towards grid.
				const randomNum = Math.random()
				const negativeEnergyFlow = Global.systemSettings.essFeedbackToGridEnabled && randomNum < 0.5
				const noEnergyFlow = randomNum >= 0.5 && randomNum <= 0.6
				let power = NaN
				let current = NaN
				if (!noEnergyFlow) {
					current = Math.random() * 20 * (negativeEnergyFlow ? -1 : 1)
					power = current * 10
				}
				totalPower = Units.sumRealNumbers(totalPower, power)
				const activePhasePath = Global.system.serviceUid + "/Ac/ActiveIn/L" + (i + 1)
				Global.mockDataSimulator.setMockValue(activePhasePath + "/Current", current)
				Global.mockDataSimulator.setMockValue(activePhasePath + "/Power", power)
			}

			// For vebus/grid/genset services, forcibly update the total power
			const inputServiceLoader = Global.acInputs.activeInput._acInputService
			if (inputServiceLoader && inputServiceLoader.item && inputServiceLoader.hasTotalPower) {
				inputServiceLoader.item._power.setValue(totalPower)
			}
		}
	}


	Component.onCompleted: {
		populate()
	}
}
