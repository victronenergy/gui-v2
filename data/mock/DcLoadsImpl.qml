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
		// Add all known types of DC loads.
		const serviceTypes = ["dcload", "dcsystem", "dcdc"]
		for (let i = 0; i < serviceTypes.length; ++i) {
			createDcLoad({ serviceType: serviceTypes[i]})
		}
		updateDcValues.restart()
	}

	function createDcLoad(props) {
		if (!props.serviceType) {
			console.warn("Cannot create mock DC Load device without service type! Properties are:", JSON.stringify(props))
			return
		}
		const deviceInstanceNum = mockDeviceCount++
		const dcLoad = dcLoadComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.%1.ttyUSB%2".arg(props.serviceType).arg(deviceInstanceNum),
			deviceInstance: deviceInstanceNum,
			serviceType: props.serviceType
		})
		for (let name in props) {
			if (name !== "serviceType") {
				dcLoad["_" + name].setValue(props[name])
			}
		}
		_createdObjects.push(dcLoad)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSystemRequested(config) {
			if (config) {
				while (_createdObjects.length > 0) {
					let obj = _createdObjects.pop()
					obj.deviceInstance = -1
					obj.destroy()
				}
				if (config.dc) {
					for (let i = 0; i < config.dc.serviceTypes.length; ++i) {
						createDcLoad({ serviceType: config.dc.serviceTypes[i]})
					}
				} else {
					Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/System/Power", NaN)
					Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/Battery/Voltage", NaN)
				}
				updateDcValues.restart()
			}
		}
	}

	property Timer updateDcValues: Timer {
		running: Global.mockDataSimulator.timersActive && !!(Global.allDevicesModel?.combinedDcLoadsModel)
		interval: 500
		repeat: true

		onTriggered: {
			if (! Global.allDevicesModel) {
				return
			}

			let totalPower = NaN
			for (let i = 0; i < Global.allDevicesModel.combinedDcLoadDevices.count; ++i) {
				const dcLoad = Global.allDevicesModel.combinedDcLoadDevices.deviceAt(i)
				const power = Global.mockDataSimulator.mockValue(dcLoad.serviceUid + "/Dc/0/Power")
				totalPower = Units.sumRealNumbers(totalPower, power)
			}

			Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/System/Power", totalPower)
			const voltage = isNaN(totalPower) ? NaN : 20 + Math.floor(Math.random() * 10)
			Global.mockDataSimulator.setMockValue("com.victronenergy.system/Dc/Battery/Voltage", voltage)
		}
	}

	property Component dcLoadComponent: Component {
		Device {
			id: dcLoad

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

			function setMockValue(key, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + key, value)
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("DC Load (%1)".arg(serviceType))
				setMockValue("/Mode", 4)
				setMockValue("/State", 5)
				setMockValue("/Error", 0)
				setMockValue("/Connected", 1)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
