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
		const serviceTypes = ["dcload", "dcsystem"]
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
					const properties = {
						"power": 50 + Math.random() * 10,
						"voltage": 20 + Math.random() * 10,
						"current": 1 + Math.random(),
					}
					for (let propName in properties) {
						const value = properties[propName]
						dcLoad["_" + propName].setValue(value)
					}
				}
			}

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy." + serviceType + ".ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_productName.setValue("DC Load (%1)".arg(serviceType))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
