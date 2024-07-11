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
		function onLevelsEnabledChanged() {
			if (!Global.mockDataSimulator.levelsEnabled) {
				_createdObjects = []
				Global.environmentInputs.model.clear()
			}
		}
	}

	function populate() {
		if (Global.mockDataSimulator.levelsEnabled) {
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
		const deviceInstanceNum = mockDeviceCount++
		const inputObj = inputComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.temperature.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
		_createdObjects.push(inputObj)
		for (var p in properties) {
			inputObj["_" + p].setValue(properties[p])
		}
	}

	property Component inputComponent: Component {
		EnvironmentInput {
			onTemperatureTypeChanged: {
				if (temperatureType >= 0 && !_customName.value) {
					_customName.setValue(Global.environmentInputs.temperatureTypeToText(temperatureType) + " temperature sensor")
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
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
			// Do not remove all objects in the model before adding the new ones, as Levels page
			// will disappear.
			const hasCreatedObjects = _createdObjects.length > 0
			while (_createdObjects.length > 1) {
				let obj = _createdObjects.pop()
				obj._deviceInstance.setValue(-1)
				obj.destroy()
			}

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					root.addInput(config[i])
				}
			}

			if (hasCreatedObjects) {
				let lastObject = _createdObjects.shift()
				lastObject._deviceInstance.setValue(-1)
				lastObject.destroy()
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
