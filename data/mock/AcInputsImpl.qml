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
		// Note: since this is using "com.victronenergy.vebus.ttyUSB0" as the service, this is
		// actually using the first mock vebus service provided by InverterChargersImpl.qml.
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
			productId: ProductInfo.ProductId_Genset_FischerPandaAc,
		}
		setInputs([ gridInput, generatorInput ])
	}

	function setMockValue(input, path, value) {
		Global.mockDataSimulator.setMockValue(input.serviceUid + path, value)
	}

	function setInputs(inputConfigs) {
		inputDeviceObjects.model = []

		// Configure the system AC input info and input properties.
		const inputInfos = [ Global.acInputs.input1Info, Global.acInputs.input2Info ]
		const inputModelData = []
		for (let i = 0; i < inputInfos.length; ++i) {
			const inputInfo = inputInfos[i]
			const inputConfig = inputConfigs[i]
			const mandatoryProperties = ["source", "serviceType", "serviceName", "connected"]
			let propertyName
			for (propertyName of mandatoryProperties) {
				// Reset the main properties for the AC-in system info.
				inputInfo["_" + propertyName].setValue(undefined)
			}
			if (!inputConfig) {
				// There is no AC-in configured at this index.
				inputModelData.push({})
				continue
			}

			inputInfo.inputIndex = i
			inputInfo._deviceInstance.setValue(i)

			// Hardcode the min/max currents
			if (isNaN(inputInfo._minimumCurrent.value)) {
				inputInfo._minimumCurrent.setValue(-20)
			}
			if (isNaN(inputInfo._maximumCurrent.value)) {
				// Use a max bigger than 20 to check the side panel graph is still
				// symmetrical above and below the threshold.
				inputInfo._maximumCurrent.setValue(40)
			}

			for (let configProperty in inputConfig) {
				const configValue = inputConfig[configProperty]
				if (inputInfo["_" + configProperty] !== undefined) {
					inputInfo["_" + configProperty].setValue(configValue)
				}
			}
			inputModelData.push(inputConfig)
		}

		inputDeviceObjects.model = inputModelData
		Qt.callLater(_updateActiveInfo)
	}

	function _updateActiveInfo() {
		let activeSource = -1
		let activeInValues = { vebus: -1, acsystem: -1 }
		let inputObject
		let i

		// Find the connected source and ActiveIn value for each AC-in.
		// The ActiveIn is only used for vebus and Multi RS services.
		for (i = 0; i < inputDeviceObjects.count; ++i) {
			inputObject = inputDeviceObjects.objectAt(i)
			if (!!inputObject && inputObject.inputInfo.connected) {
				activeSource = inputObject.inputInfo.source
				if (activeInValues[inputObject.inputInfo.serviceType] !== undefined) {
					activeInValues[inputObject.inputInfo.serviceType] = i
				}
			}
		}

		// Set the system /Ac/ActiveIn/Source
		acSource.setValue(activeSource >= 0 ? activeSource : undefined)

		// Set the vebus and multi /Ac/ActiveIn/ActiveInput
		for (const serviceType in activeInValues) {
			const activeIn = activeInValues[serviceType]
			if (activeIn < 0) {
				continue
			}
			for (i = 0; i < inputDeviceObjects.count; ++i) {
				inputObject = inputDeviceObjects.objectAt(i)
				if (!!inputObject && inputObject.inputInfo.serviceType === serviceType) {
					inputObject.setMockValue("/Ac/ActiveIn/ActiveInput", activeIn)
				}
			}
		}
	}

	readonly property Instantiator inputDeviceObjects: Instantiator {
		delegate: Device {
			required property var modelData
			required property int index
			readonly property var inputInfo: Global.acInputs["input" + (index+1) + "Info"]

			// For convenience, if this is a vebus service, then use the value of
			// com.victronenergy.system/VebusService as the /ServiceName for this input (i.e.
			// pretend this input is on that vebus service).
			readonly property string vebusServiceUid: Global.system.veBus.serviceUid
			onVebusServiceUidChanged: {
				if (modelData.serviceType === "vebus") {
					inputInfo._serviceName.setValue(vebusServiceUid.substr(6))
				}
			}

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			serviceUid: modelData.serviceName ? "mock/" + modelData.serviceName : ""

			Component.onCompleted: {
				_deviceInstance.setValue(index)
				if (modelData.productId) {
					_productId.setValue(modelData.productId)
				}
				const input = Global.acInputs["input" + (index+1)]
				if (modelData.phaseCount !== undefined) {
					if (inputInfo.serviceType === "vebus" || inputInfo.serviceType === "acsystem") {
						setMockValue("/Ac/NumberOfPhases", modelData.phaseCount)
					} else if (inputInfo.serviceType === "grid" || inputInfo.serviceType === "genset") {
						setMockValue("/NrOfPhases", modelData.phaseCount)
					}
				}
			}
		}
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
					root._updateActiveInfo()
				}
			}
		}
	}

	property Timer _measurementsTimer: Timer {
		running: Global.mockDataSimulator.timersActive
		repeat: true
		interval: 3000
		triggeredOnStart: true
		onTriggered: {
			_updateMeasurements(Global.acInputs.input1)
			_updateMeasurements(Global.acInputs.input2)
		}

		function _updateMeasurements(acInput) {
			if (!acInput || !acInput.operational) {
				return
			}

			for (let i = 0; i < acInput.phases.count; ++i) {
				// For each phase, randomly choose between positive, negative and no energy.
				// Positive energy value = imported energy, flowing towards inverter/charger.
				// Negative energy value = exported energy, flowing towards grid.
				const randomNum = Math.random()
				const negativeEnergyFlow = randomNum < 0.5
				const noEnergyFlow = randomNum >= 0.5 && randomNum <= 0.6
				let power = NaN
				let current = NaN
				if (!noEnergyFlow) {
					current = Math.random() * 20 * (negativeEnergyFlow ? -1 : 1)
					power = current * 10
				}
				acInput._phaseMeasurements["powerL" + (i+1)].setValue(power)
				acInput._phaseMeasurements["_currentL" + (i+1)].setValue(current)
			}
		}
	}


	Component.onCompleted: {
		populate()
	}
}
