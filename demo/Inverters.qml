/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: populate()
	}

	function populate() {
		let quattro = {
			state: 9,   // Inverting
			productId: 9816,
			productName: "Quattro 48/5000/70-2x100",
			ampOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ],   // EU amp options
			mode: Enums.Inverters_Mode_On,
			modeAdjustable: true,
			input1Type: Enums.Inverters_InputType_Generator,
			currentLimit1: 50,
			currentLimit1Adjustable: true,
			input2Type: Enums.Inverters_InputType_Shore,
			currentLimit2: 16,
			currentLimit2Adjustable: false,
		}
		let inverter = inverterComponent.createObject(root, quattro)
		model.append({ inverter: inverter })
	}

	Component {
		id: inverterComponent

		QtObject {
			id: inverter

			property int productId
			property string productName
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
		}
	}
}
