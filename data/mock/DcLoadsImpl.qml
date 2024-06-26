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
	}

	function createDcLoad(props) {
		if (!props.serviceType) {
			console.warn("Cannot create mock DC Load device without service type! Properties are:", JSON.stringify(props))
			return
		}
		const dcLoad = dcLoadComponent.createObject(root, { serviceType: props.serviceType })
		for (let name in props) {
			if (name !== "serviceType") {
				dcLoad["_" + name].setValue(props[name])
			}
		}
		_createdObjects.push(dcLoad)
	}

	property Component dcLoadComponent: Component {
		DcLoad {
			id: dcLoad

			property string serviceType

			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

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
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy." + serviceType + ".ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_productName.setValue("DC Load (%1)".arg(serviceType))
				_productId.setValue(123)
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
