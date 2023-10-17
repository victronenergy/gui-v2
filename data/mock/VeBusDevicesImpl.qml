/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		let quattro = {
			state: 9,   // Inverting
			productId: 9816,
			name: "Quattro 48/5000/70-2x100",
			ampOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ].map(function(v) { return { value: v } }),   // EU amp options
			mode: VenusOS.VeBusDevice_Mode_On,
			modeAdjustable: true,
		}
		let inverter = veBusDeviceComponent.createObject(root, quattro)
		Global.veBusDevices.addVeBusDevice(inverter)

		for (let i = 0; i < 2; ++i) {
			const settingData = {
				inputNumber: i+1,
				inputType: i === 0 ? VenusOS.AcInputs_InputType_Generator : VenusOS.AcInputs_InputType_Shore,
				currentLimit: i === 0 ? 50 : 16,
				currentLimitAdjustable: i === 0,
			}
			let settings = acInputSettingsComponent.createObject(root, settingData)
			inverter.inputSettings.append({ inputSettings: settings })
		}
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

	property int _objectId
	property Component veBusDeviceComponent: Component {
		MockDevice {
			id: inverter

			property int state
			property int mode: -1
			property bool modeAdjustable

			property ListModel inputSettings: ListModel {}

			property int productId
			property int productType
			property var ampOptions

			function setMode(newMode) {
				mode = newMode
			}

			function setCurrentLimit(inputIndex, currentLimit) {
				inputSettings.get(inputIndex).inputSettings.setCurrentLimit(currentLimit)
			}

			name: "VeBusDevice" + deviceInstance.value
			Component.onCompleted: deviceInstance.value = root._objectId++
		}
	}

	Component.onCompleted: {
		populate()
	}
}
