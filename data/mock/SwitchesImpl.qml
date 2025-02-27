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
		switchDevComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.switch.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component switchDevComponent: Component {
		SwitchDev {
			id: switchDev

			property int inputCount: 4

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			function populateSwitches(Channels){
				for (let i = 0; i < switchDev.inputCount; ++i) {

				}
			}

			property Timer _measurementUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					for (let i = 0; i < switchDev.inputCount; ++i) {
						if (i != 1){
							switchDev.setMockValue("/SwitchableOutput/%1/Voltage".arg(i), Math.random() * 50)
							switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(i), Math.random() * 10)
							switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(i), Math.random() * 10)
						}
					}

				}
			}

			property Instantiator vebusDevicesExtendedStatus: Instantiator {
				model: inputCount
				delegate: QtObject {
					readonly property VeQuickItem switchState: VeQuickItem {
						property int _testStatusIndex: 0
						uid: switchDev.serviceUid + "/SwitchableOutput/%1/State".arg(index)
						onValueChanged: {
							if (value){
								var statusData = [VenusOS.Switch_Status_Output_Fault,VenusOS.Switch_Status_Disabled,VenusOS.Switch_Status_Powered,
												  VenusOS.Switch_Status_On,VenusOS.Switch_Status_Over_Temperature,
												  VenusOS.Switch_Status_Short_Fault,VenusOS.Switch_Status_Tripped]
								if (index === 0 ){
									switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(index),  statusData[ _testStatusIndex])
									_testStatusIndex++
									if (_testStatusIndex >= statusData.length) _testStatusIndex = 0
								} else switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(index), VenusOS.Switch_Status_On)

							} else {
								switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(index), VenusOS.Switch_Status_Off)
							}
						}
					}
					readonly property VeQuickItem switchStatus: VeQuickItem {
						uid: switchDev.serviceUid + "/SwitchableOutput/%1/Status".arg(index)
					}
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("mock Switch " + deviceInstance)
				_productName.setValue("mockSmartSwitch")
				switchDev.setMockValue("/State", Math.floor(Math.random() * 3))
				switchDev.setMockValue("/NrOfChannels", switchDev.inputCount)
				for (let i=0;i<switchDev.inputCount;i++){
					if (i === 1) switchDev.setMockValue("/SwitchableOutput/%1/Settings/CustomName".arg(i), "cust %1".arg(i))
					else switchDev.setMockValue("/SwitchableOutput/%1/CustomName".arg(i),"")
					switchDev.setMockValue("/SwitchableOutput/%1/Settings/Type".arg(i), i % 3)
					if (i == 1) switchDev.setMockValue("/SwitchableOutput/%1/Settings/ValidTypes".arg(i), 0x2);
					else switchDev.setMockValue("/SwitchableOutput/%1/Settings/ValidTypes".arg(i), 0x7);
					switchDev.setMockValue("/SwitchableOutput/%1/State".arg(i), 0)
					switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(i), 0)
					//optional
					if (i != 0) switchDev.setMockValue("/SwitchableOutput/%1/Dimming".arg(i), 50)
					if (i != 2) switchDev.setMockValue("/SwitchableOutput/%1/Settings/FuseRating".arg(i), 5)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Temperature".arg(i), 0)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Voltage".arg(i), 0)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(i), 0)
					if (i <2) switchDev.setMockValue("/SwitchableOutput/%1/Settings/Group".arg(i), "")
					else switchDev.setMockValue("/SwitchableOutput/%1/Settings/Group".arg(i), "Group %1".arg(Math.round(i/2)))
				}
			}
		}
	}

	Component.onCompleted: {
		populate()
		populate()
		populate()
		populate()
		populate()
		populate()
	}
	}
