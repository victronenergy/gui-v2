/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		for (let i = 0; i < 3; ++i) {
			createCharger({ status: Math.random() * VenusOS.Evcs_Status_Charged })
		}
	}

	function createCharger(properties) {
		const charger = chargerComponent.createObject(root, properties)
		_createdObjects.push(charger)
		Global.evChargers.addCharger(charger)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetEvChargersRequested(config) {
			Global.evChargers.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					createCharger(config.chargers[i])
				}
			}
		}
	}

	property int _objectId
	property Component chargerComponent: Component {
		MockDevice {
			id: evCharger

			readonly property string serviceUid: "com.victronenergy.evcharger.ttyUSB" + deviceInstance.value

			property int status: Math.random() * VenusOS.Evcs_Status_OverheatingDetected
			property int mode: Math.random() * VenusOS.Evcs_Mode_Scheduled
			property bool connected
			property int chargingTime: 100000

			property real energy: 1 + Math.random() * 10
			property real power: 1 + Math.random() * 100
			property real current: 1 + Math.random() * 20
			property real maxCurrent: 30

			readonly property ListModel phases: ListModel {
				ListElement { name: "L1"; power: 10 }
				ListElement { name: "L2"; power: 20 }
				ListElement { name: "L3"; power: 30 }
			}

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000

				onTriggered: {
					const properties = ["energy", "power", "current"]
					for (let propIndex = 0; propIndex < properties.length; ++propIndex) {
						const propName = properties[propIndex]
						const value = evCharger[propName]
						if (!isNaN(value)) {
							evCharger[propName] = value * 1.01
						}
					}
					evCharger.current = 1 + Math.random() * 20
					Global.evChargers.updateTotals()
					evCharger.chargingTime += 60

					Global.mockDataSimulator.mockDataValues[serviceUid + "/Current"] = current
				}
			}

			property Timer _statusChange: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 3000

				onTriggered: {
					evCharger.status = Math.random() * VenusOS.Evcs_Status_OverheatingDetected
				}
			}

			name: "EVCharger" + deviceInstance.value
			Component.onCompleted: {
				deviceInstance.value = root._objectId++

				Global.mockDataSimulator.mockDataValues[serviceUid + "/Mode"] = mode
				Global.mockDataSimulator.mockDataValues[serviceUid + "/Position"] = 1
				Global.mockDataSimulator.mockDataValues[serviceUid + "/StartStop"] = 1
				Global.mockDataSimulator.mockDataValues[serviceUid + "/AutoStart"] = 1
				Global.mockDataSimulator.mockDataValues[serviceUid + "/EnableDisplay"] = 1
				Global.mockDataSimulator.mockDataValues[serviceUid + "/MaxCurrent"] = maxCurrent

				// Device info
				Global.mockDataSimulator.mockDataValues[serviceUid + "/Mgmt/Connection"] = serviceUid
				Global.mockDataSimulator.mockDataValues[serviceUid + "/Connected"] = 1
				Global.mockDataSimulator.mockDataValues[serviceUid + "/ProductName"] = name
				Global.mockDataSimulator.mockDataValues[serviceUid + "/ProductId"] = "0xC025"
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
