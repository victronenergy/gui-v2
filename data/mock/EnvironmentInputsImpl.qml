/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount
	property var _createdObjects: []

	Connections {
		target: Global.mockDataSimulator
		function onEnvironmentalInputsEnabledChanged() {
			if (!Global.mockDataSimulator.environmentalInputsEnabled) {
				_createdObjects = []
				Global.environmentInputs.model.clear()
			}
		}
	}

	function populate() {
		if (Global.mockDataSimulator.environmentalInputsEnabled) {
			const inputCount = Math.ceil(Math.random() * 4)
			for (let i = 0; i < inputCount; ++i) {
				const properties = {
					temperature: Math.random() * 100,
					humidity: Math.random() * 100
				}
				addInput(properties)
			}
		}
	}

	function addInput(properties) {
		if (properties.temperatureType === undefined) {
			properties.temperatureType = Math.floor(Math.random() * VenusOS.Temperature_DeviceType_Generic)
		}
		const inputObj = inputComponent.createObject(root)
		_createdObjects.push(inputObj)
		for (var p in properties) {
			inputObj["_" + p].setValue(properties[p])
		}
	}

	property Component inputComponent: Component {
		EnvironmentInput {
			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			onTemperatureTypeChanged: {
				if (temperatureType >= 0 && !_customName.value) {
					_customName.setValue(Global.environmentInputs.temperatureTypeToText(temperatureType) + " temperature sensor")
				}
			}

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.temperature.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_productName.setValue("Generic Temperature Sensor")
				_status.setValue(VenusOS.EnvironmentInput_Status_Ok)
			}

			property Timer dummyUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 10 * 1000
				onTriggered: {
					_temperature.setValue(Math.random() * 100)
					_humidity.setValue(Math.random() * 100)
				}
			}
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetEnvironmentInputsRequested(config) {
			Global.environmentInputs.model.clear()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					root.addInput(config[i])
				}
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
