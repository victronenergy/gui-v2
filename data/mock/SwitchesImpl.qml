/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount: 0
	readonly property int inputCount: 4

	function populate() {
		const deviceInstanceNum = mockDeviceCount++
		switchDevComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.switch.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	function outputId(outputIndex) {
		 // For the last output, use a non-integer id to test that is also supported.
		return outputIndex === inputCount ? `output_${outputIndex}` : outputIndex
	}

	property Component switchDevComponent: Component {
		Device {
			id: switchDev

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			property Timer _measurementUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					for (let i = 0; i < root.inputCount; ++i) {
						if (i != 1){
							const outputId = root.outputId(i)
							switchDev.setMockValue("/SwitchableOutput/%1/Voltage".arg(outputId), Math.random() * 50)
							switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(outputId), Math.random() * 10)
							switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(outputId), Math.random() * 10)
						}
					}

				}
			}

			property Instantiator vebusDevicesExtendedStatus: Instantiator {
				model: root.inputCount
				delegate: QtObject {
					readonly property VeQuickItem switchState: VeQuickItem {
						property int _testStatusIndex: 0
						uid: switchDev.serviceUid + "/SwitchableOutput/%1/State".arg(root.outputId(model.index))
						onValueChanged: {
							const outputId = root.outputId(model.index)
							if (value){
								const statusData = [
									VenusOS.SwitchableOutput_Status_Output_Fault,
									VenusOS.SwitchableOutput_Status_Disabled,
									VenusOS.SwitchableOutput_Status_Powered,
									VenusOS.SwitchableOutput_Status_On,
									VenusOS.SwitchableOutput_Status_Over_Temperature,
									VenusOS.SwitchableOutput_Status_Short_Fault,
									VenusOS.SwitchableOutput_Status_Tripped
								]
								if ((index === 0 )||(index === 3 )) {
									switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(outputId), statusData[ _testStatusIndex])
									_testStatusIndex++
									if (_testStatusIndex >= statusData.length) {
										_testStatusIndex = 0
									}
								} else {
									switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(outputId), VenusOS.SwitchableOutput_Status_On)
								}
							} else {
								switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(outputId), VenusOS.SwitchableOutput_Status_Off)
							}
						}
					}
					readonly property VeQuickItem switchStatus: VeQuickItem {
						uid: switchDev.serviceUid + "/SwitchableOutput/%1/Status".arg(root.outputId(model.index))
					}
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				if (mockDeviceCount < 4) {
					_customName.setValue("Switch %1 customName ".arg(deviceInstance));
				} else {
					_customName.setValue("")
				}
				_productName.setValue("Energy Solutions Smart Switch")

				switchDev.setMockValue("/State", Math.floor(Math.random() * 3) + 0x100)
				switchDev.setMockValue("/NrOfChannels", root.inputCount)

				for (let i = 0; i < root.inputCount; i++) {
					const outputId = root.outputId(i)
					switchDev.setMockValue("/SwitchableOutput/%1/Settings/ShowUIControl".arg(outputId), 1)
					switchDev.setMockValue("/SwitchableOutput/%1/Name".arg(outputId), `Output ${i+1}`)
					if (i === 1) {
						switchDev.setMockValue("/SwitchableOutput/%1/Settings/CustomName".arg(outputId), "function Val sw%1".arg(deviceInstance))
					} else {
						switchDev.setMockValue("/SwitchableOutput/%1/Settings/CustomName".arg(outputId), "")
					}
					switchDev.setMockValue("/SwitchableOutput/%1/Settings/Type".arg(outputId), i % 3)
					if (i == 1) {
						if (mockDeviceCount === 4) {
							switchDev.setMockValue("/SwitchableOutput/%1/Settings/ValidTypes".arg(outputId),
								(1 << VenusOS.SwitchableOutput_Type_Slave) | (1 << VenusOS.SwitchableOutput_Type_Latching));
						} else {
							switchDev.setMockValue("/SwitchableOutput/%1/Settings/ValidTypes".arg(outputId), (1<<VenusOS.SwitchableOutput_Type_Latching));
						}
					} else {
						switchDev.setMockValue("/SwitchableOutput/%1/Settings/ValidTypes".arg(outputId), 0x7);
					}
					switchDev.setMockValue("/SwitchableOutput/%1/State".arg(outputId), 0)
					switchDev.setMockValue("/SwitchableOutput/%1/Status".arg(outputId), 0)

					//optional
					if (i != 0) switchDev.setMockValue("/SwitchableOutput/%1/Dimming".arg(outputId), 50)
					if (i != 2) switchDev.setMockValue("/SwitchableOutput/%1/Settings/FuseRating".arg(outputId), 5)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Temperature".arg(outputId), 0)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Voltage".arg(outputId), 0)
					if (i != 1) switchDev.setMockValue("/SwitchableOutput/%1/Current".arg(outputId), 0)
					if (i < 2) {
						switchDev.setMockValue("/SwitchableOutput/%1/Settings/Group".arg(outputId), "")
					} else {
						switchDev.setMockValue("/SwitchableOutput/%1/Settings/Group".arg(outputId), "Group %1".arg(Math.round(i/2)))
					}
				}
			}
		}
	}

	Component.onCompleted: {
		for (let i = 0; i < 5; ++i) {
			populate()
		}
	}
}

