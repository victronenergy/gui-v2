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
			mode: VenusOS.Inverters_Mode_On,
			modeAdjustable: true,
			input1Type: VenusOS.AcInputs_InputType_Generator,
			currentLimit1: 50,
			currentLimit1Adjustable: true,
			input2Type: VenusOS.AcInputs_InputType_Shore,
			currentLimit2: 16,
			currentLimit2Adjustable: false,
		}
		let inverter = inverterComponent.createObject(root, quattro)
		Global.inverters.addInverter(inverter)
	}

	property int _objectId
	property Component inverterComponent: Component {
		MockDevice {
			id: inverter

			property int productId
			property int productType
			property var ampOptions

			property int state
			property int mode: -1
			property bool modeAdjustable

			property int input1Type: -1
			property real currentLimit1: -1.0
			property bool currentLimit1Adjustable

			property int input2Type: -1
			property real currentLimit2: -1.0
			property bool currentLimit2Adjustable

			function setMode(newMode) {
				mode = newMode
			}

			function setCurrentLimit1(newLimit) {
				currentLimit1 = newLimit
			}

			function setCurrentLimit2(newLimit) {
				currentLimit2 = newLimit
			}

			name: "Inverter" + deviceInstance.value
			Component.onCompleted: deviceInstance.value = root._objectId++
		}
	}

	Component.onCompleted: {
		populate()
	}
}
