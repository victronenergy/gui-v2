/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		let quattro = {
			state: VenusOS.System_State_Inverting,
			productId: 9816,
			name: "Quattro 48/5000/70-2x100",
			ampOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ].map(function(v) { return { value: v } }),   // EU amp options
			mode: VenusOS.VeBusDevice_Mode_On,
			modeAdjustable: true,
		}
		let quattroDevice = veBusDeviceComponent.createObject(root, quattro)
		addInputSettings(quattroDevice, [VenusOS.AcInputs_InputSource_Generator, VenusOS.AcInputs_InputSource_Shore])
		Global.veBusDevices.addVeBusDevice(quattroDevice)

		let multiPlus = {
			state: VenusOS.System_State_AbsorptionCharging,
			productId: 9728,
			name: "MultiPlus 12/3000/120-5",
			ampOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ].map(function(v) { return { value: v } }),   // US amp options
			mode: VenusOS.VeBusDevice_Mode_InverterOnly,
			modeAdjustable: true,
		}
		let multiPlusDevice = veBusDeviceComponent.createObject(root, multiPlus)
		addInputSettings(multiPlusDevice, [VenusOS.AcInputs_InputSource_Grid])
		Global.veBusDevices.addVeBusDevice(multiPlusDevice)
	}

	function addInputSettings(veBusDevice, inputTypes) {
		let settings = []
		for (let i = 0; i < inputTypes.length; ++i) {
			const settingData = {
				inputNumber: i+1,
				inputType: inputTypes[i],
				currentLimit: Math.floor(Math.random() * 50),
				currentLimitAdjustable: i === 0,
			}
			let settings = acInputSettingsComponent.createObject(root, settingData)
			veBusDevice.inputSettings.append({ inputSettings: settings })
		}
		return settings
	}

	property Component acInputSettingsComponent: Component {
		QtObject {
			property int inputNumber
			property int inputType
			property real currentLimit
			property bool currentLimitAdjustable

			function setCurrentLimit(limit) {
				currentLimit = limit
			}
		}
	}

	property Component veBusDeviceComponent: Component {
		MockDevice {
			id: inverter

			property int state
			property int mode: -1
			property bool modeAdjustable
			property int numberOfPhases: 3

			property ListModel inputSettings: ListModel {}

			property int productId
			property int productType
			property var ampOptions

			property int acOutputPower: 100
			property int dcPower: 101
			property int dcVoltage: 102
			property int dcCurrent: 103
			property int stateOfCharge: 77

			property int acActiveInput: 1
			property int acActiveInputPower: 555
			property int bmsMode: 0
			property bool modeIsAdjustable: true
			property bool isMulti: false

			property var acOutput: {
				"phase1" : {
					"frequency" : 50.1,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				},
				"phase2" : {
					"frequency" : 50.2,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				},
				"phase3" : {
					"frequency" : 50.3,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				}
			}

			function setMode(newMode) {
				mode = newMode
			}

			function setCurrentLimit(inputIndex, currentLimit) {
				inputSettings.get(inputIndex).inputSettings.setCurrentLimit(currentLimit)
			}

			serviceUid: "com.victronenergy.vebus.ttyUSB" + deviceInstance
			name: "VeBusDevice" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
