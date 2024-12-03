/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount

	function populate() {
		const deviceInstanceNum = mockDeviceCount++
		acSystemDeviceComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.acsystem.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component acSystemDeviceComponent: Component {
		Device {
			id: acSystem

			function addRsService(serviceName, deviceInstanceNum) {
				const multiRs = multiRsComponent.createObject(acSystem, { serviceUid: "mock/" + serviceName })
				multiRs._deviceInstance.setValue(deviceInstanceNum)
				multiRs._customName.setValue("Multi RS " + deviceInstanceNum)
			}

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			property Timer _measurementUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					let i = 0
					let totalPower = 0
					for (i = 0; i < 3; ++i) {
						const inPower = Math.random() * 100
						totalPower += inPower
						acSystem.setMockValue("/Ac/In/1/L%1/P".arg(i + 1), inPower)
						acSystem.setMockValue("/Ac/In/1/L%1/I".arg(i + 1), Math.random() * 10)
						acSystem.setMockValue("/Ac/In/1/L%1/V".arg(i + 1), Math.random() * 10)
						acSystem.setMockValue("/Ac/In/1/L%1/F".arg(i + 1), Math.random() * 10)
					}
					acSystem.setMockValue("/Ac/In/1/P", totalPower)

					totalPower = 0
					for (i = 0; i < 3; ++i) {
						const outPower = 100 + (Math.random() * 100)
						totalPower += outPower
						acSystem.setMockValue("/Ac/Out/L%1/P".arg(i + 1), outPower)
						acSystem.setMockValue("/Ac/Out/L%1/I".arg(i + 1), 10 + (Math.random() * 10))
						acSystem.setMockValue("/Ac/Out/L%1/V".arg(i + 1), 10 + (Math.random() * 10))
						acSystem.setMockValue("/Ac/Out/L%1/F".arg(i + 1), 10 + (Math.random() * 10))
					}
					acSystem.setMockValue("/Ac/Out/P", totalPower)
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_productName.setValue("RS 48/6000")
				_customName.setValue("AC System " + deviceInstance)
				acSystem.setMockValue("/Ac/NumberOfPhases", 3)
				acSystem.setMockValue("/Ac/NumberOfAcInputs", 2)
				acSystem.setMockValue("/Ac/In/1/CurrentLimit", 10.5)
				acSystem.setMockValue("/Ac/In/1/CurrentLimitIsAdjustable", 1)
				acSystem.setMockValue("/Ac/In/1/Type", VenusOS.AcInputs_InputSource_Shore)
				acSystem.setMockValue("/Ac/In/2/CurrentLimit", 20.25)
				acSystem.setMockValue("/Ac/In/2/CurrentLimitIsAdjustable", 0)
				acSystem.setMockValue("/Ac/In/2/Type", VenusOS.AcInputs_InputSource_Grid)
				acSystem.setMockValue("/State", Math.floor(Math.random() * VenusOS.System_State_FaultCondition))
				acSystem.setMockValue("/Mode", VenusOS.Inverter_Mode_Off)
				acSystem.setMockValue("/ModeIsAdjustable", 1)
				acSystem.setMockValue("/Capabilities/HasAcPassthroughSupport", 1)
				acSystem.setMockValue("/ProductId", 9816)    // for EU amp options
				acSystem.setMockValue("/Settings/Ess/Mode", VenusOS.Ess_State_OptimizedWithoutBatteryLife)
				acSystem.setMockValue("/Settings/Ess/MinimumSocLimit", 85)
				acSystem.setMockValue("/Settings/AlarmLevel/LowSoc", 1) // Alarm only

				// RS devices
				const multiRsServiceName = "com.victronenergy.multi.ttyUSB" + deviceInstance
				addRsService(multiRsServiceName, deviceInstance)
				acSystem.setMockValue("/Devices/0/Service", multiRsServiceName)
				acSystem.setMockValue("/Devices/0/Instance", deviceInstance)

				// Add this multi RS to the list of inverter/chargers on the system
				const inverterCharger = inverterChargerComponent.createObject(acSystem, { serviceUid: acSystem.serviceUid })
				Global.inverterChargers.acSystemDevices.addDevice(inverterCharger)
			}
		}
	}

	// Defines a Multi RS device
	Component {
		id: multiRsComponent

		Device {
			id: multiRs

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}
			function mockValue(path) {
				Global.mockDataSimulator.mockValue(serviceUid + path)
			}

			property Timer _measurementUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					let i = 0
					for (i = 0; i < 3; ++i) {
						const inPower = (Math.random() * 100)
						multiRs.setMockValue("/Ac/In/L%1/P".arg(i + 1), inPower)
						multiRs.setMockValue("/Ac/In/L%1/I".arg(i + 1), Math.random() * 10)
						multiRs.setMockValue("/Ac/In/L%1/V".arg(i + 1), Math.random() * 10)
						multiRs.setMockValue("/Ac/In/L%1/F".arg(i + 1), Math.random() * 10)
					}
					for (i = 0; i < 3; ++i) {
						const outPower = 100 + (Math.random() * 100)
						multiRs.setMockValue("/Ac/Out/L%1/P".arg(i + 1), outPower)
						multiRs.setMockValue("/Ac/Out/L%1/I".arg(i + 1), 10 + (Math.random() * 10))
						multiRs.setMockValue("/Ac/Out/L%1/V".arg(i + 1), 10 + (Math.random() * 10))
						multiRs.setMockValue("/Ac/Out/L%1/F".arg(i + 1), 10 + (Math.random() * 10))
					}

					multiRs.setMockValue("/Soc", Math.random() * 100)
					multiRs.setMockValue("/Dc/0/Temperature", Math.random() * 100)
					multiRs.setMockValue("/Dc/0/Voltage", Math.random() * 10)
					multiRs.setMockValue("/Dc/0/Current", Math.random() * 10)

					// PV values
					multiRs.setMockValue("/Yield/Power", Math.random() * 100)
					multiRs.setMockValue("/Pv/V", Math.random() * 100)
					multiRs.setMockValue("/Yield/User", multiRs.mockValue("/Yield/User") + Math.random() * 5)
					multiRs.setMockValue("/Yield/System", multiRs.mockValue("/Yield/System") + Math.random() * 5)
				}
			}

			Component.onCompleted: {
				multiRs.setMockValue("/Ac/NumberOfPhases", 3)
				multiRs.setMockValue("/Ac/NumberOfAcInputs", 2)
				multiRs.setMockValue("/State", Math.floor(Math.random() * VenusOS.System_State_FaultCondition))
				multiRs.setMockValue("/Ac/ActiveIn/ActiveInput", 1)
				multiRs.setMockValue("/Yield/User", Math.random() * 100)
				multiRs.setMockValue("/Yield/System", Math.random() * 100)
				multiRs.setMockValue("/ErrorCode", Math.random() * 5)
			}
		}
	}

	Component {
		id: inverterChargerComponent

		InverterCharger {}
	}

	Component.onCompleted: {
		populate()
	}
}
