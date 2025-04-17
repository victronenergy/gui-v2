/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount
	property var _createdObjects: []

	function populate() {
		 // Add a random set of DC inputs.
		// Have 2 inputs at most, to leave some space for AC inputs in overview page
		const serviceTypes = ["alternator", "fuelcell", "dcsource"]
		const modelCount = Math.floor(Math.random() * 2) + 1
		for (let i = 0; i < modelCount; ++i) {
			const typeIndex = Math.floor(Math.random() * serviceTypes.length)
			createInput({ serviceType: serviceTypes[typeIndex]})
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetDcInputsRequested(config) {
			Global.dcInputs.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.types.length; ++i) {
					let inputConfig = config.types[i]
					if (inputConfig) {
						createInput(inputConfig)
					}
				}
			}
		}
	}

	function createInput(props) {
		if (!props.serviceType) {
			console.warn("Cannot create mock DC device without service type! Properties are:", JSON.stringify(props))
			return
		}
		const deviceInstanceNum = mockDeviceCount++
		const input = inputComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.%1.ttyUSB%2".arg(props.serviceType).arg(deviceInstanceNum),
			deviceInstance: deviceInstanceNum,
			serviceType: props.serviceType
		})
		for (let name in props) {
			if (name !== "serviceType") {
				input["_" + name].setValue(props[name])
			}
		}
		if (props.serviceType === "alternator" && props.productId === undefined) {
			// Set a generic product id so that PageAlternator can show a valid page.
			input._productId.setValue(ProductInfo.ProductId_Alternator_Generic)
		}
		_createdObjects.push(input)
	}

	readonly property VeQuickItem _maximumPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/Input/Power/Max"
		Component.onCompleted: setValue(200)
	}

	property Component inputComponent: Component {
		DcInput {
			id: input

			property string serviceType

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				triggeredOnStart: true

				onTriggered: {
					setMockValue("/Dc/0/Power", 50 + Math.random() * 10)
					setMockValue("/Dc/0/Voltage", 20 + Math.random() * 10)
					setMockValue("/Dc/0/Current", 1 + Math.random())
					setMockValue("/Dc/In/P", 50 + Math.random() * 10)
					setMockValue("/Dc/In/V", 20 + Math.random() * 10)
					setMockValue("/Dc/In/I", 1 + Math.random())
				}
			}

			onProductIdChanged: {
				if (productId === ProductInfo.ProductId_OrionXs_Min) {
					initOrionXSValues()
				}
			}

			function setMockValue(key, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + key, value)
			}

			function initOrionXSValues() {
				setMockValue("/Capabilities", 1342292476)
				setMockValue("/Connected", 1)
				setMockValue("/CustomName", "Orion XS H123393K2J2")
				setMockValue("/DeviceOffReason", 0)
				setMockValue("/Mode", 1)
				setMockValue("/Link/BatteryCurrent", 3)
				setMockValue("/Link/TemperatureSense", 25)
				setMockValue("/Link/NetworkStatus", 4)
				setMockValue("/Error", 0)
				setMockValue("/Settings/OutputBattery", 0)
				setMockValue("/Dc/0/Temperature", Math.random() * 50)

				setMockValue("/Dc/In/I", 3.5)
				setMockValue("/Dc/In/P", 47.9)
				setMockValue("/Dc/In/V", 13.4)

				setMockValue("/History/Cumulative/User/OperationTime", 60)  // seconds
				setMockValue("/History/Cumulative/User/ChargedAh", 100)
				setMockValue("/History/Cumulative/User/CyclesStarted", 3)
				setMockValue("/History/Cumulative/User/CyclesCompleted", 2)
				setMockValue("/History/Cumulative/User/NrOfPowerups", 50)
				setMockValue("/History/Cumulative/User/NrOfDeepDischarges", 5)
				setMockValue("/History/Cycle/CyclesAvailable", 0)

				setMockValue("/History/Cycle/0/TerminationReason", 7)
				setMockValue("/History/Cycle/0/BulkTime", 2 * 60)
				setMockValue("/History/Cycle/0/BulkCharge", 30)
				setMockValue("/History/Cycle/0/AbsorptionCharge", 40)
				setMockValue("/History/Cycle/0/StartVoltage", 10.5)
				setMockValue("/History/Cycle/0/EndVoltage", 20.25)
				setMockValue("/History/Cycle/0/Error", 1)
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("DC device (%1)".arg(serviceType))
				setMockValue("/State", 4)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
